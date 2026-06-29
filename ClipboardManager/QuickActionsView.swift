import SwiftUI

struct QuickActionsView: View {
    @EnvironmentObject var store: ClipboardStore
    @Binding var searchText: String
    let closeAction: () -> Void

    var matchingActions: [QuickAction] {
        if searchText.isEmpty { return [] }
        return QuickAction.allActions.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.keywords.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
        }
    }

    var body: some View {
        if !matchingActions.isEmpty {
            VStack(alignment: .leading, spacing: 2) {
                Text("ACTIONS")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)

                ForEach(matchingActions) { action in
                    Button(action: { executeAction(action) }) {
                        HStack(spacing: 8) {
                            Image(systemName: action.icon)
                                .font(.system(size: 12))
                                .frame(width: 20)
                                .foregroundColor(.accentColor)
                            Text(action.name)
                                .font(.system(size: 12))
                            Spacer()
                            if let shortcut = action.shortcut {
                                Text(shortcut)
                                    .font(.system(size: 9))
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 3))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 4)
            Divider()
        }
    }

    private func executeAction(_ action: QuickAction) {
        switch action.id {
        case "clear_all":
            store.clearAll()
        case "clear_text":
            store.items.removeAll { $0.type == .text }
        case "clear_images":
            store.items.removeAll { $0.type == .image }
        case "export":
            exportHistory()
        case "toggle_monitor":
            break
        default:
            break
        }
        searchText = ""
        closeAction()
    }

    private func exportHistory() {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "clipboard_history.json"
        panel.allowedContentTypes = [.json]
        if panel.runModal() == .OK, let url = panel.url {
            if let data = try? JSONEncoder().encode(store.items) {
                try? data.write(to: url)
            }
        }
    }
}

struct QuickAction: Identifiable {
    let id: String
    let name: String
    let icon: String
    let keywords: [String]
    let shortcut: String?

    static let allActions: [QuickAction] = [
        QuickAction(id: "clear_all", name: "Clear All History", icon: "trash", keywords: ["clear", "delete", "remove", "history"], shortcut: "⌘⌫"),
        QuickAction(id: "clear_text", name: "Clear Text Items", icon: "doc.text", keywords: ["clear", "text", "remove"], shortcut: nil),
        QuickAction(id: "clear_images", name: "Clear Image Items", icon: "photo", keywords: ["clear", "images", "remove"], shortcut: nil),
        QuickAction(id: "export", name: "Export History", icon: "square.and.arrow.up", keywords: ["export", "save", "backup", "json"], shortcut: "⌘E"),
        QuickAction(id: "toggle_monitor", name: "Toggle Monitoring", icon: "pause.circle", keywords: ["pause", "stop", "monitor", "toggle"], shortcut: "⌘P"),
    ]
}
