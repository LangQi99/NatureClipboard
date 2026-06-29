import SwiftUI

struct PreviewPanelView: View {
    let item: ClipboardItem?
    @EnvironmentObject var themeManager: ThemeManager

    var theme: ThemeColors { themeManager.colors }

    var body: some View {
        Group {
            if let item = item {
                VStack(alignment: .leading, spacing: 0) {
                    previewHeader(item)
                    Divider().opacity(0.3)
                    previewContent(item)
                    Divider().opacity(0.3)
                    informationSection(item)
                }
            } else {
                VStack {
                    Image(systemName: "sidebar.right")
                        .font(.system(size: 40))
                        .foregroundColor(theme.textSecondary.opacity(0.5))
                    Text("Select an item to preview")
                        .font(.system(size: 13))
                        .foregroundColor(theme.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(theme.cardBackground)
    }

    @ViewBuilder
    private func previewHeader(_ item: ClipboardItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    Label(item.type.rawValue.capitalized, systemImage: typeIcon(item.type))
                        .font(.system(size: 10))
                        .foregroundColor(theme.textSecondary)
                    if let app = item.appName {
                        Label(app, systemImage: "app")
                            .font(.system(size: 10))
                            .foregroundColor(theme.textSecondary)
                    }
                }
            }
            Spacer()
            actionButtons(item)
        }
        .padding(12)
    }

    @ViewBuilder
    private func actionButtons(_ item: ClipboardItem) -> some View {
        HStack(spacing: 6) {
            Button(action: {}) {
                Image(systemName: item.isPinned ? "pin.fill" : "pin")
                    .font(.system(size: 11))
                    .foregroundColor(theme.textSecondary)
            }
            .buttonStyle(.plain)

            Button(action: {}) {
                Image(systemName: item.isFavorite ? "star.fill" : "star")
                    .font(.system(size: 11))
                    .foregroundColor(theme.textSecondary)
            }
            .buttonStyle(.plain)

            Button(action: { copyItem(item) }) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 11))
                    .foregroundColor(theme.textSecondary)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func previewContent(_ item: ClipboardItem) -> some View {
        ScrollView {
            VStack(alignment: .leading) {
                switch item.type {
                case .text, .html, .rtf:
                    Text(item.textContent ?? "")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(theme.textPrimary)
                        .textSelection(.enabled)
                        .padding(12)
                case .image:
                    if let data = item.imageData, let image = NSImage(data: data) {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(12)
                    }
                case .url:
                    VStack(alignment: .leading, spacing: 8) {
                        if let urlString = item.urlString {
                            Link(urlString, destination: URL(string: urlString)!)
                                .font(.system(size: 12))
                        }
                    }
                    .padding(12)
                case .file:
                    VStack(alignment: .leading, spacing: 4) {
                        if let paths = item.filePaths {
                            ForEach(paths, id: \.self) { path in
                                HStack {
                                    Image(systemName: "doc")
                                        .foregroundColor(theme.accent)
                                    Text(path)
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundColor(theme.textPrimary)
                                }
                            }
                        }
                    }
                    .padding(12)
                case .color:
                    VStack(spacing: 12) {
                        if let hex = item.colorHex {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: hex))
                                .frame(height: 80)
                            Text(hex)
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(theme.textPrimary)
                                .textSelection(.enabled)
                        }
                    }
                    .padding(12)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func informationSection(_ item: ClipboardItem) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Information")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(theme.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 10)
                    .padding(.bottom, 6)

                sourceRow(item)
                infoRow(label: "Content type", value: contentTypeLabel(item))

                if item.type == .image {
                    infoRow(label: "Dimensions", value: item.imageSize)
                    if let data = item.imageData {
                        infoRow(label: "Image size", value: formatBytes(data.count))
                    }
                }
                if item.type == .text || item.type == .html || item.type == .rtf || item.type == .url {
                    if let count = item.characterCount {
                        infoRow(label: "Characters", value: "\(count)")
                    }
                    if let words = item.wordCount, item.type != .url {
                        infoRow(label: "Words", value: "\(words)")
                    }
                    if let text = item.textContent {
                        let lines = text.components(separatedBy: "\n").count
                        if lines > 1 {
                            infoRow(label: "Lines", value: "\(lines)")
                        }
                    }
                }
                if item.type == .file, let paths = item.filePaths {
                    if paths.count > 1 {
                        infoRow(label: "Files", value: "\(paths.count)")
                    }
                    if let first = paths.first {
                        infoRow(label: "Path", value: abbreviatePath(first))
                        if let size = fileSize(first) {
                            infoRow(label: "File size", value: size)
                        }
                    }
                }
                if item.type == .url, let urlString = item.urlString, let url = URL(string: urlString) {
                    if let host = url.host {
                        infoRow(label: "Host", value: host)
                    }
                }
                if item.type == .color, let hex = item.colorHex {
                    infoRow(label: "Hex", value: hex)
                }

                infoRow(label: "Copied", value: relativeDate(item.createdAt))
                if item.useCount > 0 {
                    infoRow(label: "Pasted", value: "\(item.useCount)×")
                }
            }
            .padding(.bottom, 10)
        }
    }

    @ViewBuilder
    private func sourceRow(_ item: ClipboardItem) -> some View {
        HStack(alignment: .center) {
            Text("Source")
                .font(.system(size: 11))
                .foregroundColor(theme.textSecondary)
            Spacer(minLength: 12)
            HStack(spacing: 5) {
                if let icon = appIcon(item) {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 16, height: 16)
                }
                Text(item.appName ?? "Unknown")
                    .font(.system(size: 11))
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }

    private func appIcon(_ item: ClipboardItem) -> NSImage? {
        if let bundleId = item.appBundleId,
           let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
            return NSWorkspace.shared.icon(forFile: url.path)
        }
        if let name = item.appName,
           let url = NSWorkspace.shared.urlForApplication(toOpen: URL(fileURLWithPath: "/") ) {
            _ = url
        }
        return nil
    }

    private func abbreviatePath(_ path: String) -> String {
        let home = NSHomeDirectory()
        if path.hasPrefix(home) {
            return "~" + path.dropFirst(home.count)
        }
        return path
    }

    private func fileSize(_ path: String) -> String? {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: path),
              let size = attrs[.size] as? Int else { return nil }
        return formatBytes(size)
    }

    @ViewBuilder
    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(theme.textSecondary)
            Spacer(minLength: 12)
            Text(value)
                .font(.system(size: 11))
                .foregroundColor(theme.textPrimary)
                .lineLimit(1)
                .truncationMode(.middle)
                .textSelection(.enabled)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }

    private func contentTypeLabel(_ item: ClipboardItem) -> String {
        switch item.type {
        case .text: return "Text"
        case .image: return "Image"
        case .file: return "File"
        case .url: return "URL"
        case .color: return "Color"
        case .html: return "Text (HTML)"
        case .rtf: return "Text (Formatted)"
        }
    }

    private func formatBytes(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }

    private func relativeDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let cal = Calendar.current
        if cal.isDateInToday(date) {
            formatter.dateFormat = "'Today at' HH:mm:ss"
        } else if cal.isDateInYesterday(date) {
            formatter.dateFormat = "'Yesterday at' HH:mm:ss"
        } else {
            formatter.dateFormat = "MMM d, yyyy HH:mm"
        }
        return formatter.string(from: date)
    }

    private func typeIcon(_ type: ClipboardItemType) -> String {
        switch type {
        case .text: return "doc.text"
        case .image: return "photo"
        case .file: return "folder"
        case .url: return "link"
        case .color: return "paintpalette"
        case .html: return "chevron.left.forwardslash.chevron.right"
        case .rtf: return "doc.richtext"
        }
    }

    private func copyItem(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        if let text = item.textContent {
            pasteboard.setString(text, forType: .string)
        } else if let data = item.imageData, let image = NSImage(data: data) {
            pasteboard.writeObjects([image])
        }
    }
}
