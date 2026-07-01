import Testing
import Foundation
@testable import ClipboardManagerKit

struct MockLLMClient: LLMClientProtocol, Sendable {
    let response: LLMResponse

    func complete(_ request: LLMRequest) async throws -> LLMResponse {
        response
    }
}

struct ErrorLLMClient: LLMClientProtocol, Sendable {
    let error: LLMError

    func complete(_ request: LLMRequest) async throws -> LLMResponse {
        throw error
    }
}

@Suite("LLMClient") struct LLMClientTests {
    @Test func mockClient_returnsResponse() async throws {
        let expected = LLMResponse(content: "{\"tags\":[\"code\"]}", model: "gpt-4o-mini", promptTokens: 10, completionTokens: 5)
        let client = MockLLMClient(response: expected)
        let req = LLMRequest(messages: [("user", "hello")])
        let result = try await client.complete(req)
        #expect(result == expected)
    }

    @Test func errorClient_throwsHTTPError() async {
        let client = ErrorLLMClient(error: .httpError(401))
        let req = LLMRequest(messages: [("user", "hi")])
        do {
            _ = try await client.complete(req)
            #expect(Bool(false))
        } catch let e as LLMError {
            #expect(e == .httpError(401))
        } catch {
            #expect(Bool(false))
        }
    }

    @Test func request_defaultValues() {
        let req = LLMRequest(messages: [("system", "x"), ("user", "y")])
        #expect(req.temperature == 0)
        #expect(req.maxTokens == 128)
        #expect(req.jsonMode == true)
    }

    @Test func response_equatable() {
        let a = LLMResponse(content: "hi", model: "m", promptTokens: 1, completionTokens: 2)
        let b = LLMResponse(content: "hi", model: "m", promptTokens: 1, completionTokens: 2)
        #expect(a == b)
    }
}
