import SwiftUI

struct BottomBarView: View {
    let itemCount: Int
    @Binding var showingSnippets: Bool
    var onClearAll: () -> Void
    var onMerge: () -> Void
    @EnvironmentObject var themeManager: ThemeManager

    var theme: ThemeColors { themeManager.colors }

    var body: some View {
        HStack(spacing: 12) {
            Text("\(itemCount) items")
                .font(.system(size: 11))
                .foregroundColor(theme.textSecondary)

            Spacer()

            Button(action: onMerge) {
                Label("Merge", systemImage: "arrow.triangle.merge")
                    .font(.system(size: 11))
            }
            .buttonStyle(.plain)
            .foregroundColor(theme.textSecondary)

            Button(action: { showingSnippets = true }) {
                Label("Snippets", systemImage: "text.snippet")
                    .font(.system(size: 11))
            }
            .buttonStyle(.plain)
            .foregroundColor(theme.textSecondary)

            Button(action: onClearAll) {
                Label("Clear", systemImage: "trash")
                    .font(.system(size: 11))
            }
            .buttonStyle(.plain)
            .foregroundColor(theme.textSecondary)

            HStack(spacing: 4) {
                Image(systemName: "command")
                Image(systemName: "shift")
                Text("V")
            }
            .font(.system(size: 9))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(theme.pillBackground)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .foregroundColor(theme.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(theme.cardBackground)
    }
}
