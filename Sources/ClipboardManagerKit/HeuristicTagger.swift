import Foundation

public struct HeuristicTagger: Sendable {
    public init() {}

    public func tags(forText raw: String) -> [String] {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return [] }
        var tags: [String] = []

        if let host = detectSingleURLHost(text) {
            tags.append("url")
            tags.append("link")
            tags.append(host)
            return dedup(tags)
        }

        if isHexColor(text) {
            tags.append("hex")
            tags.append("color")
        }

        if isRgbOrHsl(text) {
            tags.append("color")
        }

        if isEmail(text) {
            tags.append("email")
        }

        if detectError(text) {
            tags.append("error")
        }

        if let lang = detectCodeLanguage(text) {
            tags.append("code")
            tags.append(lang)
        } else if isLikelyCode(text) {
            tags.append("code")
        }

        if tags.isEmpty && text.count >= 200 {
            tags.append("text")
        }

        return dedup(tags)
    }

    // MARK: - Rules

    private func detectSingleURLHost(_ text: String) -> String? {
        let one = text.split(whereSeparator: { $0.isWhitespace })
        guard one.count == 1 else { return nil }
        let s = String(one[0])
        guard s.hasPrefix("http://") || s.hasPrefix("https://") else { return nil }
        return URL(string: s)?.host
    }

    private func isHexColor(_ text: String) -> Bool {
        // #RGB / #RRGGBB / #RRGGBBAA
        let pattern = #"^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$"#
        return text.range(of: pattern, options: .regularExpression) != nil
    }

    private func isRgbOrHsl(_ text: String) -> Bool {
        let pattern = #"^(?:rgb|rgba|hsl|hsla)\s*\(.+\)$"#
        return text.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }

    private func isEmail(_ text: String) -> Bool {
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return text.range(of: pattern, options: .regularExpression) != nil
    }

    private func detectError(_ text: String) -> Bool {
        if text.contains("Traceback (most recent call last):") { return true }
        if text.range(of: #"^panic:\s"#, options: .regularExpression) != nil { return true }
        if text.range(of: #"^\w+Error:\s"#, options: [.regularExpression, .anchored]) != nil { return true }
        return false
    }

    private func detectCodeLanguage(_ text: String) -> String? {
        // SQL
        if text.range(of: #"\b(SELECT|INSERT|UPDATE|DELETE|CREATE\s+TABLE)\b"#, options: [.regularExpression, .caseInsensitive]) != nil {
            return "sql"
        }
        // JSON: strictly parse
        if let data = text.data(using: .utf8),
           let obj = try? JSONSerialization.jsonObject(with: data, options: []),
           obj is [String: Any] || obj is [Any] {
            return "json"
        }
        // HTML
        if text.range(of: #"<\w+[^>]*>"#, options: .regularExpression) != nil,
           text.contains("</") {
            return "html"
        }
        // Swift
        if text.range(of: #"\b(func|struct|class|enum|guard|let|var|import)\b"#, options: .regularExpression) != nil
            && text.contains("{") {
            if text.contains("->") || text.contains("var ") || text.contains("let ") {
                return "swift"
            }
        }
        // Python
        if text.range(of: #"^\s*def\s+\w+\("#, options: .regularExpression) != nil { return "python" }
        if text.contains("Traceback (most recent call last):") { return "python" }

        return nil
    }

    private func isLikelyCode(_ text: String) -> Bool {
        let hasBraces = text.contains("{") || text.contains("<")
        let hasKeywords = text.range(of: #"\b(function|class|def|import|return|const)\b"#, options: .regularExpression) != nil
        return hasBraces && hasKeywords
    }

    private func dedup(_ arr: [String]) -> [String] {
        var seen = Set<String>()
        return arr.filter { seen.insert($0).inserted }
    }
}
