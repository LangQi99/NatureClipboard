import Testing
@testable import ClipboardManagerKit

@Suite("KeyRouting") struct KeyRoutingTests {
    @Test func downArrow_noSelection_returnsFirst() {
        #expect(KeyRouting.nextIndex(direction: .down, currentIndex: nil, count: 5) == 0)
    }

    @Test func upArrow_noSelection_returnsFirst() {
        #expect(KeyRouting.nextIndex(direction: .up, currentIndex: nil, count: 5) == 0)
    }

    @Test func downArrow_middle_advances() {
        #expect(KeyRouting.nextIndex(direction: .down, currentIndex: 2, count: 5) == 3)
    }

    @Test func downArrow_atBottom_clampsToLast() {
        #expect(KeyRouting.nextIndex(direction: .down, currentIndex: 4, count: 5) == 4)
    }

    @Test func upArrow_middle_retreats() {
        #expect(KeyRouting.nextIndex(direction: .up, currentIndex: 2, count: 5) == 1)
    }

    @Test func upArrow_atTop_clampsToZero() {
        #expect(KeyRouting.nextIndex(direction: .up, currentIndex: 0, count: 5) == 0)
    }

    @Test func emptyList_returnsNil() {
        #expect(KeyRouting.nextIndex(direction: .up, currentIndex: nil, count: 0) == nil)
        #expect(KeyRouting.nextIndex(direction: .down, currentIndex: 3, count: 0) == nil)
    }

    @Test func outOfBoundsCurrentIndex_isClampedBeforeStep() {
        #expect(KeyRouting.nextIndex(direction: .down, currentIndex: 99, count: 5) == 4)
        #expect(KeyRouting.nextIndex(direction: .up, currentIndex: -3, count: 5) == 0)
    }
}
