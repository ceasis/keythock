import XCTest
@testable import KeyThock

final class KeyThockLogicTests: XCTestCase {
    func testKeyClassifierMapsCommonKeys() {
        XCTAssertEqual(KeyClassifier.classify(keyCode: 0), .alpha)
        XCTAssertEqual(KeyClassifier.classify(keyCode: 18), .number)
        XCTAssertEqual(KeyClassifier.classify(keyCode: 49), .space)
        XCTAssertEqual(KeyClassifier.classify(keyCode: 36), .enter)
        XCTAssertEqual(KeyClassifier.classify(keyCode: 51), .backspace)
        XCTAssertEqual(KeyClassifier.classify(keyCode: 123), .arrow)
        XCTAssertEqual(KeyClassifier.classify(keyCode: -1), .unknown)
    }

    func testMorseCodeMapsLettersNumbersAndWordGap() {
        XCTAssertEqual(MorseCode.pattern(forKeyCode: 0), ".-")
        XCTAssertEqual(MorseCode.pattern(forKeyCode: 1), "...")
        XCTAssertEqual(MorseCode.pattern(forKeyCode: 29), "-----")
        XCTAssertTrue(MorseCode.isWordGapKey(49))
        XCTAssertFalse(MorseCode.isWordGapKey(0))
    }

    func testCharacterLookupUsesPhysicalKeyCodes() {
        XCTAssertEqual(KeyClassifier.keyCode(for: "a"), 0)
        XCTAssertEqual(KeyClassifier.keyCode(for: "A"), 0)
        XCTAssertEqual(KeyClassifier.keyCode(for: "s"), 1)
        XCTAssertEqual(KeyClassifier.keyCode(for: " "), 49)
        XCTAssertEqual(KeyClassifier.keyCode(for: "1"), 18)
        XCTAssertNil(KeyClassifier.keyCode(for: "ß"))
    }

    func testStableSampleAssignmentKeepsSameKeyOnSameSample() {
        XCTAssertEqual(SampleAssignment.stableIndex(keyCode: 0, sampleCount: 8), 0)
        XCTAssertEqual(SampleAssignment.stableIndex(keyCode: 0, sampleCount: 8), 0)
        XCTAssertEqual(SampleAssignment.stableIndex(keyCode: 9, sampleCount: 8), 7)
        XCTAssertEqual(SampleAssignment.stableIndex(keyCode: -1, sampleCount: 8), 1)
        XCTAssertNil(SampleAssignment.stableIndex(keyCode: 0, sampleCount: 0))
    }

    func testStableSampleAssignmentCanBeShuffledWithSeed() {
        XCTAssertEqual(SampleAssignment.stableIndex(keyCode: 0, sampleCount: 8, seed: 0), 0)
        XCTAssertEqual(SampleAssignment.stableIndex(keyCode: 0, sampleCount: 8, seed: 3), 3)
        XCTAssertEqual(SampleAssignment.stableIndex(keyCode: 9, sampleCount: 8, seed: 3), 2)
    }

    func testCreamy2ExcludesBrokenFourthSample() {
        let pack = BuiltInPacks.all.first { $0.id == "com.keythock.pack.creamy2.recording" }
        let samples = pack?.source.manifest.samples[KeyCategory.alpha.rawValue]?.press ?? []

        XCTAssertEqual(pack?.name, "Creamy-2")
        XCTAssertFalse(samples.contains("samples/alpha/press_04.wav"))
        XCTAssertEqual(samples.count, 15)
    }

    func testCreamy3IsNotBundled() {
        XCTAssertFalse(BuiltInPacks.all.contains { $0.id == "com.keythock.pack.creamy3.recording" })
        XCTAssertFalse(BuiltInPacks.all.contains { $0.name == "Creamy-3" })
    }

    func testClacky2IsNotBundled() {
        XCTAssertFalse(BuiltInPacks.all.contains { $0.id == "com.keythock.pack.clacky2.recording" })
        XCTAssertFalse(BuiltInPacks.all.contains { $0.name == "Clacky-2" })
    }

    func testCustomMixerPresetCapturesSettingsSnapshot() {
        var snapshot = SettingsSnapshot()
        snapshot.masterVolume = 0.42
        snapshot.pressVolume = 0.87
        snapshot.releaseVolume = 0.21
        snapshot.pitchShiftSemitones = -1.5
        snapshot.pitchVariation = 0.03
        snapshot.bassBoost = 0.4
        snapshot.brightness = -0.2
        snapshot.echoAmount = 0.12
        snapshot.roomAmount = 0.09
        snapshot.autoDuckingEnabled = true
        snapshot.samplePlaybackMode = .randomEveryPress
        snapshot.repeatMode = .firstOnly
        snapshot.maxRepeatSoundsPerSecond = 6

        let preset = CustomMixerPreset(name: "Late Night", snapshot: snapshot)

        XCTAssertEqual(preset.name, "Late Night")
        XCTAssertEqual(preset.masterVolume, 0.42, accuracy: 0.001)
        XCTAssertEqual(preset.pressVolume, 0.87, accuracy: 0.001)
        XCTAssertEqual(preset.releaseVolume, 0.21, accuracy: 0.001)
        XCTAssertEqual(preset.pitchShiftSemitones, -1.5, accuracy: 0.001)
        XCTAssertEqual(preset.pitchVariation, 0.03, accuracy: 0.001)
        XCTAssertEqual(preset.bassBoost, 0.4, accuracy: 0.001)
        XCTAssertEqual(preset.brightness, -0.2, accuracy: 0.001)
        XCTAssertEqual(preset.echoAmount, 0.12, accuracy: 0.001)
        XCTAssertEqual(preset.roomAmount, 0.09, accuracy: 0.001)
        XCTAssertTrue(preset.autoDuckingEnabled)
        XCTAssertEqual(preset.samplePlaybackMode, .randomEveryPress)
        XCTAssertEqual(preset.repeatMode, .firstOnly)
        XCTAssertEqual(preset.maxRepeatSoundsPerSecond, 6, accuracy: 0.001)
    }

    func testAppSoundRecipeInference() {
        let defaultProfile = AppProfile(
            id: "profile-default",
            bundleId: "com.example.default",
            displayName: "Default",
            enabled: true,
            behavior: "defaultSound",
            soundPackId: nil,
            volume: nil,
            mute: false,
            repeatMode: .reduced,
            notes: ""
        )
        XCTAssertEqual(AppSoundRecipe.inferred(from: defaultProfile), .defaultSound)

        var creamyProfile = defaultProfile
        creamyProfile.soundPackId = "com.keythock.pack.creamy2.recording"
        XCTAssertEqual(AppSoundRecipe.inferred(from: creamyProfile), .creamyWriting)

        var clickyProfile = defaultProfile
        clickyProfile.soundPackId = "com.keythock.pack.clicky1.recording"
        XCTAssertEqual(AppSoundRecipe.inferred(from: clickyProfile), .clickyCoding)

        var mutedProfile = defaultProfile
        mutedProfile.mute = true
        XCTAssertEqual(AppSoundRecipe.inferred(from: mutedProfile), .mutedCalls)
    }

    func testFocusDefaultsArePresent() {
        let snapshot = SettingsSnapshot()

        XCTAssertEqual(snapshot.pomodoroWorkMinutes, 25)
        XCTAssertEqual(snapshot.pomodoroBreakMinutes, 5)
        XCTAssertEqual(snapshot.characterCountdownTarget, 500)
    }
}
