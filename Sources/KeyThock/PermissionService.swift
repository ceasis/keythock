import ApplicationServices
import AppKit
import Foundation

@MainActor
final class PermissionService: ObservableObject {
    @Published private(set) var state: PermissionState = .notDetermined
    private var observedKeyboardEvents = false

    init() {
        refresh()
    }

    func refresh(listenerIsRunning: Bool = false) {
        if CGPreflightListenEventAccess() || observedKeyboardEvents {
            state = .approved
        } else if listenerIsRunning {
            state = .unknownOrBlocked
        } else if state == .approved {
            state = .unknownOrBlocked
        } else if state != .denied {
            state = .notDetermined
        }
    }

    func markKeyboardEventObserved() {
        observedKeyboardEvents = true
        state = .approved
    }

    func requestAccess() {
        let granted = CGRequestListenEventAccess()
        observedKeyboardEvents = false
        state = granted ? .approved : .denied
        if !granted {
            openInputMonitoringSettings()
        }
    }

    func openInputMonitoringSettings() {
        let urls = [
            "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent",
            "x-apple.systempreferences:com.apple.preference.security?Privacy_Keyboard"
        ]
        for raw in urls {
            guard let url = URL(string: raw) else { continue }
            if NSWorkspace.shared.open(url) {
                return
            }
        }
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Security.prefPane"))
    }
}
