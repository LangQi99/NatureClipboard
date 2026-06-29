import Foundation
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    @Published var maxHistoryCount: Int {
        didSet { UserDefaults.standard.set(maxHistoryCount, forKey: "maxHistoryCount") }
    }
    @Published var launchAtLogin: Bool {
        didSet { UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin") }
    }
    @Published var showInMenuBar: Bool {
        didSet { UserDefaults.standard.set(showInMenuBar, forKey: "showInMenuBar") }
    }
    @Published var playSoundOnCopy: Bool {
        didSet { UserDefaults.standard.set(playSoundOnCopy, forKey: "playSoundOnCopy") }
    }
    @Published var showNotificationOnCopy: Bool {
        didSet { UserDefaults.standard.set(showNotificationOnCopy, forKey: "showNotificationOnCopy") }
    }
    @Published var ignoreTransientContent: Bool {
        didSet { UserDefaults.standard.set(ignoreTransientContent, forKey: "ignoreTransientContent") }
    }
    @Published var clearOnQuit: Bool {
        didSet { UserDefaults.standard.set(clearOnQuit, forKey: "clearOnQuit") }
    }
    @Published var ignoredApps: [String] {
        didSet { UserDefaults.standard.set(ignoredApps, forKey: "ignoredApps") }
    }
    @Published var appearanceMode: AppearanceMode {
        didSet { UserDefaults.standard.set(appearanceMode.rawValue, forKey: "appearanceMode") }
    }
    @Published var windowWidth: CGFloat {
        didSet { UserDefaults.standard.set(windowWidth, forKey: "windowWidth") }
    }
    @Published var windowHeight: CGFloat {
        didSet { UserDefaults.standard.set(windowHeight, forKey: "windowHeight") }
    }
    @Published var previewEnabled: Bool {
        didSet { UserDefaults.standard.set(previewEnabled, forKey: "previewEnabled") }
    }

    enum AppearanceMode: String, CaseIterable {
        case system, light, dark
    }

    private init() {
        let defaults = UserDefaults.standard
        maxHistoryCount = defaults.object(forKey: "maxHistoryCount") as? Int ?? 5000
        launchAtLogin = defaults.bool(forKey: "launchAtLogin")
        showInMenuBar = defaults.object(forKey: "showInMenuBar") as? Bool ?? true
        playSoundOnCopy = defaults.bool(forKey: "playSoundOnCopy")
        showNotificationOnCopy = defaults.bool(forKey: "showNotificationOnCopy")
        ignoreTransientContent = defaults.object(forKey: "ignoreTransientContent") as? Bool ?? true
        clearOnQuit = defaults.bool(forKey: "clearOnQuit")
        ignoredApps = defaults.stringArray(forKey: "ignoredApps") ?? []
        appearanceMode = AppearanceMode(rawValue: defaults.string(forKey: "appearanceMode") ?? "system") ?? .system
        windowWidth = defaults.object(forKey: "windowWidth") as? CGFloat ?? 750
        windowHeight = defaults.object(forKey: "windowHeight") as? CGFloat ?? 500
        previewEnabled = defaults.object(forKey: "previewEnabled") as? Bool ?? true
    }
}
