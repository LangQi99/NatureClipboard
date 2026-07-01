import Testing
import Foundation
@testable import ClipboardManagerKit

@Suite("AISettings") struct AISettingsTests {
    @Test func defaults_allExpectedValues() {
        let s = AISettings()
        #expect(s.enabled == false)
        #expect(s.provider == .openai)
        #expect(s.baseURL == "https://api.openai.com/v1")
        #expect(s.model == "gpt-4o-mini")
        #expect(s.timeout == 15)
        #expect(s.maxTokens == 128)
        #expect(s.taggingEnabled == true)
        #expect(s.summaryEnabled == false)
        #expect(s.ocrEnabled == true)
        #expect(s.llmVisionFallback == false)
        #expect(s.urlEnrichmentEnabled == true)
        #expect(s.triggerOnNewItem == true)
        #expect(s.rateLimit == 30)
    }

    @Test func codable_roundTrip() throws {
        var s = AISettings()
        s.enabled = true
        s.provider = .ollama
        s.baseURL = "http://localhost:11434/v1"
        s.model = "qwen2.5:7b"
        s.rateLimit = 10
        let data = try JSONEncoder().encode(s)
        let back = try JSONDecoder().decode(AISettings.self, from: data)
        #expect(back == s)
    }

    @Test func codable_missingFields_fallsBackToDefaults() throws {
        let json = #"{"enabled":true}"#.data(using: .utf8)!
        let s = try JSONDecoder().decode(AISettings.self, from: json)
        #expect(s.enabled == true)
        #expect(s.provider == .openai)
        #expect(s.model == "gpt-4o-mini")
    }

    @Test func provider_allCases() {
        #expect(AIProvider.allCases.count == 5)
    }
}
