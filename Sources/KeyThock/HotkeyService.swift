import Carbon
import Foundation

final class HotkeyService: ObservableObject {
    @Published private(set) var isRegistered = false
    @Published private(set) var statusText = "Control + Option + Escape"

    var onToggle: (() -> Void)?

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private let hotKeyID = EventHotKeyID(signature: 0x5448_434B, id: 1)
    private var currentHotkey: GlobalMuteHotkey = .controlOptionEscape

    deinit {
        unregister()
    }

    func setEnabled(_ enabled: Bool, hotkey: GlobalMuteHotkey) {
        currentHotkey = hotkey
        if enabled {
            register(hotkey)
        } else {
            unregister()
        }
    }

    func register(_ hotkey: GlobalMuteHotkey) {
        currentHotkey = hotkey
        unregister()

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        let installStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            hotKeyEventHandler,
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandlerRef
        )
        guard installStatus == noErr else {
            publishRegistered(false, "Hotkey unavailable")
            return
        }

        let identifier = hotKeyID
        let modifiers = carbonModifiers(for: hotkey)
        let registerStatus = RegisterEventHotKey(
            UInt32(hotkey.keyCode),
            modifiers,
            identifier,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if registerStatus == noErr {
            publishRegistered(true, hotkey.label)
        } else {
            unregister()
            publishRegistered(false, "\(hotkey.label) is already in use")
        }
    }

    func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }
        publishRegistered(false, currentHotkey.label)
    }

    fileprivate func handleHotKey(_ event: EventRef?) -> OSStatus {
        var identifier = EventHotKeyID()
        let status = GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &identifier
        )
        guard status == noErr,
              identifier.signature == hotKeyID.signature,
              identifier.id == hotKeyID.id else {
            return status
        }

        DispatchQueue.main.async { [weak self] in
            self?.onToggle?()
        }
        return noErr
    }

    private func publishRegistered(_ registered: Bool, _ text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.isRegistered = registered
            self?.statusText = text
        }
    }

    private func carbonModifiers(for hotkey: GlobalMuteHotkey) -> UInt32 {
        var modifiers: UInt32 = 0
        if hotkey.requiresControl { modifiers |= UInt32(controlKey) }
        if hotkey.requiresOption { modifiers |= UInt32(optionKey) }
        if hotkey.requiresCommand { modifiers |= UInt32(cmdKey) }
        if hotkey.requiresShift { modifiers |= UInt32(shiftKey) }
        return modifiers
    }
}

private func hotKeyEventHandler(
    nextHandler: EventHandlerCallRef?,
    event: EventRef?,
    userData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let userData else { return noErr }
    let service = Unmanaged<HotkeyService>.fromOpaque(userData).takeUnretainedValue()
    return service.handleHotKey(event)
}
