import SwiftUI
import AppKit
import ClipboardManagerKit

struct OnboardingView: View {
    var onFinish: () -> Void
    @State private var step: Int = 0

    var body: some View {
        VStack(spacing: 22) {
            switch step {
            case 0:
                stepWelcome
            case 1:
                stepAccessibility
            default:
                stepDone
            }
        }
        .padding(32)
        .frame(width: 480, height: 320)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var stepWelcome: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 44))
                .foregroundColor(.green)
            Text("Welcome to NatureClipboard")
                .font(.title2).bold()
            Text("A Raycast-style clipboard manager with a fresh Nature theme.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Spacer()
            Button("Continue") { withAnimation { step = 1 } }
                .keyboardShortcut(.defaultAction)
        }
    }

    private var stepAccessibility: some View {
        VStack(spacing: 12) {
            Image(systemName: "hand.raised.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            Text("Accessibility Permission")
                .font(.title3).bold()
            Text("NatureClipboard needs Accessibility permission to intercept the global shortcut (⌘E) and to paste back into the previously focused app after selecting an item.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 6)
            Spacer()
            HStack {
                Button("Open System Settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                        NSWorkspace.shared.open(url)
                    }
                }
                Button("Continue") { withAnimation { step = 2 } }
                    .keyboardShortcut(.defaultAction)
            }
        }
    }

    private var stepDone: some View {
        VStack(spacing: 14) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 40))
                .foregroundColor(.green)
            Text("You're all set")
                .font(.title3).bold()
            Text("Press ⌘E anywhere to open your clipboard history.")
                .foregroundColor(.secondary)
            Spacer()
            Button("Get Started") { onFinish() }
                .keyboardShortcut(.defaultAction)
        }
    }
}
