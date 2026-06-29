import Foundation

enum TextTransformation: String, CaseIterable {
    case uppercase
    case lowercase
    case capitalized
    case titleCase
    case camelCase
    case snakeCase
    case kebabCase
    case trimWhitespace
    case removeNewlines
    case sortLines
    case reverseLines
    case removeDuplicateLines
    case base64Encode
    case base64Decode
    case urlEncode
    case urlDecode
    case countWords
    case countCharacters
    case wrapInQuotes
    case stripHTML
    case jsonPrettify
    case jsonMinify

    var displayName: String {
        switch self {
        case .uppercase: return "UPPERCASE"
        case .lowercase: return "lowercase"
        case .capitalized: return "Capitalized"
        case .titleCase: return "Title Case"
        case .camelCase: return "camelCase"
        case .snakeCase: return "snake_case"
        case .kebabCase: return "kebab-case"
        case .trimWhitespace: return "Trim Whitespace"
        case .removeNewlines: return "Remove Newlines"
        case .sortLines: return "Sort Lines"
        case .reverseLines: return "Reverse Lines"
        case .removeDuplicateLines: return "Remove Duplicate Lines"
        case .base64Encode: return "Base64 Encode"
        case .base64Decode: return "Base64 Decode"
        case .urlEncode: return "URL Encode"
        case .urlDecode: return "URL Decode"
        case .countWords: return "Count Words"
        case .countCharacters: return "Count Characters"
        case .wrapInQuotes: return "Wrap in Quotes"
        case .stripHTML: return "Strip HTML"
        case .jsonPrettify: return "JSON Prettify"
        case .jsonMinify: return "JSON Minify"
        }
    }

    func apply(to text: String) -> String {
        switch self {
        case .uppercase: return text.uppercased()
        case .lowercase: return text.lowercased()
        case .capitalized: return text.capitalized
        case .titleCase: return text.split(separator: " ").map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }.joined(separator: " ")
        case .camelCase:
            let words = text.components(separatedBy: .alphanumerics.inverted).filter { !$0.isEmpty }
            return words.enumerated().map { $0.offset == 0 ? $0.element.lowercased() : $0.element.capitalized }.joined()
        case .snakeCase:
            return text.components(separatedBy: .alphanumerics.inverted).filter { !$0.isEmpty }.joined(separator: "_").lowercased()
        case .kebabCase:
            return text.components(separatedBy: .alphanumerics.inverted).filter { !$0.isEmpty }.joined(separator: "-").lowercased()
        case .trimWhitespace: return text.trimmingCharacters(in: .whitespacesAndNewlines)
        case .removeNewlines: return text.replacingOccurrences(of: "\n", with: " ")
        case .sortLines: return text.components(separatedBy: "\n").sorted().joined(separator: "\n")
        case .reverseLines: return text.components(separatedBy: "\n").reversed().joined(separator: "\n")
        case .removeDuplicateLines:
            var seen = Set<String>()
            return text.components(separatedBy: "\n").filter { seen.insert($0).inserted }.joined(separator: "\n")
        case .base64Encode: return Data(text.utf8).base64EncodedString()
        case .base64Decode:
            guard let data = Data(base64Encoded: text), let decoded = String(data: data, encoding: .utf8) else { return text }
            return decoded
        case .urlEncode: return text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? text
        case .urlDecode: return text.removingPercentEncoding ?? text
        case .countWords: return "Words: \(text.split(separator: " ").count)"
        case .countCharacters: return "Characters: \(text.count)"
        case .wrapInQuotes: return "\"\(text)\""
        case .stripHTML: return text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        case .jsonPrettify:
            guard let data = text.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data),
                  let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                  let result = String(data: pretty, encoding: .utf8) else { return text }
            return result
        case .jsonMinify:
            guard let data = text.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data),
                  let compact = try? JSONSerialization.data(withJSONObject: json),
                  let result = String(data: compact, encoding: .utf8) else { return text }
            return result
        }
    }
}
