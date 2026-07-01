import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var store: ClipboardStore

    var body: some View {
        TabView {
            GeneralSettingsView()
                .environmentObject(settings)
                .tabItem { Label("General", systemImage: "gear") }

            AppearanceSettingsView()
                .environmentObject(settings)
                .tabItem { Label("Appearance", systemImage: "paintbrush") }

            StorageSettingsView()
                .environmentObject(settings)
                .environmentObject(store)
                .tabItem { Label("Storage", systemImage: "internaldrive") }

            ExclusionsSettingsView()
                .environmentObject(settings)
                .tabItem { Label("Exclusions", systemImage: "nosign") }

            AISettingsView()
                .tabItem { Label("AI", systemImage: "brain") }
        }
        .frame(width: 500, height: 450)
    }
}

struct GeneralSettingsView: View {
    @EnvironmentObject var settings: SettingsManager

    var body: some View {
        Form {
            Toggle("Launch at login", isOn: $settings.launchAtLogin)
            Toggle("Show in menu bar", isOn: $settings.showInMenuBar)
            Toggle("Play sound on copy", isOn: $settings.playSoundOnCopy)
            Toggle("Show notification on copy", isOn: $settings.showNotificationOnCopy)
            Toggle("Clear history on quit", isOn: $settings.clearOnQuit)
            Toggle("Ignore transient clipboard content", isOn: $settings.ignoreTransientContent)

            Section("History") {
                Stepper("Max items: \(settings.maxHistoryCount)", value: $settings.maxHistoryCount, in: 100...50000, step: 500)
            }

            Section("Shortcut") {
                Text("Global shortcut: ⌘E")
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct AppearanceSettingsView: View {
    @EnvironmentObject var settings: SettingsManager

    var body: some View {
        Form {
            Picker("Appearance", selection: $settings.appearanceMode) {
                ForEach(SettingsManager.AppearanceMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue.capitalized).tag(mode)
                }
            }

            Toggle("Show preview panel", isOn: $settings.previewEnabled)

            Section("Window Size") {
                HStack {
                    Text("Width:")
                    Slider(value: $settings.windowWidth, in: 600...1200, step: 50)
                    Text("\(Int(settings.windowWidth))")
                }
                HStack {
                    Text("Height:")
                    Slider(value: $settings.windowHeight, in: 400...800, step: 50)
                    Text("\(Int(settings.windowHeight))")
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct StorageSettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var store: ClipboardStore

    var body: some View {
        Form {
            Section("Statistics") {
                LabeledContent("Total items", value: "\(store.items.count)")
                LabeledContent("Pinned items", value: "\(store.items.filter(\.isPinned).count)")
                LabeledContent("Favorites", value: "\(store.items.filter(\.isFavorite).count)")
                LabeledContent("Snippets", value: "\(store.snippets.count)")
            }

            Section("Actions") {
                Button("Clear All History") { store.clearAll() }
                Button("Export History...") { exportHistory() }
                Button("Import History...") { importHistory() }
            }
        }
        .formStyle(.grouped)
        .padding()
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

    private func importHistory() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        if panel.runModal() == .OK, let url = panel.url {
            if let data = try? Data(contentsOf: url),
               let items = try? JSONDecoder().decode([ClipboardItem].self, from: data) {
                for item in items {
                    store.addItem(item)
                }
            }
        }
    }
}

struct ExclusionsSettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    @State private var newApp = ""

    var body: some View {
        Form {
            Section("Ignored Applications") {
                ForEach(settings.ignoredApps, id: \.self) { app in
                    HStack {
                        Text(app)
                        Spacer()
                        Button(action: { settings.ignoredApps.removeAll { $0 == app } }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
                HStack {
                    TextField("Bundle ID or App Name", text: $newApp)
                    Button("Add") {
                        if !newApp.isEmpty {
                            settings.ignoredApps.append(newApp)
                            newApp = ""
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
