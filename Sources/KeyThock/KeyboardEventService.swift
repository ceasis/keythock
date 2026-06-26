import ApplicationServices
import AppKit
import Foundation

/// Listens for keyboard events globally using a listen-only `CGEventTap`.
///
/// Important: this uses `CGEventTap` with `.listenOnly`, which is gated by the
/// **Input Monitoring** privilege (`CGPreflightListenEventAccess` /
/// `CGRequestListenEventAccess`) and is available to sandboxed Mac App Store
/// apps. Do NOT switch to `NSEvent.addGlobalMonitorForEvents`: that API requires
/// the **Accessibility** privilege, is unavailable in the sandbox, and is what
/// caused the App Store 2.4.5 rejection.
final class KeyboardEventService {
    enum ListenerState: Equatable {
        case stopped
        case running
        case failed(String)
    }

    var onEvent: ((KeyEvent) -> Void)?
    var onStateChange: ((ListenerState) -> Void)?
    var onDebug: ((String) -> Void)?

    private var eventTaps: [CFMachPort] = []
    private var runLoopSources: [CFRunLoopSource] = []
    private var recentDeliveredEvents: [DeliveredEventSignature: TimeInterval] = [:]
    private(set) var state: ListenerState = .stopped {
        didSet { onStateChange?(state) }
    }

    var isRunning: Bool {
        state.isRunning
    }

    func start() {
        stop()
        onDebug?("keyboard.global.start")

        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)
            | CGEventMask(1 << CGEventType.keyUp.rawValue)
            | CGEventMask(1 << CGEventType.flagsChanged.rawValue)
            | CGEventMask(1 << CGEventType.tapDisabledByTimeout.rawValue)
            | CGEventMask(1 << CGEventType.tapDisabledByUserInput.rawValue)

        let refcon = Unmanaged.passUnretained(self).toOpaque()
        let tapLocations: [(CGEventTapLocation, String)] = [
            (.cgSessionEventTap, "session"),
            (.cgAnnotatedSessionEventTap, "annotated-session"),
            (.cghidEventTap, "hid")
        ]

        for (location, name) in tapLocations {
            guard let tap = CGEvent.tapCreate(
                tap: location,
                place: .headInsertEventTap,
                options: .listenOnly,
                eventsOfInterest: mask,
                callback: keyboardEventCallback,
                userInfo: refcon
            ) else {
                onDebug?("keyboard.tap.failed location=\(name)")
                continue
            }

            if let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0) {
                CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
                runLoopSources.append(source)
            }
            CGEvent.tapEnable(tap: tap, enable: true)
            eventTaps.append(tap)
            onDebug?("keyboard.tap.running location=\(name)")
        }

        guard !eventTaps.isEmpty else {
            state = .failed("macOS did not create the keyboard event listener. Check Input Monitoring.")
            onDebug?("keyboard.failed no-event-taps")
            return
        }

        state = .running
    }

    func stop() {
        for tap in eventTaps {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        for source in runLoopSources {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        eventTaps = []
        runLoopSources = []
        recentDeliveredEvents = [:]
        state = .stopped
    }

    func restart() {
        start()
    }

    fileprivate func receive(type: CGEventType, event: CGEvent) {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if !eventTaps.isEmpty {
                for tap in eventTaps {
                    CGEvent.tapEnable(tap: tap, enable: true)
                }
                state = .running
                onDebug?("keyboard.tap.reenabled")
            } else {
                state = .failed("Keyboard listener was disabled by macOS.")
                onDebug?("keyboard.tap.disabled no-taps")
            }
            return
        }

        let phase: KeyPhase
        switch type {
        case .keyDown:
            phase = .down
        case .keyUp:
            phase = .up
        case .flagsChanged:
            phase = .modifierChanged
        default:
            return
        }

        let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
        let keyEvent = KeyEvent(
            keyCode: keyCode,
            category: phase == .modifierChanged ? .modifier : KeyClassifier.classify(keyCode: keyCode),
            phase: phase,
            isRepeat: event.getIntegerValueField(.keyboardEventAutorepeat) != 0,
            timestamp: event.timestamp.seconds,
            flagsRawValue: UInt(event.flags.rawValue),
            sourceAppBundleId: NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        )
        deliver(keyEvent)
    }

    private func deliver(_ keyEvent: KeyEvent) {
        let signature = DeliveredEventSignature(keyCode: keyEvent.keyCode, phase: keyEvent.phase)
        let now = ProcessInfo.processInfo.systemUptime
        recentDeliveredEvents = recentDeliveredEvents.filter { now - $0.value < 0.2 }
        if let lastDeliveredAt = recentDeliveredEvents[signature],
           now - lastDeliveredAt < 0.045 {
            return
        }
        recentDeliveredEvents[signature] = now
        onDebug?("keyboard.event phase=\(keyEvent.phase.rawValue) repeat=\(keyEvent.isRepeat) app=\(keyEvent.sourceAppBundleId ?? "unknown")")
        onEvent?(keyEvent)
    }
}

private struct DeliveredEventSignature: Hashable {
    let keyCode: Int
    let phase: KeyPhase
}

extension KeyboardEventService.ListenerState {
    var isRunning: Bool {
        if case .running = self {
            return true
        }
        return false
    }
}

private func keyboardEventCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    if let refcon {
        let service = Unmanaged<KeyboardEventService>.fromOpaque(refcon).takeUnretainedValue()
        service.receive(type: type, event: event)
    }
    return Unmanaged.passUnretained(event)
}

private extension UInt64 {
    var seconds: TimeInterval {
        TimeInterval(self) / 1_000_000_000
    }
}
