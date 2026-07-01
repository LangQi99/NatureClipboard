import Foundation

public enum Highlighter {
    /// Return all case-insensitive ranges in `text` that match any term in `query`.
    /// Multiple terms in `query` are separated by whitespace.
    /// Ranges are returned sorted by lowerBound, non-overlapping.
    public static func matches(text: String, query: String) -> [Range<String.Index>] {
        let terms = query
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)
            .filter { !$0.isEmpty }
        guard !terms.isEmpty, !text.isEmpty else { return [] }

        var ranges: [Range<String.Index>] = []
        for term in terms {
            var searchStart = text.startIndex
            while searchStart < text.endIndex,
                  let r = text.range(of: term, options: .caseInsensitive, range: searchStart..<text.endIndex) {
                ranges.append(r)
                searchStart = r.upperBound
            }
        }
        return mergeSorted(ranges)
    }

    private static func mergeSorted(_ input: [Range<String.Index>]) -> [Range<String.Index>] {
        let sorted = input.sorted { $0.lowerBound < $1.lowerBound }
        var result: [Range<String.Index>] = []
        for r in sorted {
            if let last = result.last, r.lowerBound < last.upperBound {
                if r.upperBound > last.upperBound {
                    result[result.count - 1] = last.lowerBound..<r.upperBound
                }
            } else {
                result.append(r)
            }
        }
        return result
    }
}
