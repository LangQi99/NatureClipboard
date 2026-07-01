import Foundation

public enum ArrowDirection {
    case up, down
}

public enum KeyRouting {
    /// Return the index that should be selected after pressing an arrow key.
    /// - Parameters:
    ///   - direction: up or down arrow.
    ///   - currentIndex: nil if no current selection.
    ///   - count: total items in the list.
    /// - Returns: The new index, or nil if the list is empty.
    public static func nextIndex(direction: ArrowDirection, currentIndex: Int?, count: Int) -> Int? {
        guard count > 0 else { return nil }
        let clamped = currentIndex.map { max(0, min(count - 1, $0)) }
        switch direction {
        case .up:
            if let idx = clamped {
                return max(0, idx - 1)
            }
            return 0
        case .down:
            if let idx = clamped {
                return min(count - 1, idx + 1)
            }
            return 0
        }
    }
}
