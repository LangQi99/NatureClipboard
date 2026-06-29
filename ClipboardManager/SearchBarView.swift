import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    var closeAction: () -> Void
    var onSubmit: () -> Void = {}
    @EnvironmentObject var themeManager: ThemeManager
    @FocusState private var isFocused: Bool

    var theme: ThemeColors { themeManager.colors }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(theme.textSecondary)
                .font(.system(size: 16))

            TextField("Search clipboard history...", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 15))
                .foregroundColor(theme.textPrimary)
                .focused($isFocused)
                .onSubmit(onSubmit)

            if !searchText.isEmpty {
                Button(action: { withAnimation(.easeOut(duration: 0.15)) { searchText = "" } }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(theme.textSecondary)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }

            ThemeSwitcherView()
                .environmentObject(themeManager)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            WindowDragView()
                .background(theme.searchBarBackground)
        )
        .onAppear { isFocused = true }
        .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
    }
}

struct WindowDragView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        return WindowDragNSView()
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

class WindowDragNSView: NSView {
    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }
}

struct ThemeSwitcherView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Menu {
            ForEach(AppTheme.allCases, id: \.self) { t in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        themeManager.currentTheme = t
                    }
                }) {
                    Label(t.displayName, systemImage: t.icon)
                }
            }
        } label: {
            Image(systemName: themeManager.currentTheme.icon)
                .font(.system(size: 12))
                .foregroundColor(themeManager.colors.textSecondary)
                .frame(width: 24, height: 24)
                .background(themeManager.colors.pillBackground)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

struct CategoryBarView: View {
    @Binding var selectedCategory: ClipboardCategory
    @EnvironmentObject var themeManager: ThemeManager

    var theme: ThemeColors { themeManager.colors }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(ClipboardCategory.allCases, id: \.self) { category in
                    CategoryPill(category: category, isSelected: selectedCategory == category, theme: theme)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                selectedCategory = category
                            }
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }
}

struct CategoryPill: View {
    let category: ClipboardCategory
    let isSelected: Bool
    let theme: ThemeColors

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.icon)
                .font(.system(size: 10))
            Text(category.displayName)
                .font(.system(size: 11, weight: .medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(isSelected ? theme.pillSelectedBackground : theme.pillBackground)
        .foregroundColor(isSelected ? theme.accent : theme.textSecondary)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(isSelected ? theme.accent.opacity(0.5) : theme.border, lineWidth: 0.5))
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isSelected)
    }
}
