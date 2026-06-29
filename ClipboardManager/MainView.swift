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
        .tint(theme.accent)
        .accentColor(theme.accent)
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
        .onAppear {
            if selectedItem == nil, let first = store.filteredItems.first {
                selectedItem = first
            }
        }
        .onChange(of: store.filteredItems) { _, items in
            if selectedItem == nil || !items.contains(where: { $0.id == selectedItem?.id }) {
                selectedItem = items.first
            }
        }
    }

    private func pasteAndClose(_ item: ClipboardItem) {
        closeAction()
        store.pasteItem(item)
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
    private static let startTime = Date()

    private let canopyGreens: [Color] = [
        Color(red: 0.22, green: 0.45, blue: 0.22),
        Color(red: 0.32, green: 0.58, blue: 0.3),
        Color(red: 0.45, green: 0.7, blue: 0.38),
        Color(red: 0.58, green: 0.78, blue: 0.48),
        Color(red: 0.38, green: 0.62, blue: 0.32)
    ]

    var body: some View {
        TimelineView(.animation) { context in
            let elapsed = context.date.timeIntervalSince(Self.startTime)
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
                    .position(x: geo.size.width / 2, y: geo.size.height - 130)

                    fallingLeaves(in: geo.size, time: elapsed)
                    oxygenBubbles(in: geo.size, time: elapsed)
                }
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
    private func fallingLeaves(in size: CGSize, time: Double) -> some View {
        let xPositions: [CGFloat] = [0.96, 0.93, 0.89, 0.85, 0.81, 0.94, 0.87, 0.83]
        let yPhases: [Double] = [0.0, 0.13, 0.27, 0.4, 0.55, 0.68, 0.82, 0.92]
        let cycleDuration = 18.0
        ForEach(0..<8, id: \.self) { i in
            let seed = Double(i)
            let phase = (time / cycleDuration + yPhases[i]).truncatingRemainder(dividingBy: 1.0)
            let yPos = CGFloat(phase) * size.height
            let drift = sin(phase * .pi * 4 + seed) * 22
            let rotation = phase * 720 + seed * 45

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
                .position(x: xPositions[i] * size.width + drift, y: yPos)
        }
    }

    @ViewBuilder
    private func oxygenBubbles(in size: CGSize, time: Double) -> some View {
        let canopyCenterX = size.width / 2
        let canopyTopY = size.height - 230
        let emissions: [(CGFloat, CGFloat)] = [
            (canopyCenterX - 70, canopyTopY + 20),
            (canopyCenterX + 10, canopyTopY - 10),
            (canopyCenterX + 70, canopyTopY + 10),
            (canopyCenterX - 30, canopyTopY + 30),
            (canopyCenterX + 30, canopyTopY - 20),
            (canopyCenterX, canopyTopY - 40),
            (canopyCenterX - 90, canopyTopY + 40),
            (canopyCenterX + 90, canopyTopY + 30),
            (canopyCenterX + 50, canopyTopY + 50),
            (canopyCenterX - 50, canopyTopY - 10)
        ]
        let cycleDuration = 10.0
        ForEach(0..<emissions.count, id: \.self) { i in
            let seed = Double(i)
            let phaseOffset = Double(i) / Double(emissions.count)
            let progress = (time / cycleDuration + phaseOffset).truncatingRemainder(dividingBy: 1.0)
            let startY = emissions[i].1
            let endY: CGFloat = -30
            let yPos = startY + (endY - startY) * CGFloat(progress)
            let drift = sin(progress * .pi * 4 + seed) * 14
            let xPos = emissions[i].0 + drift
            let bubbleSize: CGFloat = 22 + CGFloat(i % 3) * 4
            let alpha = progress < 0.1 ? progress * 10 : (progress > 0.9 ? (1 - progress) * 10 : 1.0)

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: bubbleSize, height: bubbleSize)
                Circle()
                    .stroke(Color(red: 0.25, green: 0.55, blue: 0.3), lineWidth: 1.6)
                    .frame(width: bubbleSize, height: bubbleSize)
                Text("O₂")
                    .font(.system(size: bubbleSize * 0.42, weight: .semibold))
                    .foregroundColor(Color(red: 0.18, green: 0.45, blue: 0.22))
            }
            .opacity(alpha)
            .position(x: xPos, y: yPos)
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
