import Foundation

public struct LLMRequest: Sendable {
    public var messages: [(role: String, content: String)]
    public var temperature: Double
    public var maxTokens: Int
    public var jsonMode: Bool

    public init(messages: [(role: String, content: String)], temperature: Double = 0, maxTokens: Int = 128, jsonMode: Bool = true) {
        self.messages = messages
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.jsonMode = jsonMode
    }
}

public struct LLMResponse: Sendable, Equatable {
    public var content: String
    public var model: String
    public var promptTokens: Int
    public var completionTokens: Int

    public init(content: String, model: String = "", promptTokens: Int = 0, completionTokens: Int = 0) {
        self.content = content
        self.model = model
        self.promptTokens = promptTokens
        self.completionTokens = completionTokens
    }
}

public enum LLMError: Error, Equatable {
    case invalidURL
    case httpError(Int)
    case noContent
    case networkError(String)
}

public protocol LLMClientProtocol: Sendable {
    func complete(_ request: LLMRequest) async throws -> LLMResponse
}

public struct OpenAICompatibleClient: LLMClientProtocol, Sendable {
    let baseURL: String
    let apiKey: String
    let model: String
    let timeout: TimeInterval

    public init(baseURL: String, apiKey: String, model: String, timeout: TimeInterval = 15) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.model = model
        self.timeout = timeout
    }

    public func complete(_ request: LLMRequest) async throws -> LLMResponse {
        guard let url = URL(string: baseURL + "/chat/completions") else {
            throw LLMError.invalidURL
        }
        var httpReq = URLRequest(url: url)
        httpReq.httpMethod = "POST"
        httpReq.timeoutInterval = timeout
        httpReq.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        httpReq.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [
            "model": model,
            "temperature": request.temperature,
            "max_tokens": request.maxTokens,
            "messages": request.messages.map { ["role": $0.role, "content": $0.content] }
        ]
        if request.jsonMode {
            body["response_format"] = ["type": "json_object"]
        }
        httpReq.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: httpReq)
        guard let http = response as? HTTPURLResponse else { throw LLMError.networkError("No HTTP response") }
        guard http.statusCode == 200 else { throw LLMError.httpError(http.statusCode) }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let first = choices.first,
              let message = first["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw LLMError.noContent
        }

        let usage = json["usage"] as? [String: Any]
        return LLMResponse(
            content: content,
            model: (json["model"] as? String) ?? model,
            promptTokens: (usage?["prompt_tokens"] as? Int) ?? 0,
            completionTokens: (usage?["completion_tokens"] as? Int) ?? 0
        )
    }
}
