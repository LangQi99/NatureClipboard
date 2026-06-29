import SwiftUI

enum AppTheme: String, CaseIterable, Codable {
    case liquidGlass
    case nature

    var displayName: String {
        switch self {
        case .liquidGlass: return "Liquid Glass"
        case .nature: return "Nature"
        }
    }

    var icon: String {
        switch self {
        case .liquidGlass: return "drop.fill"
        case .nature: return "leaf.fill"
        }
    }
}

struct ThemeColors {
    let background: Color
    let panelBackground: Color
    let cardBackground: Color
    let accent: Color
    let accentSecondary: Color
    let textPrimary: Color
    let textSecondary: Color
    let border: Color
    let pillBackground: Color
    let pillSelectedBackground: Color
    let searchBarBackground: Color
    let shadowColor: Color
    let material: NSVisualEffectView.Material
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var currentTheme: AppTheme {
        didSet { UserDefaults.standard.set(currentTheme.rawValue, forKey: "appTheme") }
    }

    var colors: ThemeColors {
        switch currentTheme {
        case .liquidGlass: return Self.liquidGlassColors
        case .nature: return Self.natureColors
        }
    }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "appTheme") ?? "nature"
        currentTheme = AppTheme(rawValue: saved) ?? .nature
    }

    static let liquidGlassColors = ThemeColors(
        background: Color.clear,
        panelBackground: Color.white.opacity(0.08),
        cardBackground: Color.white.opacity(0.06),
        accent: Color(red: 0.4, green: 0.7, blue: 1.0),
        accentSecondary: Color(red: 0.6, green: 0.4, blue: 1.0),
        textPrimary: Color.white.opacity(0.95),
        textSecondary: Color.white.opacity(0.6),
        border: Color.white.opacity(0.15),
        pillBackground: Color.white.opacity(0.08),
        pillSelectedBackground: Color.white.opacity(0.2),
        searchBarBackground: Color.white.opacity(0.05),
        shadowColor: Color.black.opacity(0.3),
        material: .hudWindow
    )

    static let natureColors = ThemeColors(
        background: Color(red: 0.97, green: 0.98, blue: 0.95),
        panelBackground: Color(red: 0.98, green: 0.99, blue: 0.96),
        cardBackground: Color.white.opacity(0.9),
        accent: Color(red: 0.35, green: 0.62, blue: 0.38),
        accentSecondary: Color(red: 0.55, green: 0.78, blue: 0.5),
        textPrimary: Color(red: 0.22, green: 0.38, blue: 0.26),
        textSecondary: Color(red: 0.45, green: 0.58, blue: 0.48),
        border: Color(red: 0.5, green: 0.72, blue: 0.5).opacity(0.2),
        pillBackground: Color(red: 0.7, green: 0.85, blue: 0.65).opacity(0.18),
        pillSelectedBackground: Color(red: 0.45, green: 0.7, blue: 0.45).opacity(0.25),
        searchBarBackground: Color.white.opacity(0.7),
        shadowColor: Color(red: 0.3, green: 0.5, blue: 0.3).opacity(0.1),
        material: .sheet
    )
}
