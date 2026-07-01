import Testing
import Foundation
@testable import ClipboardManagerKit

@Suite("TagResponseParser") struct TagResponseParserTests {
    @Test func validJSON_parsesCorrectly() throws {
        let json = #"{"tags":["code","swift"],"summary":"A Swift function"}"#
        let result = try TagResponseParser.parse(json)
        #expect(result.tags == ["code", "swift"])
        #expect(result.summary == "A Swift function")
    }

    @Test func emptyTags_returnsEmpty() throws {
        let json = #"{"tags":[],"summary":"nothing"}"#
        let result = try TagResponseParser.parse(json)
        #expect(result.tags.isEmpty)
        #expect(result.summary == "nothing")
    }

    @Test func missingSummary_defaultsToNil() throws {
        let json = #"{"tags":["url"]}"#
        let result = try TagResponseParser.parse(json)
        #expect(result.tags == ["url"])
        #expect(result.summary == nil)
    }

    @Test func trailingComma_lenientParse() throws {
        let json = #"{"tags":["code",],"summary":"x",}"#
        let result = try TagResponseParser.parse(json)
        #expect(result.tags.contains("code"))
    }

    @Test func wrappedInCodeFence_extractsJSON() throws {
        let raw = "```json\n{\"tags\":[\"sql\"],\"summary\":\"query\"}\n```"
        let result = try TagResponseParser.parse(raw)
        #expect(result.tags == ["sql"])
    }

    @Test func invalidJSON_throws() {
        #expect(throws: TagParseError.self) {
            try TagResponseParser.parse("not json at all")
        }
    }

    @Test func tagsExceedMax5_truncated() throws {
        let json = #"{"tags":["a","b","c","d","e","f","g"],"summary":"x"}"#
        let result = try TagResponseParser.parse(json)
        #expect(result.tags.count <= 5)
    }

    @Test func tagsNormalized_lowercased_trimmed() throws {
        let json = #"{"tags":["  Code ","SWIFT"],"summary":"x"}"#
        let result = try TagResponseParser.parse(json)
        #expect(result.tags == ["code", "swift"])
    }
}
