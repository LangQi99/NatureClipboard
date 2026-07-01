import Testing
import Foundation
@testable import ClipboardManagerKit

@Suite("Highlighter") struct HighlighterTests {
    private func rangesToStrings(_ text: String, _ ranges: [Range<String.Index>]) -> [String] {
        ranges.map { String(text[$0]) }
    }

    @Test func matches_emptyQuery_returnsEmpty() {
        let ranges = Highlighter.matches(text: "hello world", query: "")
        #expect(ranges.isEmpty)
    }

    @Test func matches_singleTerm_case_insensitive() {
        let text = "Hello World"
        let ranges = Highlighter.matches(text: text, query: "hello")
        #expect(rangesToStrings(text, ranges) == ["Hello"])
    }

    @Test func matches_multipleOccurrences() {
        let text = "foo bar foo baz foo"
        let ranges = Highlighter.matches(text: text, query: "foo")
        #expect(ranges.count == 3)
    }

    @Test func matches_multipleTerms_spaceSeparated() {
        let text = "The quick brown fox"
        let ranges = Highlighter.matches(text: text, query: "quick fox")
        let strings = rangesToStrings(text, ranges)
        #expect(strings.contains("quick"))
        #expect(strings.contains("fox"))
    }

    @Test func matches_ignoresBlankTermInQuery() {
        let text = "hello world"
        let ranges = Highlighter.matches(text: text, query: "   hello   ")
        #expect(rangesToStrings(text, ranges) == ["hello"])
    }

    @Test func matches_chinese() {
        let text = "这是一段中文文本"
        let ranges = Highlighter.matches(text: text, query: "中文")
        #expect(rangesToStrings(text, ranges) == ["中文"])
    }

    @Test func matches_emoji() {
        let text = "hello 🌱 world"
        let ranges = Highlighter.matches(text: text, query: "🌱")
        #expect(rangesToStrings(text, ranges) == ["🌱"])
    }

    @Test func matches_notFound_returnsEmpty() {
        #expect(Highlighter.matches(text: "hello", query: "xyz").isEmpty)
    }

    @Test func matches_overlappingTerms_dedupOrdered() {
        // "abab" 里查询 "ab" 应该给两个不重叠命中
        let text = "abab"
        let ranges = Highlighter.matches(text: text, query: "ab")
        #expect(ranges.count == 2)
    }
}
