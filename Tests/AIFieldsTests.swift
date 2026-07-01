import Testing
import Foundation
@testable import ClipboardManagerKit

@Suite("AIFields") struct AIFieldsTests {
    // These types live in the app target too; here we test the Kit-side AIStatus + OCRLine + coding helpers.

    @Test func aiStatus_defaults_to_none() {
        let s = AIStatus.none
        #expect(s.rawValue == "none")
    }

    @Test func aiStatus_roundTripCodable() throws {
        let orig = AIFieldsSnapshot(
            aiTags: ["code", "swift"],
            aiSummary: "a short summary",
            aiModel: "gpt-4o-mini",
            aiStatus: .done,
            ocrText: "hello",
            ocrLines: [OCRLine(rect: CGRect(x: 0.1, y: 0.2, width: 0.3, height: 0.05), text: "hello")],
            urlTitle: "OpenAI",
            urlSiteName: "openai.com"
        )
        let data = try JSONEncoder().encode(orig)
        let back = try JSONDecoder().decode(AIFieldsSnapshot.self, from: data)
        #expect(back.aiTags == ["code", "swift"])
        #expect(back.aiStatus == .done)
        #expect(back.ocrLines?.first?.text == "hello")
        #expect(back.urlTitle == "OpenAI")
    }

    @Test func aiStatus_decodesUnknownAsNone() throws {
        let json = #"{"aiTags":[],"aiStatus":"weird"}"#.data(using: .utf8)!
        let snap = try JSONDecoder().decode(AIFieldsSnapshot.self, from: json)
        #expect(snap.aiStatus == .none)
    }

    @Test func aiFields_missingKeys_defaultToEmpty() throws {
        // simulate v1 payload without any AI keys
        let json = "{}".data(using: .utf8)!
        let snap = try JSONDecoder().decode(AIFieldsSnapshot.self, from: json)
        #expect(snap.aiTags.isEmpty)
        #expect(snap.aiSummary == nil)
        #expect(snap.aiModel == nil)
        #expect(snap.aiStatus == .none)
        #expect(snap.ocrText == nil)
        #expect(snap.ocrLines == nil)
        #expect(snap.urlTitle == nil)
        #expect(snap.urlSiteName == nil)
    }
}
