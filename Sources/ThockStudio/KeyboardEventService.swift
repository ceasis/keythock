import ApplicationServices
import AppKit
import Foundation

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
    private var globalMonitor: Any?
    private var lastDeliveredEvent: DeliveredEventSignature?
    private(set) var state: ListenerState = .stopped {
        didSet { onStateChange?(state) }
    }

    var isRunning: Bool {
        state.isRunning
    }

    func start() {
        stop()
        onDebug?("keyboard.start")

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

            let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
            if let source {
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

        installGlobalMonitorFallback()
        state = .running
    }

    func stop() {
        for tap in eventTaps {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        for source in runLoopSources {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
        }
        eventTaps = []
        runLoopSources = []
        globalMonitor = nil
        lastDeliveredEvent = nil
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

        let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
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

        let sourceApp = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        let keyEvent = KeyEvent(
            keyCode: keyCode,
            category: phase == .modifierChanged ? .modifier : KeyClassifier.classify(keyCode: keyCode),
            phase: phase,
            isRepeat: event.getIntegerValueField(.keyboardEventAutorepeat) != 0,
            timestamp: event.timestamp.seconds,
            flagsRawValue: event.flags.rawValue,
            sourceAppBundleId: sourceApp
        )
        deliver(keyEvent)
    }

    private func installGlobalMonitorFallback() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .keyUp, .flagsChanged]) { [weak self] event in
            self?.receive(event: event)
        }
    }

    private func receive(event: NSEvent) {
        let phase: KeyPhase
        switch event.type {
        case .keyDown:
            phase = .down
        case .keyUp:
            phase = .up
        case .flagsChanged:
            phase = .modifierChanged
        default:
            return
        }

        let keyCode = Int(event.keyCode)
        let sourceApp = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        let keyEvent = KeyEvent(
            keyCode: keyCode,
            category: phase == .modifierChanged ? .modifier : KeyClassifier.classify(keyCode: keyCode),
            phase: phase,
            isRepeat: event.isARepeat,
            timestamp: event.timestamp,
            flagsRawValue: Self.cgFlags(from: event.modifierFlags).rawValue,
            sourceAppBundleId: sourceApp
        )
        deliver(keyEvent)
    }

    private func deliver(_ keyEvent: KeyEvent) {
        let signature = DeliveredEventSignature(keyCode: keyEvent.keyCode, phase: keyEvent.phase, timestamp: keyEvent.timestamp)
        if let lastDeliveredEvent,
           lastDeliveredEvent.keyCode == signature.keyCode,
           lastDeliveredEvent.phase == signature.phase,
           abs(lastDeliveredEvent.timestamp - signature.timestamp) < 0.03 {
            return
        }
        lastDeliveredEvent = signature
        onDebug?("keyboard.event key=\(keyEvent.keyCode) phase=\(keyEvent.phase.rawValue) repeat=\(keyEvent.isRepeat) app=\(keyEvent.sourceAppBundleId ?? "unknown")")
        onEvent?(keyEvent)
    }

    private static func cgFlags(from flags: NSEvent.ModifierFlags) -> CGEventFlags {
        var result = CGEventFlags()
        if flags.contains(.shift) { result.insert(.maskShift) }
        if flags.contains(.control) { result.insert(.maskControl) }
        if flags.contains(.option) { result.insert(.maskAlternate) }
        if flags.contains(.command) { result.insert(.maskCommand) }
        return result
    }
}

private struct DeliveredEventSignature {
    let keyCode: Int
    let phase: KeyPhase
    let timestamp: TimeInterval
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
