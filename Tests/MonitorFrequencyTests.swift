import Testing
@testable import ClipboardManagerKit

@Suite("MonitorFrequency") struct MonitorFrequencyTests {

    // MARK: - Foreground

    @Test func foreground_plugged_returnsFast() {
        let t = MonitorFrequency.recommendedInterval(foreground: true, lowPowerMode: false, batteryLevel: 0.8)
        #expect(t == 0.5)
    }

    @Test func foreground_noBatteryInfo_returnsFast() {
        let t = MonitorFrequency.recommendedInterval(foreground: true, lowPowerMode: false, batteryLevel: nil)
        #expect(t == 0.5)
    }

    // MARK: - Background

    @Test func background_normalBattery_returnsMedium() {
        let t = MonitorFrequency.recommendedInterval(foreground: false, lowPowerMode: false, batteryLevel: 0.8)
        #expect(t == 1.5)
    }

    // MARK: - Low power / low battery

    @Test func lowPowerMode_returnsSlow() {
        let t = MonitorFrequency.recommendedInterval(foreground: true, lowPowerMode: true, batteryLevel: 0.8)
        #expect(t == 2.0)
    }

    @Test func lowBattery_below20_returnsSlow() {
        let t = MonitorFrequency.recommendedInterval(foreground: true, lowPowerMode: false, batteryLevel: 0.15)
        #expect(t == 2.0)
    }

    // MARK: - Boundary

    @Test func batteryExactly20_returnsFast() {
        let t = MonitorFrequency.recommendedInterval(foreground: true, lowPowerMode: false, batteryLevel: 0.20)
        #expect(t == 0.5)
    }

    // MARK: - Priority

    @Test func background_andLowPower_lowPowerWins() {
        let t = MonitorFrequency.recommendedInterval(foreground: false, lowPowerMode: true, batteryLevel: 0.8)
        #expect(t == 2.0)
    }
}
