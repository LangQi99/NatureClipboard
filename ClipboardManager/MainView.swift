import SwiftUI

struct MainView: View {
    @StateObject private var store = ClipboardStore.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedItem: ClipboardItem?
    @State private var showingSnippets = false
    @State private var selectedItems: Set<ClipboardItem> = []
    @State private var appeared = false
    var closeAction: () -> Void

    var theme: ThemeColors { themeManager.colors }

    var body: some View {
        VStack(spacing: 0) {
            SearchBarView(searchText: $store.searchText, closeAction: closeAction, onSubmit: {
                let target = selectedItem ?? store.filteredItems.first
                if let item = target {
                    pasteAndClose(item)
                }
            })
                .environmentObject(themeManager)
            CategoryBarView(selectedCategory: $store.selectedCategory)
                .environmentObject(themeManager)
            Divider().opacity(0.3)

            QuickActionsView(searchText: $store.searchText, closeAction: closeAction)
                .environmentObject(store)
                .environmentObject(themeManager)

            HSplitView {
                ItemListView(
                    items: store.filteredItems,
                    selectedItem: $selectedItem,
                    selectedItems: $selectedItems,
                    onPaste: { item in pasteAndClose(item) },
                    onDelete: { store.deleteItem($0) },
                    onPin: { store.togglePin($0) },
                    onFavorite: { store.toggleFavorite($0) }
                )
                .environmentObject(themeManager)
                .frame(minWidth: 350, idealWidth: 400)

                if SettingsManager.shared.previewEnabled {
                    PreviewPanelView(item: selectedItem)
                        .environmentObject(themeManager)
                        .frame(minWidth: 250, idealWidth: 350)
                }
            }

            BottomBarView(
                itemCount: store.filteredItems.count,
                showingSnippets: $showingSnippets,
                onClearAll: { store.clearAll() },
                onMerge: {
                    let merged = store.mergeItems(Array(selectedItems))
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(merged, forType: .string)
                }
            )
            .environmentObject(themeManager)
        }
        .frame(width: 750, height: 500)
        .background(panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(theme.border, lineWidth: 1)
        )
        .shadow(color: theme.shadowColor, radius: 20, x: 0, y: 10)
        .scaleEffect(appeared ? 1.0 : 0.97)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                appeared = true
            }
        }
        .sheet(isPresented: $showingSnippets) {
            SnippetsView()
                .environmentObject(store)
        }
    }

    private func pasteAndClose(_ item: ClipboardItem) {
        closeAction()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            store.pasteItem(item)
        }
    }

    @ViewBuilder
    private var panelBackground: some View {
        switch themeManager.currentTheme {
        case .liquidGlass:
            ZStack {
                VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                Color.black.opacity(0.2)
                LinearGradient(
                    colors: [Color.white.opacity(0.08), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        case .nature:
            NatureBackground()
        }
    }
}

struct NatureBackground: View {
    @State private var leafPhase: CGFloat = 0
    @State private var bubblePhase: CGFloat = 0

    private let canopyGreens: [Color] = [
        Color(red: 0.22, green: 0.45, blue: 0.22),
        Color(red: 0.32, green: 0.58, blue: 0.3),
        Color(red: 0.45, green: 0.7, blue: 0.38),
        Color(red: 0.58, green: 0.78, blue: 0.48),
        Color(red: 0.38, green: 0.62, blue: 0.32)
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 0.975, green: 0.985, blue: 0.96)

                RoundedRectangle(cornerRadius: 0)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.48, green: 0.72, blue: 0.4),
                                Color(red: 0.38, green: 0.62, blue: 0.32)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 42)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                ZStack {
                    Capsule()
                        .fill(Color(red: 0.45, green: 0.32, blue: 0.22))
                        .frame(width: 12, height: 200)
                        .offset(y: 30)

                    Capsule()
                        .fill(Color(red: 0.4, green: 0.28, blue: 0.2))
                        .frame(width: 7, height: 110)
                        .rotationEffect(.degrees(-22))
                        .offset(x: -35, y: -25)

                    Capsule()
                        .fill(Color(red: 0.4, green: 0.28, blue: 0.2))
                        .frame(width: 6, height: 90)
                        .rotationEffect(.degrees(18))
                        .offset(x: 28, y: -35)

                    canopyShape
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .bottomTrailing)
                .offset(x: -20, y: -40)

                fallingLeaves(in: geo.size)

                oxygenBubbles(in: geo.size)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                leafPhase = 1
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                bubblePhase = 1
            }
        }
    }

    @ViewBuilder
    private var canopyShape: some View {
        ZStack {
            Circle().fill(canopyGreens[0]).frame(width: 130).offset(x: -55, y: -25)
            Circle().fill(canopyGreens[1]).frame(width: 150).offset(x: 40, y: -55)
            Circle().fill(canopyGreens[2]).frame(width: 175).offset(x: 0, y: -90)
            Circle().fill(canopyGreens[3]).frame(width: 110).offset(x: 70, y: -100)
            Circle().fill(canopyGreens[4]).frame(width: 95).offset(x: -75, y: -85)
            Circle().fill(canopyGreens[1]).frame(width: 85).offset(x: -25, y: -130)
        }
        .offset(y: -50)
    }

    @ViewBuilder
    private func fallingLeaves(in size: CGSize) -> some View {
        ForEach(0..<14, id: \.self) { i in
            let seed = Double(i)
            let xPos = CGFloat((seed * 73).truncatingRemainder(dividingBy: 1.0)) * size.width
            let baseY = CGFloat((seed * 37).truncatingRemainder(dividingBy: 1.0)) * size.height
            let drift = sin(leafPhase * .pi * 2 + seed) * 30
            let yOffset = (leafPhase * size.height * 0.6 + baseY).truncatingRemainder(dividingBy: size.height)
            let rotation = leafPhase * 360 + seed * 45

            Image(systemName: "leaf.fill")
                .font(.system(size: CGFloat(11 + (i % 4) * 4)))
                .foregroundStyle(
                    [
                        Color(red: 0.28, green: 0.55, blue: 0.28),
                        Color(red: 0.4, green: 0.68, blue: 0.32),
                        Color(red: 0.55, green: 0.78, blue: 0.35)
                    ][i % 3]
                )
                .rotationEffect(.degrees(rotation))
                .position(x: xPos + drift, y: yOffset)
        }
    }

    @ViewBuilder
    private func oxygenBubbles(in size: CGSize) -> some View {
        ForEach(0..<6, id: \.self) { i in
            let seed = Double(i)
            let xPos = CGFloat((seed * 91).truncatingRemainder(dividingBy: 1.0)) * size.width * 0.8 + size.width * 0.1
            let baseY = size.height - (CGFloat(bubblePhase) * size.height + CGFloat(seed * 80))
                .truncatingRemainder(dividingBy: size.height + 100)
            let drift = sin(bubblePhase * .pi * 2 + seed) * 12
            let bubbleSize: CGFloat = 22 + CGFloat(i % 3) * 4

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: bubbleSize, height: bubbleSize)
                Circle()
                    .stroke(Color(red: 0.35, green: 0.65, blue: 0.4), lineWidth: 1.6)
                    .frame(width: bubbleSize, height: bubbleSize)
                Text("O₂")
                    .font(.system(size: bubbleSize * 0.42, weight: .semibold))
                    .foregroundColor(Color(red: 0.32, green: 0.6, blue: 0.38))
            }
            .position(x: xPos + drift, y: baseY)
        }
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.wantsLayer = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
