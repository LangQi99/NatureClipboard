import Foundation

public enum AIProvider: String, Codable, CaseIterable, Sendable {
    case openai = "OpenAI"
    case anthropic = "Anthropic"
    case azureOpenAI = "Azure OpenAI"
    case ollama = "Ollama"
    case custom = "Custom (OpenAI-compatible)"
}

public struct AISettings: Codable, Equatable, Sendable {
    public var enabled: Bool
    public var provider: AIProvider
    public var baseURL: String
    public var model: String
    public var timeout: TimeInterval
    public var maxTokens: Int
    public var taggingEnabled: Bool
    public var summaryEnabled: Bool
    public var ocrEnabled: Bool
    public var llmVisionFallback: Bool
    public var urlEnrichmentEnabled: Bool
    public var triggerOnNewItem: Bool
    public var rateLimit: Int

    public init(
        enabled: Bool = false,
        provider: AIProvider = .openai,
        baseURL: String = "https://api.openai.com/v1",
        model: String = "gpt-4o-mini",
        timeout: TimeInterval = 15,
        maxTokens: Int = 128,
        taggingEnabled: Bool = true,
        summaryEnabled: Bool = false,
        ocrEnabled: Bool = true,
        llmVisionFallback: Bool = false,
        urlEnrichmentEnabled: Bool = true,
        triggerOnNewItem: Bool = true,
        rateLimit: Int = 30
    ) {
        self.enabled = enabled
        self.provider = provider
        self.baseURL = baseURL
        self.model = model
        self.timeout = timeout
        self.maxTokens = maxTokens
        self.taggingEnabled = taggingEnabled
        self.summaryEnabled = summaryEnabled
        self.ocrEnabled = ocrEnabled
        self.llmVisionFallback = llmVisionFallback
        self.urlEnrichmentEnabled = urlEnrichmentEnabled
        self.triggerOnNewItem = triggerOnNewItem
        self.rateLimit = rateLimit
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.enabled = try c.decodeIfPresent(Bool.self, forKey: .enabled) ?? false
        self.provider = try c.decodeIfPresent(AIProvider.self, forKey: .provider) ?? .openai
        self.baseURL = try c.decodeIfPresent(String.self, forKey: .baseURL) ?? "https://api.openai.com/v1"
        self.model = try c.decodeIfPresent(String.self, forKey: .model) ?? "gpt-4o-mini"
        self.timeout = try c.decodeIfPresent(TimeInterval.self, forKey: .timeout) ?? 15
        self.maxTokens = try c.decodeIfPresent(Int.self, forKey: .maxTokens) ?? 128
        self.taggingEnabled = try c.decodeIfPresent(Bool.self, forKey: .taggingEnabled) ?? true
        self.summaryEnabled = try c.decodeIfPresent(Bool.self, forKey: .summaryEnabled) ?? false
        self.ocrEnabled = try c.decodeIfPresent(Bool.self, forKey: .ocrEnabled) ?? true
        self.llmVisionFallback = try c.decodeIfPresent(Bool.self, forKey: .llmVisionFallback) ?? false
        self.urlEnrichmentEnabled = try c.decodeIfPresent(Bool.self, forKey: .urlEnrichmentEnabled) ?? true
        self.triggerOnNewItem = try c.decodeIfPresent(Bool.self, forKey: .triggerOnNewItem) ?? true
        self.rateLimit = try c.decodeIfPresent(Int.self, forKey: .rateLimit) ?? 30
    }
}

public enum AISettingsStore {
    private static let key = "aiSettings"

    public static func load() -> AISettings {
        guard let data = UserDefaults.standard.data(forKey: key),
              let settings = try? JSONDecoder().decode(AISettings.self, from: data) else {
            return AISettings()
        }
        return settings
    }

    public static func save(_ settings: AISettings) {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    public static func apiKey() -> String? {
        Keychain.load(key: "apiKey")
    }

    public static func setApiKey(_ value: String?) {
        if let value = value, !value.isEmpty {
            try? Keychain.save(key: "apiKey", value: value)
        } else {
            Keychain.delete(key: "apiKey")
        }
    }
}
