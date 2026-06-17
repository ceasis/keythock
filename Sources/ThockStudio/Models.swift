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

enum PermissionState: String, Codable {
    case notDetermined
    case denied
    case approved
    case unknownOrBlocked

    var label: String {
        switch self {
        case .notDetermined: return "Permission needed"
        case .denied: return "Permission denied"
        case .approved: return "Permission approved"
        case .unknownOrBlocked: return "Keyboard events blocked"
        }
    }
}

enum SettingsTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case soundPacks = "Sound Packs"
    case mixer = "Mixer"
    case keySounds = "Keys"
    case appProfiles = "App Profiles"
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
        case .appProfiles: return "app.badge"
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
    let flagsRawValue: UInt64
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

struct SettingsSnapshot: Codable {
    var appEnabled: Bool = true
    var currentPackId: String = "com.thockstudio.pack.creamy2.recording"
    var masterVolume: Float = 0.55
    var pressVolume: Float = 1.0
    var releaseVolume: Float = 0.35
    var spacebarVolume: Float = 1.15
    var modifierVolume: Float = 0.3
    var pitchShiftSemitones: Float? = 0
    var pitchVariation: Float = 0.02
    var sampleVariation: Bool = true
    var bassBoost: Float = 0
    var brightness: Float = 0
    var roomAmount: Float = 0.05
    var limiterEnabled: Bool = true
    var releaseSoundsEnabled: Bool = true
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
    var temporaryMuteUntil: Date?
    var onboardingCompletedVersion: String?
    var hideBluetoothWarning: Bool = false
    var keySampleOverrides: [String: [String: Int]]?
}
