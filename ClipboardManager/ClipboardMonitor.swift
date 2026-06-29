import Foundation
import AppKit
import Combine

class ClipboardMonitor: ObservableObject {
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let pasteboard = NSPasteboard.general
    var onNewItem: ((ClipboardItem) -> Void)?
    @Published var isMonitoring = true

    func start() {
        lastChangeCount = pasteboard.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForChanges()
        }
        isMonitoring = true
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isMonitoring = false
    }

    func pause() {
        isMonitoring = false
    }

    func resume() {
        isMonitoring = true
    }

    private func checkForChanges() {
        guard isMonitoring else { return }
        let currentCount = pasteboard.changeCount
        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        if let item = captureClipboard() {
            DispatchQueue.main.async { [weak self] in
                self?.onNewItem?(item)
            }
        }
    }

    private func captureClipboard() -> ClipboardItem? {
        let frontApp = NSWorkspace.shared.frontmostApplication
        let appName = frontApp?.localizedName
        let bundleId = frontApp?.bundleIdentifier

        if let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL], !urls.isEmpty {
            let fileURLs = urls.filter { $0.isFileURL }
            if !fileURLs.isEmpty {
                return ClipboardItem(type: .file, filePaths: fileURLs.map { $0.path },
                                    appName: appName, appBundleId: bundleId)
            }
            if let urlString = urls.first?.absoluteString {
                return ClipboardItem(type: .url, textContent: urlString, urlString: urlString,
                                    appName: appName, appBundleId: bundleId)
            }
        }

        if let image = NSImage(pasteboard: pasteboard) {
            if let tiff = image.tiffRepresentation,
               let bitmap = NSBitmapImageRep(data: tiff),
               let pngData = bitmap.representation(using: .png, properties: [:]) {
                return ClipboardItem(type: .image, imageData: pngData,
                                    appName: appName, appBundleId: bundleId)
            }
        }

        if let colorData = pasteboard.data(forType: .color) {
            if let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: colorData) {
                let hex = String(format: "#%02X%02X%02X",
                    Int(color.redComponent * 255),
                    Int(color.greenComponent * 255),
                    Int(color.blueComponent * 255))
                return ClipboardItem(type: .color, textContent: hex, colorHex: hex,
                                    appName: appName, appBundleId: bundleId)
            }
        }

        if let rtfData = pasteboard.data(forType: .rtf) {
            let plainText = pasteboard.string(forType: .string)
            let html = pasteboard.string(forType: .html)
            return ClipboardItem(type: .rtf, textContent: plainText, htmlContent: html, rtfData: rtfData,
                                appName: appName, appBundleId: bundleId)
        }

        if let html = pasteboard.string(forType: .html) {
            let plainText = pasteboard.string(forType: .string)
            if let text = plainText, !text.isEmpty {
                return ClipboardItem(type: .rtf, textContent: text, htmlContent: html,
                                    appName: appName, appBundleId: bundleId)
            }
            return ClipboardItem(type: .html, textContent: plainText, htmlContent: html,
                                appName: appName, appBundleId: bundleId)
        }

        if let text = pasteboard.string(forType: .string) {
            if text.hasPrefix("http://") || text.hasPrefix("https://") {
                return ClipboardItem(type: .url, textContent: text, urlString: text,
                                    appName: appName, appBundleId: bundleId)
            }
            return ClipboardItem(type: .text, textContent: text,
                                appName: appName, appBundleId: bundleId)
        }

        return nil
    }
}
