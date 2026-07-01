import Testing
@testable import ClipboardManagerKit

@Suite("Onboarding") struct OnboardingStateTests {
    @Test func initial_notCompleted() {
        let store = InMemoryOnboardingStore()
        let state = OnboardingState(store: store)
        #expect(state.hasCompleted == false)
    }

    @Test func complete_persistsFlag() {
        let store = InMemoryOnboardingStore()
        let state = OnboardingState(store: store)
        state.complete()
        #expect(state.hasCompleted == true)
        #expect(store.read(key: OnboardingState.storageKey) as? Bool == true)
    }

    @Test func loadsFromStore() {
        let store = InMemoryOnboardingStore()
        store.write(true, key: OnboardingState.storageKey)
        let state = OnboardingState(store: store)
        #expect(state.hasCompleted == true)
    }
}

final class InMemoryOnboardingStore: OnboardingStorage {
    private var storage: [String: Any] = [:]
    func read(key: String) -> Any? { storage[key] }
    func write(_ value: Any?, key: String) { storage[key] = value }
}
