import ApplicationServices
import AppKit
import Foundation

@MainActor
final class PermissionService: ObservableObject {
    @Published private(set) var state: PermissionState = .notDetermined

    init() {
        refresh()
    }

    func refresh(listenerIsRunning: Bool = false) {
        if listenerIsRunning || CGPreflightListenEventAccess() {
            state = .approved
        } else if state == .approved {
            state = .unknownOrBlocked
        } else if state != .denied {
            state = .notDetermined
        }
    }

    func requestAccess() {
        let granted = CGRequestListenEventAccess()
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
