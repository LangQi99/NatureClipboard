import SwiftUI

struct ItemListView: View {
    let items: [ClipboardItem]
    @Binding var selectedItem: ClipboardItem?
    @Binding var selectedItems: Set<ClipboardItem>
    var onPaste: (ClipboardItem) -> Void
    var onDelete: (ClipboardItem) -> Void
    var onPin: (ClipboardItem) -> Void
    var onFavorite: (ClipboardItem) -> Void
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedIndex: Int = 0

    var theme: ThemeColors { themeManager.colors }

    var body: some View {
        ScrollViewReader { proxy in
            listContent
                .onKeyPress(.upArrow) {
                    moveSelection(by: -1, proxy: proxy)
                    return .handled
                }
                .onKeyPress(.downArrow) {
                    moveSelection(by: 1, proxy: proxy)
                    return .handled
                }
                .onKeyPress(.return) {
                    if let item = selectedItem { onPaste(item) }
                    return .handled
                }
                .onKeyPress(.delete) {
                    if let item = selectedItem { onDelete(item) }
                    return .handled
                }
                .onChange(of: items) { _, _ in
                    if selectedIndex >= items.count {
                        selectedIndex = max(0, items.count - 1)
                    }
                    if !items.isEmpty { selectedItem = items[selectedIndex] }
                }
        }
        .background(Color.clear)
    }

    private var listContent: some View {
        List {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                rowView(for: item, at: index)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder
    private func rowView(for item: ClipboardItem, at index: Int) -> some View {
        ItemRowView(item: item, isSelected: index == selectedIndex, theme: theme)
            .id(item.id)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.001))
            .contentShape(Rectangle())
            .onDrag({
                selectedItem = item
                selectedIndex = index
                return makeDragProvider(for: item)
            }, preview: {
                dragPreview(for: item)
            })
            .onTapGesture {
                selectedItem = item
                selectedIndex = index
            }
            .simultaneousGesture(
                TapGesture(count: 2).onEnded { onPaste(item) }
            )
            .contextMenu { contextMenu(for: item) }
    }

    @ViewBuilder
    private func dragPreview(for item: ClipboardItem) -> some View {
        HStack(spacing: 8) {
            switch item.type {
            case .image:
                if let data = item.imageData, let image = NSImage(data: data) {
                    Image(nsImage: image).resizable().aspectRatio(contentMode: .fit).frame(maxWidth: 80, maxHeight: 60)
                }
            case .file:
                Image(systemName: "doc.fill").font(.system(size: 32)).foregroundColor(.orange)
                Text(item.filePaths?.first?.components(separatedBy: "/").last ?? "File").lineLimit(1)
            default:
                Text(item.displayTitle).lineLimit(2).padding(.horizontal, 8)
            }
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(6)
    }

    private func makeDragProvider(for item: ClipboardItem) -> NSItemProvider {
        switch item.type {
        case .text, .html, .rtf, .url, .color:
            return NSItemProvider(object: (item.textContent ?? item.urlString ?? item.colorHex ?? "") as NSString)
        case .image:
            if let data = item.imageData {
                let tmp = FileManager.default.temporaryDirectory
                    .appendingPathComponent("clip-\(item.id.uuidString).png")
                if !FileManager.default.fileExists(atPath: tmp.path) {
                    try? data.write(to: tmp)
                }
                if let provider = NSItemProvider(contentsOf: tmp) {
                    provider.suggestedName = "image.png"
                    return provider
                }
            }
            return NSItemProvider()
        case .file:
            if let path = item.filePaths?.first {
                let url = URL(fileURLWithPath: path)
                if FileManager.default.fileExists(atPath: path),
                   let provider = NSItemProvider(contentsOf: url) {
                    provider.suggestedName = url.lastPathComponent
                    return provider
                }
                return NSItemProvider(object: url as NSURL)
            }
            return NSItemProvider()
        }
    }

    private func moveSelection(by offset: Int, proxy: ScrollViewProxy) {
        let newIndex = max(0, min(items.count - 1, selectedIndex + offset))
        guard newIndex != selectedIndex else { return }
        selectedIndex = newIndex
        if !items.isEmpty {
            selectedItem = items[newIndex]
            proxy.scrollTo(items[newIndex].id)
        }
    }

    @ViewBuilder
    private func contextMenu(for item: ClipboardItem) -> some View {
        Button("Paste") { onPaste(item) }
        Divider()
        Button(item.isPinned ? "Unpin" : "Pin") { onPin(item) }
        Button(item.isFavorite ? "Unfavorite" : "Favorite") { onFavorite(item) }
        Divider()
        Button("Copy to Clipboard") { copyToClipboard(item) }
        if item.type == .url, let urlString = item.urlString, let url = URL(string: urlString) {
            Button("Open in Browser") { NSWorkspace.shared.open(url) }
        }
        if item.type == .text || item.type == .html || item.type == .rtf {
            Divider()
            Menu("Transform") {
                ForEach(TextTransformation.allCases, id: \.self) { transform in
                    Button(transform.displayName) {
                        applyTransform(transform, to: item)
                    }
                }
            }
        }
        Divider()
        Button("Delete", role: .destructive) { onDelete(item) }
    }

    private func copyToClipboard(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        if let text = item.textContent {
            pasteboard.setString(text, forType: .string)
        }
    }

    private func applyTransform(_ transform: TextTransformation, to item: ClipboardItem) {
        guard let text = item.textContent else { return }
        let result = transform.apply(to: text)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(result, forType: .string)
    }
}

struct ItemRowView: View {
    let item: ClipboardItem
    var isSelected: Bool = false
    var theme: ThemeColors

    var body: some View {
        HStack(spacing: 10) {
            itemIcon
                .frame(width: 32, height: 32)
                .background(theme.pillBackground)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(item.displayTitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(theme.textPrimary)
                        .lineLimit(1)

                    if item.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.orange)
                    }
                    if item.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.yellow)
                    }
                }

                HStack(spacing: 6) {
                    if let app = item.appName {
                        Text(app)
                            .font(.system(size: 10))
                            .foregroundColor(theme.textSecondary)
                    }
                    Text(item.createdAt.relative)
                        .font(.system(size: 10))
                        .foregroundColor(theme.textSecondary.opacity(0.7))
                    if item.type == .text, let count = item.characterCount {
                        Text("\(count) chars")
                            .font(.system(size: 10))
                            .foregroundColor(theme.textSecondary.opacity(0.7))
                    }
                }
            }

            Spacer()

            typeIndicator
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(isSelected ? theme.pillSelectedBackground : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    @ViewBuilder
    private var itemIcon: some View {
        switch item.type {
        case .text:
            Image(systemName: "doc.text")
                .foregroundColor(theme.accent)
        case .image:
            if let data = item.imageData, let image = NSImage(data: data) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "photo")
                    .foregroundColor(theme.accent)
            }
        case .file:
            Image(systemName: "doc")
                .foregroundColor(theme.accent)
        case .url:
            Image(systemName: "link")
                .foregroundColor(theme.accent)
        case .color:
            if let hex = item.colorHex {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: hex))
            } else {
                Image(systemName: "paintpalette")
                    .foregroundColor(theme.accent)
            }
        case .html:
            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .foregroundColor(theme.accent)
        case .rtf:
            Image(systemName: "doc.richtext")
                .foregroundColor(theme.accent)
        }
    }

    @ViewBuilder
    private var typeIndicator: some View {
        Text(item.type.rawValue.capitalized)
            .font(.system(size: 9, weight: .medium))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(theme.pillBackground)
            .clipShape(Capsule())
            .foregroundColor(theme.textSecondary)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        default:
            r = 0; g = 0; b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
}

extension Date {
    var relative: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
