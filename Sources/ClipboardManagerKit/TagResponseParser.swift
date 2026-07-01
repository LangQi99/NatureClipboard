import Foundation

public enum TagParseError: Error {
    case invalidJSON
}

public struct TagResult: Sendable, Equatable {
    public var tags: [String]
    public var summary: String?

    public init(tags: [String], summary: String? = nil) {
        self.tags = tags
        self.summary = summary
    }
}

public enum TagResponseParser {
    public static func parse(_ raw: String) throws -> TagResult {
        let cleaned = extractJSON(from: raw)
        guard let data = cleaned.data(using: .utf8) else { throw TagParseError.invalidJSON }

        let json: [String: Any]
        do {
            // Try strict first
            if let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                json = obj
            } else {
                throw TagParseError.invalidJSON
            }
        } catch _ as TagParseError {
            throw TagParseError.invalidJSON
        } catch {
            // Lenient: strip trailing commas
            let lenient = cleaned
                .replacingOccurrences(of: ",\\s*]", with: "]", options: .regularExpression)
                .replacingOccurrences(of: ",\\s*}", with: "}", options: .regularExpression)
            guard let lenientData = lenient.data(using: .utf8),
                  let obj = try? JSONSerialization.jsonObject(with: lenientData) as? [String: Any] else {
                throw TagParseError.invalidJSON
            }
            json = obj
        }

        let rawTags = (json["tags"] as? [String]) ?? []
        let tags = rawTags
            .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            .filter { !$0.isEmpty }
            .prefix(5)

        let summary = json["summary"] as? String

        return TagResult(tags: Array(tags), summary: summary)
    }

    private static func extractJSON(from raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("```") {
            let lines = trimmed.components(separatedBy: "\n")
            let inner = lines.dropFirst().dropLast().joined(separator: "\n")
            return inner.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let start = trimmed.firstIndex(of: "{"),
           let end = trimmed.lastIndex(of: "}") {
            return String(trimmed[start...end])
        }
        return trimmed
    }
}
