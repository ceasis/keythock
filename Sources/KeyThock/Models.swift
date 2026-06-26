import Foundation

enum KeyCategory: String, Codable, CaseIterable, Identifiable {
    case alpha
    case number
    case punctuation
    case space
    case enter
    case backspace
    case tab
    case escape
    case arrow
    case modifier
    case function
    case numpad
    case unknown

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .alpha: return "Letters"
        case .number: return "Numbers"
        case .punctuation: return "Punctuation"
        case .space: return "Spacebar"
        case .enter: return "Enter"
        case .backspace: return "Backspace"
        case .tab: return "Tab"
        case .escape: return "Escape"
        case .arrow: return "Arrows"
        case .modifier: return "Modifiers"
        case .function: return "Function"
        case .numpad: return "Numpad"
        case .unknown: return "Other"
        }
    }

    var weight: Float {
        switch self {
        case .space: return 1.2
        case .enter: return 1.08
        case .backspace: return 0.92
        case .modifier: return 0.3
        case .arrow: return 0.72
        case .function: return 0.62
        case .escape: return 0.7
        default: return 1.0
        }
    }
}

enum KeyPhase: String, Codable {
    case down
    case up
    case modifierChanged

    var samplePhase: SamplePhase {
        switch self {
        case .down, .modifierChanged: return .press
        case .up: return .release
        }
    }
}

enum SamplePhase: String, Codable, CaseIterable, Identifiable {
    case press
    case release

    var id: String { rawValue }
}

enum RepeatMode: String, Codable, CaseIterable, Identifiable {
    case reduced
    case firstOnly
    case all
    case off

    var id: String { rawValue }

    var label: String {
        switch self {
        case .reduced: return "Reduced repeats"
        case .firstOnly: return "First press only"
        case .all: return "Every repeat"
        case .off: return "No repeat sounds"
        }
    }
}

enum SamplePlaybackMode: String, Codable, CaseIterable, Identifiable {
    case stablePerKey
    case singleSample
    case randomEveryPress

    var id: String { rawValue }

    var label: String {
        switch self {
        case .stablePerKey: return "Per Key"
        case .singleSample: return "Single"
        case .randomEveryPress: return "Random"
        }
    }

    var helpText: String {
        switch self {
        case .stablePerKey:
            return "Different keys can use different samples; the same key stays consistent."
        case .singleSample:
            return "Every unassigned key uses the first sample."
        case .randomEveryPress:
            return "Every press can choose a different sample."
        }
    }

    var usesMultipleSamples: Bool {
        self != .singleSample
    }
}

enum AppSoundRecipe: String, CaseIterable, Identifiable {
    case defaultSound
    case creamyWriting
    case clickyCoding
    case mutedCalls
    case custom

    var id: String { rawValue }

    var label: String {
        switch self {
        case .defaultSound: return "Default"
        case .creamyWriting: return "Creamy"
        case .clickyCoding: return "Clicky"
        case .mutedCalls: return "Muted"
        case .custom: return "Custom"
        }
    }

    var title: String {
        switch self {
        case .defaultSound: return "Use Default"
        case .creamyWriting: return "Creamy Writing"
        case .clickyCoding: return "Clicky Coding"
        case .mutedCalls: return "Mute Calls"
        case .custom: return "Custom Recipe"
        }
    }

    var symbolName: String {
        switch self {
        case .defaultSound: return "speaker.wave.2"
        case .creamyWriting: return "text.cursor"
        case .clickyCoding: return "chevron.left.forwardslash.chevron.right"
        case .mutedCalls: return "video.slash"
        case .custom: return "slider.horizontal.3"
        }
    }

    var soundPackId: String? {
        switch self {
        case .creamyWriting:
            return "com.keythock.pack.creamy2.recording"
        case .clickyCoding:
            return "com.keythock.pack.clicky1.recording"
        case .defaultSound, .mutedCalls, .custom:
            return nil
        }
    }

    var mutes: Bool {
        self == .mutedCalls
    }

    static func inferred(from profile: AppProfile) -> AppSoundRecipe {
        if profile.mute { return .mutedCalls }
        switch profile.soundPackId {
        case nil:
            return .defaultSound
        case "com.keythock.pack.creamy2.recording", "com.keythock.pack.creamykeyboard.recording":
            return .creamyWriting
        case "com.keythock.pack.clicky1.recording", "com.keythock.pack.clacky1.recording":
            return .clickyCoding
        default:
            return .custom
        }
    }
}

enum PomodoroPhase: String, Codable {
    case idle
    case work
    case breakTime

    var label: String {
        switch self {
        case .idle: return "Ready"
        case .work: return "Focus"
        case .breakTime: return "Break"
        }
    }

    var symbolName: String {
        switch self {
        case .idle: return "timer"
        case .work: return "brain.head.profile"
        case .breakTime: return "cup.and.saucer"
        }
    }
}

enum PermissionState: String, Codable {
    case notDetermined
    case denied
    case approved
    case unknownOrBlocked

    var label: String {
        switch self {
        case .notDetermined: return "Input Monitoring needed"
        case .denied: return "Input Monitoring denied"
        case .approved: return "Keyboard access ready"
        case .unknownOrBlocked: return "Keyboard access blocked"
        }
    }
}

enum SettingsTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case soundPacks = "Sound Packs"
    case mixer = "Mixer"
    case keySounds = "Keys"
    case appProfiles = "Recipes"
    case focus = "Focus"
    case diagnostics = "Diagnostics"
    case privacy = "Privacy"
    case settings = "Settings"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .home: return "house"
        case .soundPacks: return "waveform"
        case .mixer: return "slider.horizontal.3"
        case .keySounds: return "keyboard"
        case .appProfiles: return "paintpalette"
        case .focus: return "timer"
        case .diagnostics: return "stethoscope"
        case .privacy: return "lock.shield"
        case .settings: return "gearshape"
        }
    }
}

enum GlobalMuteHotkey: String, Codable, CaseIterable, Identifiable {
    case controlOptionEscape
    case controlEscape
    case commandEscape
    case controlOptionK
    case commandShiftM

    var id: String { rawValue }

    var label: String {
        switch self {
        case .controlOptionEscape: return "Control + Option + Escape"
        case .controlEscape: return "Control + Escape"
        case .commandEscape: return "Command + Escape"
        case .controlOptionK: return "Control + Option + K"
        case .commandShiftM: return "Command + Shift + M"
        }
    }

    var keyCode: Int {
        switch self {
        case .controlOptionEscape, .controlEscape, .commandEscape:
            return 53
        case .controlOptionK:
            return 40
        case .commandShiftM:
            return 46
        }
    }

    var requiresControl: Bool {
        self == .controlOptionEscape || self == .controlEscape || self == .controlOptionK
    }

    var requiresOption: Bool {
        self == .controlOptionEscape || self == .controlOptionK
    }

    var requiresCommand: Bool {
        self == .commandEscape || self == .commandShiftM
    }

    var requiresShift: Bool {
        self == .commandShiftM
    }
}

struct KeyEvent: Equatable {
    let keyCode: Int
    let category: KeyCategory
    let phase: KeyPhase
    let isRepeat: Bool
    let timestamp: TimeInterval
    let flagsRawValue: UInt
    let sourceAppBundleId: String?
}

struct SoundPlaybackRequest {
    let packId: String
    let keyCategory: KeyCategory
    let phase: KeyPhase
    let volume: Float
    let pitchShiftSemitones: Float
    let pitchVariation: Float
    let sampleVariation: Bool
    let sampleIndexOverride: Int?
    let timestamp: TimeInterval
    let appProfileId: String?
}

struct SampleBufferKey: Hashable {
    var category: KeyCategory
    var phase: SamplePhase
}

struct SoundPack: Identifiable {
    let id: String
    let name: String
    let category: String
    let loudness: String
    let tone: String
    let bestFor: String
    let description: String
    let isPremium: Bool
    let recommendedVolume: Float
    let pitchVariationDefault: Float
    let sampleVariationDefault: Bool
    let supportsPress: Bool
    let supportsRelease: Bool
    let source: SoundPackSource

    var searchText: String {
        [name, category, loudness, tone, bestFor, description].joined(separator: " ").lowercased()
    }

    func sampleCount(for category: KeyCategory, phase: SamplePhase = .press) -> Int {
        let sampleManifest = source.manifest.samples[category.rawValue] ?? source.manifest.samples[KeyCategory.alpha.rawValue]
        switch phase {
        case .press:
            return sampleManifest?.press?.count ?? 0
        case .release:
            return sampleManifest?.release?.count ?? sampleManifest?.press?.count ?? 0
        }
    }
}

enum SoundPackSource {
    case bundled(resourcePath: String, manifest: SoundPackManifest)
    case imported(baseURL: URL, manifest: SoundPackManifest)

    var manifest: SoundPackManifest {
        switch self {
        case let .bundled(_, manifest), let .imported(_, manifest):
            return manifest
        }
    }
}

struct SoundPackManifest: Codable {
    var schemaVersion: Int
    var packId: String
    var name: String
    var version: String
    var author: String?
    var category: String
    var tone: String
    var loudness: String
    var description: String
    var isPremium: Bool?
    var supportsPress: Bool?
    var supportsRelease: Bool?
    var recommendedVolume: Float?
    var pitchVariationDefault: Float?
    var sampleVariationDefault: Bool?
    var artwork: String?
    var preview: String?
    var samples: [String: PackSampleManifest]
}

struct PackSampleManifest: Codable {
    var press: [String]?
    var release: [String]?
}

struct AppProfile: Identifiable, Codable, Equatable {
    var id: String
    var bundleId: String
    var displayName: String
    var enabled: Bool
    var behavior: String
    var soundPackId: String?
    var volume: Float?
    var mute: Bool
    var repeatMode: RepeatMode
    var notes: String
}

struct CustomMixerPreset: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var name: String
    var createdAt: Date = Date()
    var masterVolume: Float
    var pressVolume: Float
    var releaseVolume: Float
    var spacebarVolume: Float
    var modifierVolume: Float
    var pitchShiftSemitones: Float
    var pitchVariation: Float
    var sampleVariation: Bool
    var samplePlaybackMode: SamplePlaybackMode?
    var bassBoost: Float
    var brightness: Float
    var echoAmount: Float
    var roomAmount: Float
    var limiterEnabled: Bool
    var autoDuckingEnabled: Bool
    var releaseSoundsEnabled: Bool
    var modifierSoundsEnabled: Bool
    var repeatMode: RepeatMode
    var maxRepeatSoundsPerSecond: Double

    init(name: String, snapshot: SettingsSnapshot) {
        self.name = name
        masterVolume = snapshot.masterVolume
        pressVolume = snapshot.pressVolume
        releaseVolume = snapshot.releaseVolume
        spacebarVolume = snapshot.spacebarVolume
        modifierVolume = snapshot.modifierVolume
        pitchShiftSemitones = snapshot.pitchShiftSemitones ?? 0
        pitchVariation = snapshot.pitchVariation
        sampleVariation = snapshot.sampleVariation
        samplePlaybackMode = snapshot.resolvedSamplePlaybackMode
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
    }
}

struct SoundPackImportReport: Identifiable, Equatable {
    var id: String
    var packName: String
    var sampleCount: Int
    var pressSampleCount: Int
    var releaseSampleCount: Int
    var categories: [String]
    var missingReleaseCategories: [String]
}

enum SampleAssignment {
    static func stableIndex(keyCode: Int, sampleCount: Int, seed: Int = 0) -> Int? {
        guard sampleCount > 0 else { return nil }
        let remainder = (keyCode &* 31 &+ seed) % sampleCount
        return remainder >= 0 ? remainder : remainder + sampleCount
    }
}

struct SettingsSnapshot: Codable {
    var appEnabled: Bool = true
    var currentPackId: String = "com.keythock.pack.creamy2.recording"
    var masterVolume: Float = 0.25
    var pressVolume: Float = 1.0
    var releaseVolume: Float = 0.35
    var spacebarVolume: Float = 1.15
    var modifierVolume: Float = 0.3
    var pitchShiftSemitones: Float? = 0
    var pitchVariation: Float = 0.02
    var sampleVariation: Bool = true
    var samplePlaybackMode: SamplePlaybackMode? = .stablePerKey
    var sampleShuffleSeed: Int? = 0
    var bassBoost: Float = 0
    var brightness: Float = 0
    var echoAmount: Float? = 0
    var roomAmount: Float = 0
    var limiterEnabled: Bool = true
    var autoDuckingEnabled: Bool? = false
    var releaseSoundsEnabled: Bool = false
    var modifierSoundsEnabled: Bool = true
    var repeatMode: RepeatMode = .reduced
    var maxRepeatSoundsPerSecond: Double = 10
    var launchAtLogin: Bool = false
    var showDockIcon: Bool = true
    var menuBarAnimation: Bool = true
    var globalMuteHotkeyEnabled: Bool? = true
    var globalMuteHotkey: GlobalMuteHotkey? = .controlOptionEscape
    var quietHoursEnabled: Bool = false
    var quietHoursStartMinutes: Int = 22 * 60
    var quietHoursEndMinutes: Int = 7 * 60
    var quietHoursLowerVolume: Bool = false
    var quietHoursVolume: Float = 0.2
    var pomodoroWorkMinutes: Int? = 25
    var pomodoroBreakMinutes: Int? = 5
    var characterCountdownTarget: Int? = 500
    var temporaryMuteUntil: Date?
    var onboardingCompletedVersion: String?
    var hideBluetoothWarning: Bool = false
    var keySampleOverrides: [String: [String: Int]]?

    var resolvedSamplePlaybackMode: SamplePlaybackMode {
        samplePlaybackMode ?? (sampleVariation ? .stablePerKey : .singleSample)
    }
}
