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
                    previewFooter(item)
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
    private func previewFooter(_ item: ClipboardItem) -> some View {
        HStack(spacing: 12) {
            Label(item.createdAt.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                .font(.system(size: 10))
                .foregroundColor(theme.textSecondary)
            if item.useCount > 0 {
                Label("Used \(item.useCount)x", systemImage: "arrow.counterclockwise")
                    .font(.system(size: 10))
                    .foregroundColor(theme.textSecondary)
            }
            if let count = item.characterCount {
                Text("\(count) chars")
                    .font(.system(size: 10))
                    .foregroundColor(theme.textSecondary)
            }
            if let words = item.wordCount {
                Text("\(words) words")
                    .font(.system(size: 10))
                    .foregroundColor(theme.textSecondary)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
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
