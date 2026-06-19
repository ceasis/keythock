import Foundation
import ServiceManagement
import SwiftUI

@MainActor
final class SettingsStore: ObservableObject {
    private let defaultsKey = "settings.snapshot.v1"
    private let dryDefaultMixerMigrationKey = "migration.dryDefaultMixer.v1"
    private let drySmallRoomMigrationKey = "migration.drySmallRoom.v2"
    private let defaultVolumeMigrationKey = "migration.defaultVolume25.v2"
    private let defaults: UserDefaults

    @Published var appEnabled: Bool { didSet { save() } }
    @Published var currentPackId: String { didSet { save() } }
    @Published var masterVolume: Float { didSet { save() } }
    @Published var pressVolume: Float { didSet { save() } }
    @Published var releaseVolume: Float { didSet { save() } }
    @Published var spacebarVolume: Float { didSet { save() } }
    @Published var modifierVolume: Float { didSet { save() } }
    @Published var pitchShiftSemitones: Float { didSet { save() } }
    @Published var pitchVariation: Float { didSet { save() } }
    @Published var sampleVariation: Bool { didSet { save() } }
    @Published var bassBoost: Float { didSet { save() } }
    @Published var brightness: Float { didSet { save() } }
    @Published var echoAmount: Float { didSet { save() } }
    @Published var roomAmount: Float { didSet { save() } }
    @Published var limiterEnabled: Bool { didSet { save() } }
    @Published var autoDuckingEnabled: Bool { didSet { save() } }
    @Published var releaseSoundsEnabled: Bool { didSet { save() } }
    @Published var modifierSoundsEnabled: Bool { didSet { save() } }
    @Published var repeatMode: RepeatMode { didSet { save() } }
    @Published var maxRepeatSoundsPerSecond: Double { didSet { save() } }
    @Published var launchAtLogin: Bool { didSet { save(); applyLaunchAtLogin() } }
    @Published var showDockIcon: Bool { didSet { save(); applyDockPolicy() } }
    @Published var menuBarAnimation: Bool { didSet { save() } }
    @Published var globalMuteHotkeyEnabled: Bool { didSet { save() } }
    @Published var globalMuteHotkey: GlobalMuteHotkey { didSet { save() } }
    @Published var quietHoursEnabled: Bool { didSet { save() } }
    @Published var quietHoursStartMinutes: Int { didSet { save() } }
    @Published var quietHoursEndMinutes: Int { didSet { save() } }
    @Published var quietHoursLowerVolume: Bool { didSet { save() } }
    @Published var quietHoursVolume: Float { didSet { save() } }
    @Published var temporaryMuteUntil: Date? { didSet { save() } }
    @Published var onboardingCompletedVersion: String? { didSet { save(); applyDockPolicy() } }
    @Published var hideBluetoothWarning: Bool { didSet { save() } }
    @Published var keySampleOverrides: [String: [String: Int]] { didSet { save() } }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let snapshot = Self.loadSnapshot(defaults: defaults, key: defaultsKey)
        appEnabled = snapshot.appEnabled
        currentPackId = snapshot.currentPackId
        masterVolume = snapshot.masterVolume
        pressVolume = snapshot.pressVolume
        releaseVolume = snapshot.releaseVolume
        spacebarVolume = snapshot.spacebarVolume
        modifierVolume = snapshot.modifierVolume
        pitchShiftSemitones = snapshot.pitchShiftSemitones ?? 0
        pitchVariation = snapshot.pitchVariation
        sampleVariation = snapshot.sampleVariation
        bassBoost = snapshot.bassBoost
        brightness = snapshot.brightness
        echoAmount = snapshot.echoAmount ?? 0
        roomAmount = snapshot.roomAmount
        limiterEnabled = snapshot.limiterEnabled
        autoDuckingEnabled = snapshot.autoDuckingEnabled ?? false
        releaseSoundsEnabled = snapshot.releaseSoundsEnabled
        modifierSoundsEnabled = snapshot.modifierSoundsEnabled
        repeatMode = snapshot.repeatMode
        maxRepeatSoundsPerSecond = snapshot.maxRepeatSoundsPerSecond
        launchAtLogin = snapshot.launchAtLogin
        showDockIcon = snapshot.showDockIcon
        menuBarAnimation = snapshot.menuBarAnimation
        globalMuteHotkeyEnabled = snapshot.globalMuteHotkeyEnabled ?? true
        globalMuteHotkey = snapshot.globalMuteHotkey ?? .controlOptionEscape
        quietHoursEnabled = snapshot.quietHoursEnabled
        quietHoursStartMinutes = snapshot.quietHoursStartMinutes
        quietHoursEndMinutes = snapshot.quietHoursEndMinutes
        quietHoursLowerVolume = snapshot.quietHoursLowerVolume
        quietHoursVolume = snapshot.quietHoursVolume
        temporaryMuteUntil = snapshot.temporaryMuteUntil
        onboardingCompletedVersion = snapshot.onboardingCompletedVersion
        hideBluetoothWarning = snapshot.hideBluetoothWarning
        keySampleOverrides = snapshot.keySampleOverrides ?? [:]
        migrateDryDefaultMixer()
        migrateDefaultVolume()

        DispatchQueue.main.async { [weak self] in
            self?.applyDockPolicy()
        }
    }

    var snapshot: SettingsSnapshot {
        SettingsSnapshot(
            appEnabled: appEnabled,
            currentPackId: currentPackId,
            masterVolume: masterVolume,
            pressVolume: pressVolume,
            releaseVolume: releaseVolume,
            spacebarVolume: spacebarVolume,
            modifierVolume: modifierVolume,
            pitchShiftSemitones: pitchShiftSemitones,
            pitchVariation: pitchVariation,
            sampleVariation: sampleVariation,
            bassBoost: bassBoost,
            brightness: brightness,
            echoAmount: echoAmount,
            roomAmount: roomAmount,
            limiterEnabled: limiterEnabled,
            autoDuckingEnabled: autoDuckingEnabled,
            releaseSoundsEnabled: releaseSoundsEnabled,
            modifierSoundsEnabled: modifierSoundsEnabled,
            repeatMode: repeatMode,
            maxRepeatSoundsPerSecond: maxRepeatSoundsPerSecond,
            launchAtLogin: launchAtLogin,
            showDockIcon: showDockIcon,
            menuBarAnimation: menuBarAnimation,
            globalMuteHotkeyEnabled: globalMuteHotkeyEnabled,
            globalMuteHotkey: globalMuteHotkey,
            quietHoursEnabled: quietHoursEnabled,
            quietHoursStartMinutes: quietHoursStartMinutes,
            quietHoursEndMinutes: quietHoursEndMinutes,
            quietHoursLowerVolume: quietHoursLowerVolume,
            quietHoursVolume: quietHoursVolume,
            temporaryMuteUntil: temporaryMuteUntil,
            onboardingCompletedVersion: onboardingCompletedVersion,
            hideBluetoothWarning: hideBluetoothWarning,
            keySampleOverrides: keySampleOverrides
        )
    }

    func completeOnboarding() {
        onboardingCompletedVersion = "1.0.0"
        showDockIcon = false
    }

    func clearTemporaryMute() {
        temporaryMuteUntil = nil
    }

    func mute(for interval: TimeInterval) {
        temporaryMuteUntil = Date().addingTimeInterval(interval)
    }

    func muteUntilTomorrow() {
        let calendar = Calendar.current
        let startOfTomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date())
        temporaryMuteUntil = startOfTomorrow.addingTimeInterval(8 * 60 * 60)
    }

    func resetMixer() {
        masterVolume = 0.25
        pressVolume = 1.0
        releaseVolume = 0.35
        spacebarVolume = 1.15
        modifierVolume = 0.3
        pitchShiftSemitones = 0
        pitchVariation = 0.02
        sampleVariation = true
        bassBoost = 0
        brightness = 0
        echoAmount = 0
        roomAmount = 0
        limiterEnabled = true
        autoDuckingEnabled = false
        releaseSoundsEnabled = false
        modifierSoundsEnabled = true
        repeatMode = .reduced
        maxRepeatSoundsPerSecond = 10
    }

    func resetAll() {
        let fresh = SettingsSnapshot()
        appEnabled = fresh.appEnabled
        currentPackId = fresh.currentPackId
        masterVolume = fresh.masterVolume
        pressVolume = fresh.pressVolume
        releaseVolume = fresh.releaseVolume
        spacebarVolume = fresh.spacebarVolume
        modifierVolume = fresh.modifierVolume
        pitchShiftSemitones = fresh.pitchShiftSemitones ?? 0
        pitchVariation = fresh.pitchVariation
        sampleVariation = fresh.sampleVariation
        bassBoost = fresh.bassBoost
        brightness = fresh.brightness
        echoAmount = fresh.echoAmount ?? 0
        roomAmount = fresh.roomAmount
        limiterEnabled = fresh.limiterEnabled
        autoDuckingEnabled = fresh.autoDuckingEnabled ?? false
        releaseSoundsEnabled = fresh.releaseSoundsEnabled
        modifierSoundsEnabled = fresh.modifierSoundsEnabled
        repeatMode = fresh.repeatMode
        maxRepeatSoundsPerSecond = fresh.maxRepeatSoundsPerSecond
        launchAtLogin = fresh.launchAtLogin
        showDockIcon = fresh.showDockIcon
        menuBarAnimation = fresh.menuBarAnimation
        globalMuteHotkeyEnabled = fresh.globalMuteHotkeyEnabled ?? true
        globalMuteHotkey = fresh.globalMuteHotkey ?? .controlOptionEscape
        quietHoursEnabled = fresh.quietHoursEnabled
        quietHoursStartMinutes = fresh.quietHoursStartMinutes
        quietHoursEndMinutes = fresh.quietHoursEndMinutes
        quietHoursLowerVolume = fresh.quietHoursLowerVolume
        quietHoursVolume = fresh.quietHoursVolume
        temporaryMuteUntil = fresh.temporaryMuteUntil
        onboardingCompletedVersion = fresh.onboardingCompletedVersion
        hideBluetoothWarning = fresh.hideBluetoothWarning
        keySampleOverrides = fresh.keySampleOverrides ?? [:]
    }

    func keySampleOverride(packId: String, keyCode: Int) -> Int? {
        keySampleOverrides[packId]?[String(keyCode)]
    }

    func setKeySampleOverride(packId: String, keyCode: Int, sampleIndex: Int) {
        var packOverrides = keySampleOverrides[packId] ?? [:]
        packOverrides[String(keyCode)] = sampleIndex
        keySampleOverrides[packId] = packOverrides
    }

    func clearKeySampleOverride(packId: String, keyCode: Int) {
        guard var packOverrides = keySampleOverrides[packId] else { return }
        packOverrides.removeValue(forKey: String(keyCode))
        if packOverrides.isEmpty {
            keySampleOverrides.removeValue(forKey: packId)
        } else {
            keySampleOverrides[packId] = packOverrides
        }
    }

    func clearKeySampleOverrides(packId: String) {
        keySampleOverrides.removeValue(forKey: packId)
    }

    func exportSettings() throws -> URL {
        let data = try JSONEncoder.pretty.encode(snapshot)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("KeyThockSettings")
            .appendingPathExtension("json")
        try data.write(to: url, options: .atomic)
        return url
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: defaultsKey)
    }

    private func migrateDryDefaultMixer() {
        if !defaults.bool(forKey: dryDefaultMixerMigrationKey) {
            if abs(roomAmount - 0.05) < 0.001 {
                roomAmount = 0
            }
            if releaseSoundsEnabled && abs(releaseVolume - 0.35) < 0.001 {
                releaseSoundsEnabled = false
            }
            defaults.set(true, forKey: dryDefaultMixerMigrationKey)
        }

        guard !defaults.bool(forKey: drySmallRoomMigrationKey) else { return }
        if roomAmount > 0 && roomAmount <= 0.05 {
            roomAmount = 0
        }
        defaults.set(true, forKey: drySmallRoomMigrationKey)
    }

    private func migrateDefaultVolume() {
        guard !defaults.bool(forKey: defaultVolumeMigrationKey) else { return }
        masterVolume = 0.25
        defaults.set(true, forKey: defaultVolumeMigrationKey)
    }

    private static func loadSnapshot(defaults: UserDefaults, key: String) -> SettingsSnapshot {
        guard let data = defaults.data(forKey: key),
              let snapshot = try? JSONDecoder().decode(SettingsSnapshot.self, from: data) else {
            return SettingsSnapshot()
        }
        return snapshot
    }

    private func applyLaunchAtLogin() {
        do {
            if launchAtLogin {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("KeyThock launch-at-login update failed: \(error.localizedDescription)")
        }
    }

    private func applyDockPolicy() {
        let shouldShowDock = showDockIcon || onboardingCompletedVersion == nil
        NSApp.setActivationPolicy(shouldShowDock ? .regular : .accessory)
    }
}

extension JSONEncoder {
    static var pretty: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}
