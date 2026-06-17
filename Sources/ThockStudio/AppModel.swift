import AppKit
import Combine
import Foundation

@MainActor
final class AppModel: ObservableObject {
    @Published var listenerState: KeyboardEventService.ListenerState = .stopped
    @Published var selectedTab: SettingsTab = .home
    @Published var isTypingPreviewFocused = false
    @Published var transientPulse = false
    @Published var outputWarning: String?
    @Published var lastKeyboardEventDate: Date?
    @Published var lastKeyboardEventSummary = "No key events yet"
    @Published var lastSoundPlayedDate: Date?
    @Published var lastTypingPlaybackDecision = "No typing playback attempted yet"
    @Published var lastTypingPlaybackDecisionDate: Date?

    let settings: SettingsStore
    let permissions: PermissionService
    let packs: SoundPackManager
    let audio: AudioEngineService
    let profileService: ProfileService
    let hotkeys: HotkeyService
    let debugLog: DebugLogService

    private let keyboard = KeyboardEventService()
    private var cancellables: Set<AnyCancellable> = []
    private var lastRepeatByKey: [Int: TimeInterval] = [:]
    private var suppressSoundsUntil: Date?
    private var timer: Timer?
    private let creamyRecordingPackId = "com.thockstudio.pack.creamykeyboard.recording"
    private let creamyRecordingMigrationKey = "migration.selectedCreamyRecordingPack.v3"
    private let creamy2RecordingPackId = "com.thockstudio.pack.creamy2.recording"
    private let creamy2RecordingMigrationKey = "migration.selectedCreamy2RecordingPack.v1"

    init() {
        settings = SettingsStore()
        permissions = PermissionService()
        packs = SoundPackManager()
        audio = AudioEngineService()
        profileService = ProfileService()
        hotkeys = HotkeyService()
        debugLog = DebugLogService()
        debugLog.append("app.launch pid=\(ProcessInfo.processInfo.processIdentifier) bundle=\(Bundle.main.bundleURL.path) sandbox=\(ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] ?? "none")")

        selectCreamyRecordingPackOnce()
        selectCreamy2RecordingPackOnce()
        ensureSelectedPackExists()
        wireObjectChanges()
        clearPreviewFocusWhenAppDeactivates()
        configureKeyboardListener()
        configureHotkeys()
        audio.preload(pack: currentPack, settings: settings.snapshot)
        permissions.refresh(listenerIsRunning: keyboard.isRunning)
        keyboard.start()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    var currentPack: SoundPack {
        packs.pack(with: settings.currentPackId)
    }

    var visibleStatus: String {
        if permissions.state != .approved { return permissions.state.label }
        if let until = settings.temporaryMuteUntil, until > Date() { return "Muted until \(until.formatted(date: .omitted, time: .shortened))" }
        if profileService.isActiveAppMuted() { return "Muted in \(profileService.activeAppName)" }
        if isQuietHoursActive { return "Quiet Hours" }
        if !settings.appEnabled { return "Off" }
        return "On"
    }

    var menuBarSymbol: String {
        if permissions.state != .approved { return "keyboard.badge.ellipsis" }
        if !settings.appEnabled || isMutedNow { return "keyboard.badge.eye" }
        return transientPulse ? "waveform" : "keyboard"
    }

    var listenerStatusText: String {
        switch listenerState {
        case .stopped:
            return "Keyboard listener stopped"
        case .running:
            return "Keyboard listener running"
        case let .failed(message):
            return message
        }
    }

    var lastKeyboardEventText: String {
        guard let lastKeyboardEventDate else { return lastKeyboardEventSummary }
        return "\(lastKeyboardEventSummary) at \(lastKeyboardEventDate.formatted(date: .omitted, time: .standard))"
    }

    var audioStatusText: String {
        if let error = audio.lastError { return error }
        if audio.isRunning { return "Audio engine running" }
        return "Audio engine stopped"
    }

    var lastSoundPlayedText: String {
        guard let lastSoundPlayedDate else { return "No sound played yet" }
        return "Sound played at \(lastSoundPlayedDate.formatted(date: .omitted, time: .standard))"
    }

    var lastTypingPlaybackDecisionText: String {
        guard let lastTypingPlaybackDecisionDate else { return lastTypingPlaybackDecision }
        return "\(lastTypingPlaybackDecision) at \(lastTypingPlaybackDecisionDate.formatted(date: .omitted, time: .standard))"
    }

    var debugLogPathText: String {
        debugLog.url.path
    }

    var typingPlaybackStatusText: String {
        if permissions.state != .approved { return permissions.state.label }
        if !settings.appEnabled { return "Thock Studio is off" }
        if let until = settings.temporaryMuteUntil, until > Date() {
            return "Muted until \(until.formatted(date: .omitted, time: .shortened))"
        }
        if profileService.isActiveAppMuted() {
            return "Muted in \(profileService.activeAppName)"
        }
        if isQuietHoursActive && !settings.quietHoursLowerVolume {
            return "Muted by Quiet Hours"
        }
        return "Ready"
    }

    var typingPlaybackReady: Bool {
        permissions.state == .approved && !isMutedNow
    }

    var isMutedNow: Bool {
        if !settings.appEnabled { return true }
        if let until = settings.temporaryMuteUntil, until > Date() { return true }
        if profileService.isActiveAppMuted() { return true }
        if isQuietHoursActive && !settings.quietHoursLowerVolume { return true }
        return false
    }

    var isQuietHoursActive: Bool {
        guard settings.quietHoursEnabled else { return false }
        let now = Date()
        let components = Calendar.current.dateComponents([.hour, .minute], from: now)
        let current = (components.hour ?? 0) * 60 + (components.minute ?? 0)
        let start = settings.quietHoursStartMinutes
        let end = settings.quietHoursEndMinutes
        if start == end { return false }
        if start < end {
            return current >= start && current < end
        }
        return current >= start || current < end
    }

    func selectPack(_ pack: SoundPack) {
        settings.currentPackId = pack.id
        settings.masterVolume = pack.recommendedVolume
        settings.pitchVariation = pack.pitchVariationDefault
        settings.sampleVariation = pack.sampleVariationDefault
        audio.preload(pack: pack, settings: settings.snapshot)
    }

    func preview(_ pack: SoundPack) {
        audio.previewTypingDemo(pack: pack, settings: settings.snapshot)
        markSoundPlayed()
        if audio.activePackId != settings.currentPackId {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                guard let self else { return }
                self.audio.preload(pack: self.currentPack, settings: self.settings.snapshot)
            }
        }
    }

    func previewKey(category: KeyCategory = .alpha) {
        if audio.play(SoundPlaybackRequest(
            packId: audio.activePackId ?? settings.currentPackId,
            keyCategory: category,
            phase: .down,
            volume: settings.masterVolume,
            pitchShiftSemitones: settings.pitchShiftSemitones,
            pitchVariation: settings.pitchVariation,
            sampleVariation: settings.sampleVariation,
            sampleIndexOverride: nil,
            timestamp: Date().timeIntervalSince1970,
            appProfileId: nil
        )) {
            markSoundPlayed()
            pulse()
        }
    }

    func assignedSampleIndex(keyCode: Int, packId: String? = nil) -> Int? {
        settings.keySampleOverride(packId: packId ?? settings.currentPackId, keyCode: keyCode)
    }

    func sampleCount(for category: KeyCategory, pack: SoundPack? = nil) -> Int {
        (pack ?? currentPack).sampleCount(for: category)
    }

    func cycleKeySample(keyCode: Int, category: KeyCategory) {
        let pack = currentPack
        let count = pack.sampleCount(for: category)
        guard count > 0 else { return }
        let current = settings.keySampleOverride(packId: pack.id, keyCode: keyCode)
        let next = current.map { ($0 + 1) % count } ?? 0
        settings.setKeySampleOverride(packId: pack.id, keyCode: keyCode, sampleIndex: next)
        playConfiguredKey(pack: pack, keyCode: keyCode, category: category, sampleIndex: next)
    }

    func previewConfiguredKey(keyCode: Int, category: KeyCategory) {
        let pack = currentPack
        let sampleIndex = settings.keySampleOverride(packId: pack.id, keyCode: keyCode)
        playConfiguredKey(pack: pack, keyCode: keyCode, category: category, sampleIndex: sampleIndex)
    }

    func clearConfiguredKey(keyCode: Int) {
        settings.clearKeySampleOverride(packId: settings.currentPackId, keyCode: keyCode)
    }

    func clearConfiguredKeysForCurrentPack() {
        settings.clearKeySampleOverrides(packId: settings.currentPackId)
    }

    func requestPermission() {
        permissions.requestAccess()
        if permissions.state == .approved {
            keyboard.restart()
        }
    }

    func openSettingsForPermission() {
        refreshPermissionStatus()
        permissions.openInputMonitoringSettings()
    }

    func revealAppForPermission() {
        NSWorkspace.shared.activateFileViewerSelecting([Bundle.main.bundleURL])
    }

    func openDebugLog() {
        NSWorkspace.shared.open(debugLog.url)
    }

    func refreshPermissionStatus() {
        permissions.refresh(listenerIsRunning: keyboard.isRunning)
        if permissions.state == .approved && !keyboard.isRunning {
            keyboard.start()
        }
    }

    func restartAudio() {
        audio.restart()
        audio.preload(pack: currentPack, settings: settings.snapshot)
    }

    func restartKeyboardListener() {
        permissions.refresh(listenerIsRunning: keyboard.isRunning)
        keyboard.restart()
    }

    func importPack(from url: URL) {
        do {
            let pack = try packs.importPack(from: url)
            selectPack(pack)
        } catch {
            packs.importMessage = error.localizedDescription
        }
    }

    func resetLocalData() {
        settings.resetAll()
        profileService.resetDefaults()
        hotkeys.setEnabled(settings.globalMuteHotkeyEnabled, hotkey: settings.globalMuteHotkey)
        audio.preload(pack: currentPack, settings: settings.snapshot)
    }

    func setGlobalMuteHotkeyEnabled(_ enabled: Bool) {
        settings.globalMuteHotkeyEnabled = enabled
        hotkeys.setEnabled(enabled, hotkey: settings.globalMuteHotkey)
    }

    func setGlobalMuteHotkey(_ hotkey: GlobalMuteHotkey) {
        settings.globalMuteHotkey = hotkey
        hotkeys.setEnabled(settings.globalMuteHotkeyEnabled, hotkey: hotkey)
    }

    func toggleSoundsFromHotkey() {
        suppressSoundsUntil = Date().addingTimeInterval(0.3)
        if settings.appEnabled && settings.temporaryMuteUntil == nil {
            settings.appEnabled = false
        } else {
            settings.clearTemporaryMute()
            settings.appEnabled = true
        }
        pulse()
    }

    private func playConfiguredKey(pack: SoundPack, keyCode: Int, category: KeyCategory, sampleIndex: Int?) {
        if audio.activePackId != pack.id {
            audio.preload(pack: pack, settings: settings.snapshot)
        }
        if audio.play(SoundPlaybackRequest(
            packId: pack.id,
            keyCategory: category,
            phase: .down,
            volume: effectiveVolume(category: category, phase: .down, profile: nil),
            pitchShiftSemitones: settings.pitchShiftSemitones,
            pitchVariation: settings.pitchVariation,
            sampleVariation: sampleIndex == nil ? settings.sampleVariation : false,
            sampleIndexOverride: sampleIndex,
            timestamp: Date().timeIntervalSince1970,
            appProfileId: nil
        )) {
            markSoundPlayed()
            pulse()
        }
    }

    private func configureKeyboardListener() {
        keyboard.onDebug = { [weak self] message in
            self?.debugLog.append(message)
        }
        keyboard.onStateChange = { [weak self] state in
            Task { @MainActor in
                guard let self else { return }
                self.listenerState = state
                self.permissions.refresh(listenerIsRunning: state.isRunning)
                self.debugLog.append("keyboard.state \(self.listenerStatusText) permission=\(self.permissions.state.rawValue)")
            }
        }
        keyboard.onEvent = { [weak self] event in
            Task { @MainActor in
                self?.handle(event)
            }
        }
    }

    private func configureHotkeys() {
        hotkeys.onToggle = { [weak self] in
            self?.toggleSoundsFromHotkey()
        }
        hotkeys.setEnabled(settings.globalMuteHotkeyEnabled, hotkey: settings.globalMuteHotkey)
    }

    private func selectCreamyRecordingPackOnce() {
        guard !UserDefaults.standard.bool(forKey: creamyRecordingMigrationKey) else { return }
        settings.currentPackId = creamyRecordingPackId
        settings.masterVolume = 0.48
        UserDefaults.standard.set(true, forKey: creamyRecordingMigrationKey)
    }

    private func selectCreamy2RecordingPackOnce() {
        guard !UserDefaults.standard.bool(forKey: creamy2RecordingMigrationKey) else { return }
        settings.currentPackId = creamy2RecordingPackId
        settings.masterVolume = 0.46
        UserDefaults.standard.set(true, forKey: creamy2RecordingMigrationKey)
    }

    private func ensureSelectedPackExists() {
        guard !packs.allPacks.contains(where: { $0.id == settings.currentPackId }) else { return }
        settings.currentPackId = creamy2RecordingPackId
        settings.masterVolume = 0.46
    }

    private func handle(_ event: KeyEvent) {
        debugLog.append("app.handle key=\(event.keyCode) category=\(event.category.rawValue) phase=\(event.phase.rawValue) repeat=\(event.isRepeat)")
        // Modifier flag changes (Shift/Ctrl/Cmd/Opt) reach us through the global-monitor
        // fallback even without Input Monitoring permission, so they don't prove access.
        // Only a real keyDown/keyUp — which macOS withholds without the grant — counts.
        if event.phase != .modifierChanged {
            permissions.markKeyboardEventObserved()
        }
        if event.phase == .down || event.phase == .modifierChanged {
            lastKeyboardEventDate = Date()
            lastKeyboardEventSummary = "\(event.category.displayName) key \(event.keyCode)"
        }
        if isTypingPreviewFocused && event.sourceAppBundleId == Bundle.main.bundleIdentifier {
            noteTypingPlayback("Skipped: in-app preview pad handled this key")
            return
        }
        guard !isGlobalMuteHotkeyEvent(event) else {
            noteTypingPlayback("Skipped: mute shortcut")
            return
        }
        if let suppressSoundsUntil, suppressSoundsUntil > Date() {
            noteTypingPlayback("Skipped: mute shortcut settling")
            return
        }
        guard shouldPlayRepeat(event) else {
            noteTypingPlayback("Skipped: repeat limit")
            return
        }

        profileService.refreshActiveApp()
        guard !isMutedNow else {
            noteTypingPlayback("Skipped: \(typingPlaybackStatusText)")
            return
        }
        let activeProfile = profileService.profileForActiveApp()
        let packId = activeProfile?.soundPackId ?? settings.currentPackId
        let pack = packs.pack(with: packId)
        guard event.phase != .up || (settings.releaseSoundsEnabled && pack.supportsRelease) else {
            noteTypingPlayback("Skipped: release sounds off")
            return
        }
        guard event.category != .modifier || settings.modifierSoundsEnabled else {
            noteTypingPlayback("Skipped: modifier sounds off")
            return
        }
        if audio.activePackId != pack.id {
            audio.preload(pack: pack, settings: settings.snapshot)
        }

        var volume = effectiveVolume(category: event.category, phase: event.phase, profile: activeProfile)
        if event.isRepeat && settings.repeatMode == .reduced {
            volume *= 0.45
        }
        let sampleIndexOverride = settings.keySampleOverride(packId: pack.id, keyCode: event.keyCode)

        let didPlay = audio.play(SoundPlaybackRequest(
            packId: pack.id,
            keyCategory: event.category,
            phase: event.phase,
            volume: volume,
            pitchShiftSemitones: settings.pitchShiftSemitones,
            pitchVariation: settings.pitchVariation,
            sampleVariation: sampleIndexOverride == nil ? settings.sampleVariation : false,
            sampleIndexOverride: sampleIndexOverride,
            timestamp: event.timestamp,
            appProfileId: activeProfile?.id
        ))

        if didPlay {
            markSoundPlayed()
            noteTypingPlayback("Played \(pack.name) for \(event.category.displayName)")
            pulse()
        } else {
            noteTypingPlayback("Skipped: audio sample was not scheduled")
        }
    }

    private func markSoundPlayed() {
        lastSoundPlayedDate = Date()
    }

    private func noteTypingPlayback(_ message: String) {
        lastTypingPlaybackDecision = message
        lastTypingPlaybackDecisionDate = Date()
        debugLog.append("playback.decision \(message)")
    }

    private func shouldPlayRepeat(_ event: KeyEvent) -> Bool {
        guard event.isRepeat else { return true }
        switch settings.repeatMode {
        case .all, .reduced:
            let now = Date().timeIntervalSince1970
            let minimumGap = 1.0 / max(1, settings.maxRepeatSoundsPerSecond)
            if let last = lastRepeatByKey[event.keyCode], now - last < minimumGap {
                return false
            }
            lastRepeatByKey[event.keyCode] = now
            return true
        case .firstOnly, .off:
            return false
        }
    }

    private func isGlobalMuteHotkeyEvent(_ event: KeyEvent) -> Bool {
        let hotkey = settings.globalMuteHotkey
        guard settings.globalMuteHotkeyEnabled, event.keyCode == hotkey.keyCode else { return false }
        let flags = CGEventFlags(rawValue: event.flagsRawValue)
        if hotkey.requiresControl && !flags.contains(.maskControl) { return false }
        if hotkey.requiresOption && !flags.contains(.maskAlternate) { return false }
        if hotkey.requiresCommand && !flags.contains(.maskCommand) { return false }
        if hotkey.requiresShift && !flags.contains(.maskShift) { return false }
        return true
    }

    private func effectiveVolume(category: KeyCategory, phase: KeyPhase, profile: AppProfile?) -> Float {
        var volume = settings.masterVolume
        volume *= profile?.volume ?? 1
        volume *= phase == .up ? settings.releaseVolume : settings.pressVolume

        switch category {
        case .space:
            volume *= settings.spacebarVolume
        case .modifier:
            volume *= settings.modifierVolume
        default:
            break
        }

        if isQuietHoursActive && settings.quietHoursLowerVolume {
            volume *= settings.quietHoursVolume
        }
        if settings.limiterEnabled {
            volume = min(volume, 1.1)
        }
        return max(0, volume)
    }

    private func wireObjectChanges() {
        [
            settings.objectWillChange.eraseToAnyPublisher(),
            permissions.objectWillChange.eraseToAnyPublisher(),
            packs.objectWillChange.eraseToAnyPublisher(),
            audio.objectWillChange.eraseToAnyPublisher(),
            profileService.objectWillChange.eraseToAnyPublisher(),
            hotkeys.objectWillChange.eraseToAnyPublisher()
        ].forEach { publisher in
            publisher
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in self?.objectWillChange.send() }
                .store(in: &cancellables)
        }
    }

    private func clearPreviewFocusWhenAppDeactivates() {
        NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.isTypingPreviewFocused = false
            }
            .store(in: &cancellables)
    }

    private func tick() {
        if !NSApp.isActive && isTypingPreviewFocused {
            isTypingPreviewFocused = false
        }
        if let until = settings.temporaryMuteUntil, until <= Date() {
            settings.temporaryMuteUntil = nil
        }
        refreshPermissionStatus()
    }

    private func pulse() {
        guard settings.menuBarAnimation else { return }
        transientPulse = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
            self?.transientPulse = false
        }
    }
}
