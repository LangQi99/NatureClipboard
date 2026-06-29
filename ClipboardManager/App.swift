import SwiftUI

@main
struct ClipboardManagerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var clipboardStore = ClipboardStore.shared
    @StateObject private var settingsManager = SettingsManager.shared

    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(settingsManager)
                .environmentObject(clipboardStore)
        }
    }
}
