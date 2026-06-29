import AppKit
import SwiftUI
import Carbon.HIToolbox

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var panel: FloatingPanel?
    var globalMonitor: Any?
    var localMonitor: Any?
    var hotKeyRef: EventHotKeyRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupPanel()
        setupHotkey()
        NSApp.setActivationPolicy(.accessory)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.panel?.show()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard Manager")
            button.action = #selector(statusItemClicked)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    @objc func statusItemClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type == .rightMouseUp {
            showMenu()
        } else {
            togglePanel()
        }
    }

    private func showMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show Clipboard", action: #selector(togglePanel), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Clear History", action: #selector(clearHistory), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    private func setupPanel() {
        panel = FloatingPanel()
    }

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    private func setupHotkey() {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        if !trusted {
            print("Accessibility permission required.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.setupHotkey()
            }
            return
        }

        let mask: CGEventMask = 1 << CGEventType.keyDown.rawValue
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: { _, type, event, refcon in
                guard let refcon = refcon else { return Unmanaged.passUnretained(event) }
                let delegate = Unmanaged<AppDelegate>.fromOpaque(refcon).takeUnretainedValue()
                let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
                let flags = event.flags
                if keyCode == Int64(kVK_ANSI_V)
                    && flags.contains(.maskCommand)
                    && flags.contains(.maskShift)
                    && !flags.contains(.maskAlternate)
                    && !flags.contains(.maskControl) {
                    DispatchQueue.main.async {
                        delegate.togglePanel()
                    }
                    return nil
                }
                return Unmanaged.passUnretained(event)
            },
            userInfo: selfPtr
        ) else {
            print("Failed to create CGEvent tap")
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    @objc func togglePanel() {
        if let panel = panel {
            if panel.isVisible {
                panel.animateOut()
            } else {
                panel.animateIn()
            }
        }
    }

    @objc func clearHistory() {
        ClipboardStore.shared.clearAll()
    }

    @objc func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quitApp() {
        if SettingsManager.shared.clearOnQuit {
            ClipboardStore.shared.clearAll()
        }
        NSApp.terminate(nil)
    }
}

class KeyEventBus: ObservableObject {
    static let shared = KeyEventBus()
    var onUp: (() -> Void)?
    var onDown: (() -> Void)?
    var onReturn: (() -> Void)?
    var onEscape: (() -> Void)?
}

class FloatingPanel: NSPanel {
    private var hostingView: NSHostingView<MainView>?

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if flags == [.command, .shift] && event.keyCode == UInt16(kVK_ANSI_V) {
            (NSApp.delegate as? AppDelegate)?.togglePanel()
            return true
        }
        return super.performKeyEquivalent(with: event)
    }

    override func sendEvent(_ event: NSEvent) {
        if event.type == .keyDown {
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if flags == [.command, .shift] && event.keyCode == UInt16(kVK_ANSI_V) {
                (NSApp.delegate as? AppDelegate)?.togglePanel()
                return
            }
            if flags.isEmpty {
                switch Int(event.keyCode) {
                case kVK_UpArrow:
                    KeyEventBus.shared.onUp?()
                    return
                case kVK_DownArrow:
                    KeyEventBus.shared.onDown?()
                    return
                case kVK_Return:
                    if let h = KeyEventBus.shared.onReturn { h(); return }
                case kVK_Escape:
                    if let h = KeyEventBus.shared.onEscape { h(); return }
                default: break
                }
            }
        }
        super.sendEvent(event)
    }

    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 750, height: 500),
            styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = true
        level = .floating
        isMovableByWindowBackground = false
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        animationBehavior = .utilityWindow
        collectionBehavior = [.transient, .ignoresCycle, .fullScreenAuxiliary]
        isReleasedWhenClosed = false
        alphaValue = 0

        let mainView = MainView(closeAction: { [weak self] in self?.animateOut() })
        hostingView = NSHostingView(rootView: mainView)
        contentView = hostingView

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleResignKey),
            name: NSWindow.didResignKeyNotification, object: self)
    }

    @objc private func handleResignKey() {
        if isVisible { animateOut() }
    }

    func show() {
        center()
        makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        alphaValue = 1
    }

    func animateIn() {
        alphaValue = 0
        center()
        let finalFrame = frame
        var startFrame = finalFrame
        startFrame.origin.y -= 20
        setFrame(startFrame, display: false)
        makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            self.animator().alphaValue = 1
            self.animator().setFrame(finalFrame, display: true)
        })
    }

    func animateOut() {
        let startFrame = frame
        var endFrame = startFrame
        endFrame.origin.y -= 15

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.animator().alphaValue = 0
            self.animator().setFrame(endFrame, display: true)
        }, completionHandler: {
            self.orderOut(nil)
            self.setFrame(startFrame, display: false)
        })
    }

    override func close() {
        animateOut()
    }

    override func cancelOperation(_ sender: Any?) {
        animateOut()
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
