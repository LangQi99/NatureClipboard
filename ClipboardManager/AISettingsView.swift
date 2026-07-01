import SwiftUI
import ClipboardManagerKit

struct AISettingsView: View {
    @State private var settings = AISettingsStore.load()
    @State private var apiKeyInput = AISettingsStore.apiKey() ?? ""
    @State private var showFirstTimeAlert = false
    @State private var testResult: String?

    var body: some View {
        Form {
            Section {
                Toggle("Enable AI features", isOn: $settings.enabled)
                    .onChange(of: settings.enabled) { _, newValue in
                        if newValue { showFirstTimeAlert = true }
                        save()
                    }
            }

            if settings.enabled {
                Section("Provider") {
                    Picker("Provider", selection: $settings.provider) {
                        ForEach(AIProvider.allCases, id: \.self) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    .onChange(of: settings.provider) { _, _ in save() }

                    TextField("Base URL", text: $settings.baseURL)
                        .onSubmit { save() }

                    HStack {
                        SecureField("API Key", text: $apiKeyInput)
                        Button("Save") {
                            AISettingsStore.setApiKey(apiKeyInput)
                        }
                    }

                    TextField("Model", text: $settings.model)
                        .onSubmit { save() }

                    Stepper("Timeout: \(Int(settings.timeout))s", value: $settings.timeout, in: 5...60, step: 5)
                        .onChange(of: settings.timeout) { _, _ in save() }

                    Stepper("Max tokens: \(settings.maxTokens)", value: $settings.maxTokens, in: 64...2048, step: 64)
                        .onChange(of: settings.maxTokens) { _, _ in save() }
                }

                Section("Features") {
                    Toggle("Tagging", isOn: $settings.taggingEnabled)
                    Toggle("Summary", isOn: $settings.summaryEnabled)
                    Toggle("OCR (local Vision)", isOn: $settings.ocrEnabled)
                    Toggle("LLM Vision Fallback (sends images)", isOn: $settings.llmVisionFallback)
                    Toggle("URL Enrichment", isOn: $settings.urlEnrichmentEnabled)
                }
                .onChange(of: settings.taggingEnabled) { _, _ in save() }
                .onChange(of: settings.summaryEnabled) { _, _ in save() }
                .onChange(of: settings.ocrEnabled) { _, _ in save() }
                .onChange(of: settings.llmVisionFallback) { _, _ in save() }
                .onChange(of: settings.urlEnrichmentEnabled) { _, _ in save() }

                Section("Trigger") {
                    Picker("Mode", selection: $settings.triggerOnNewItem) {
                        Text("On new item").tag(true)
                        Text("Manual only").tag(false)
                    }
                    .onChange(of: settings.triggerOnNewItem) { _, _ in save() }

                    Stepper("Rate limit: \(settings.rateLimit)/min", value: $settings.rateLimit, in: 1...120)
                        .onChange(of: settings.rateLimit) { _, _ in save() }
                }

                Section("Diagnostics") {
                    Button("Test Connection") { testConnection() }
                    if let result = testResult {
                        Text(result)
                            .font(.system(size: 11))
                            .foregroundColor(result.hasPrefix("OK") ? .green : .red)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .alert("Enable AI Features?", isPresented: $showFirstTimeAlert) {
            Button("Enable") { }
            Button("Cancel", role: .cancel) {
                settings.enabled = false
                save()
            }
        } message: {
            Text("Clipboard text content will be sent to your configured Provider (default: OpenAI). Images use local Vision by default. You can disable this anytime.")
        }
    }

    private func save() {
        AISettingsStore.save(settings)
    }

    private func testConnection() {
        testResult = "Testing..."
        let key = AISettingsStore.apiKey() ?? ""
        guard !key.isEmpty else { testResult = "Error: No API key"; return }
        var request = URLRequest(url: URL(string: settings.baseURL + "/models")!)
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = settings.timeout
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    testResult = "Error: \(error.localizedDescription)"
                } else if let http = response as? HTTPURLResponse {
                    testResult = http.statusCode == 200 ? "OK (connected)" : "Error: HTTP \(http.statusCode)"
                }
            }
        }.resume()
    }
}
