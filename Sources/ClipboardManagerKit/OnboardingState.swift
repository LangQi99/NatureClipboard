import Foundation

public protocol OnboardingStorage: AnyObject {
    func read(key: String) -> Any?
    func write(_ value: Any?, key: String)
}

public final class UserDefaultsOnboardingStore: OnboardingStorage {
    private let defaults: UserDefaults
    public init(defaults: UserDefaults = .standard) { self.defaults = defaults }
    public func read(key: String) -> Any? { defaults.object(forKey: key) }
    public func write(_ value: Any?, key: String) { defaults.set(value, forKey: key) }
}

public final class OnboardingState {
    public static let storageKey = "hasCompletedOnboarding"

    private let store: OnboardingStorage
    public init(store: OnboardingStorage = UserDefaultsOnboardingStore()) {
        self.store = store
    }

    public var hasCompleted: Bool {
        (store.read(key: Self.storageKey) as? Bool) ?? false
    }

    public func complete() {
        store.write(true, key: Self.storageKey)
    }

    public func reset() {
        store.write(nil, key: Self.storageKey)
    }
}
