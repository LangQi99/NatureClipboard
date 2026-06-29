import Foundation
import AppKit
import Combine

class ClipboardStore: ObservableObject {
    static let shared = ClipboardStore()

    @Published var items: [ClipboardItem] = []
    @Published var snippets: [Snippet] = []
    @Published var selectedCategory: ClipboardCategory = .all
    @Published var searchText: String = ""

    private let monitor = ClipboardMonitor()
    private let storageURL: URL
    private let snippetsURL: URL
    private let maxItems: Int = 5000

    var filteredItems: [ClipboardItem] {
        var result = items

        if selectedCategory == .pinned {
            result = result.filter { $0.isPinned }
        } else if selectedCategory == .favorites {
            result = result.filter { $0.isFavorite }
        } else if selectedCategory != .all {
            result = result.filter { $0.category == selectedCategory }
        }

        if !searchText.isEmpty {
            result = result.filter { item in
                if let text = item.textContent, text.localizedCaseInsensitiveContains(searchText) { return true }
                if let url = item.urlString, url.localizedCaseInsensitiveContains(searchText) { return true }
                if let paths = item.filePaths, paths.contains(where: { $0.localizedCaseInsensitiveContains(searchText) }) { return true }
                if let app = item.appName, app.localizedCaseInsensitiveContains(searchText) { return true }
                if item.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) }) { return true }
                if let title = item.title, title.localizedCaseInsensitiveContains(searchText) { return true }
                return false
            }
        }

        return result
    }

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("ClipboardManager")
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        storageURL = appDir.appendingPathComponent("clipboard_history.json")
        snippetsURL = appDir.appendingPathComponent("snippets.json")
        loadItems()
        loadSnippets()
        setupMonitor()
    }

    private func setupMonitor() {
        monitor.onNewItem = { [weak self] item in
            self?.addItem(item)
        }
        monitor.start()
    }

    func addItem(_ item: ClipboardItem) {
        if let existingIndex = items.firstIndex(where: { $0.textContent == item.textContent && $0.type == item.type && item.textContent != nil }) {
            var existing = items.remove(at: existingIndex)
            existing.lastUsedAt = Date()
            existing.useCount += 1
            items.insert(existing, at: 0)
        } else {
            items.insert(item, at: 0)
        }

        while items.count > maxItems {
            if let lastUnpinned = items.lastIndex(where: { !$0.isPinned && !$0.isFavorite }) {
                items.remove(at: lastUnpinned)
            } else {
                break
            }
        }

        saveItems()
    }

    func deleteItem(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
        saveItems()
    }

    func deleteItems(_ itemSet: Set<ClipboardItem>) {
        items.removeAll { itemSet.contains($0) }
        saveItems()
    }

    func clearAll() {
        items.removeAll { !$0.isPinned }
        saveItems()
    }

    func togglePin(_ item: ClipboardItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isPinned.toggle()
            saveItems()
        }
    }

    func toggleFavorite(_ item: ClipboardItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isFavorite.toggle()
            saveItems()
        }
    }

    func pasteItem(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        switch item.type {
        case .text:
            if let text = item.textContent {
                pasteboard.setString(text, forType: .string)
            }
        case .image:
            if let data = item.imageData, let image = NSImage(data: data) {
                pasteboard.writeObjects([image])
            }
        case .file:
            if let paths = item.filePaths {
                let urls = paths.compactMap { URL(fileURLWithPath: $0) as NSURL }
                pasteboard.writeObjects(urls)
            }
        case .url:
            if let urlString = item.urlString, let url = URL(string: urlString) {
                pasteboard.writeObjects([url as NSURL])
                pasteboard.setString(urlString, forType: .string)
            }
        case .color:
            if let hex = item.colorHex {
                pasteboard.setString(hex, forType: .string)
            }
        case .html:
            if let html = item.htmlContent {
                pasteboard.setString(html, forType: .html)
            }
            if let text = item.textContent {
                pasteboard.setString(text, forType: .string)
            }
        case .rtf:
            if let text = item.textContent {
                pasteboard.setString(text, forType: .string)
            }
            if let data = item.rtfData {
                pasteboard.setData(data, forType: .rtf)
            }
            if let html = item.htmlContent {
                pasteboard.setString(html, forType: .html)
            }
        }

        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].lastUsedAt = Date()
            items[index].useCount += 1
            saveItems()
        }

        monitor.pause()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.monitor.resume()
        }

        simulatePaste()
    }

    func mergeItems(_ selectedItems: [ClipboardItem]) -> String {
        return selectedItems.compactMap { $0.textContent }.joined(separator: "\n")
    }

    func addSnippet(_ snippet: Snippet) {
        snippets.append(snippet)
        saveSnippets()
    }

    func deleteSnippet(_ snippet: Snippet) {
        snippets.removeAll { $0.id == snippet.id }
        saveSnippets()
    }

    func updateSnippet(_ snippet: Snippet) {
        if let index = snippets.firstIndex(where: { $0.id == snippet.id }) {
            snippets[index] = snippet
            saveSnippets()
        }
    }

    func pasteSnippet(_ snippet: Snippet) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(snippet.content, forType: .string)

        if let index = snippets.firstIndex(where: { $0.id == snippet.id }) {
            snippets[index].lastUsedAt = Date()
            snippets[index].useCount += 1
            saveSnippets()
        }

        monitor.pause()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.monitor.resume()
        }

        simulatePaste()
    }

    private func simulatePaste() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            let source = CGEventSource(stateID: .hidSystemState)
            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
            let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
            keyDown?.flags = .maskCommand
            keyUp?.flags = .maskCommand
            keyDown?.post(tap: .cghidEventTap)
            keyUp?.post(tap: .cghidEventTap)
        }
    }

    private func loadItems() {
        guard let data = try? Data(contentsOf: storageURL),
              let decoded = try? JSONDecoder().decode([ClipboardItem].self, from: data) else { return }
        items = decoded
    }

    private func saveItems() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: storageURL)
    }

    private func loadSnippets() {
        guard let data = try? Data(contentsOf: snippetsURL),
              let decoded = try? JSONDecoder().decode([Snippet].self, from: data) else { return }
        snippets = decoded
    }

    private func saveSnippets() {
        guard let data = try? JSONEncoder().encode(snippets) else { return }
        try? data.write(to: snippetsURL)
    }
}
