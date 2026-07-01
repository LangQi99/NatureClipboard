import Testing
@testable import ClipboardManagerKit

@Suite("AIPipeline") struct AIPipelineTests {
    @Test func url_yieldsUrlTagAndDone() {
        let result = AIPipeline.heuristicTag(text: "https://github.com/openai/openai-python")
        #expect(result.tags.contains("url"))
        #expect(result.status == .done)
    }

    @Test func plainShortWord_yieldsEmptyAndNone() {
        let result = AIPipeline.heuristicTag(text: "hello")
        #expect(result.tags.isEmpty)
        #expect(result.status == .none)
    }

    @Test func sql_yieldsSqlTagAndDone() {
        let result = AIPipeline.heuristicTag(text: "SELECT id, name FROM users WHERE age > 18")
        #expect(result.tags.contains("sql"))
        #expect(result.status == .done)
    }
}
