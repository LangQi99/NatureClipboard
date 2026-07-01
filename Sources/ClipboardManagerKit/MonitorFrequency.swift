import Foundation

public enum MonitorFrequency {
    public static let foregroundInterval: TimeInterval = 0.5
    public static let backgroundInterval: TimeInterval = 1.5
    public static let lowPowerInterval: TimeInterval = 2.0
    public static let lowBatteryThreshold: Double = 0.2

    public static func recommendedInterval(
        foreground: Bool,
        lowPowerMode: Bool,
        batteryLevel: Double?
    ) -> TimeInterval {
        if lowPowerMode {
            return lowPowerInterval
        }
        if let level = batteryLevel, level < lowBatteryThreshold {
            return lowPowerInterval
        }
        if !foreground {
            return backgroundInterval
        }
        return foregroundInterval
    }
}
