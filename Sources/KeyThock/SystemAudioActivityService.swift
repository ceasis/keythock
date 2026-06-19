import AppKit
import CoreAudio
import Foundation

@MainActor
final class SystemAudioActivityService: ObservableObject {
    @Published private(set) var isOtherAudioPlaying = false
    @Published private(set) var lastCheckedDate: Date?

    private var lastRefreshDate = Date.distantPast
    private let minimumRefreshInterval: TimeInterval = 0.45

    func refreshIfNeeded(force: Bool = false) {
        guard force || Date().timeIntervalSince(lastRefreshDate) >= minimumRefreshInterval else { return }
        lastRefreshDate = Date()
        lastCheckedDate = lastRefreshDate
        isOtherAudioPlaying = Self.detectOtherOutputAudio()
    }

    func clear() {
        isOtherAudioPlaying = false
    }

    private static func detectOtherOutputAudio() -> Bool {
        let currentPID = ProcessInfo.processInfo.processIdentifier
        let currentBundleID = Bundle.main.bundleIdentifier

        for processObjectID in audioProcessObjectIDs() {
            guard isRunningOutput(processObjectID),
                  let pid = pid(for: processObjectID),
                  pid > 0,
                  pid != currentPID else { continue }

            let bundleID = NSRunningApplication(processIdentifier: pid)?.bundleIdentifier
            if let bundleID, bundleID == currentBundleID { continue }
            if let bundleID, ignoredBundleIDs.contains(bundleID) { continue }
            if let bundleID, ignoredBundlePrefixes.contains(where: { bundleID.hasPrefix($0) }) { continue }

            return true
        }

        return false
    }

    private static let ignoredBundleIDs: Set<String> = [
        "com.apple.CoreSpeech"
    ]

    private static let ignoredBundlePrefixes = [
        "com.apple.siri",
        "com.apple.Siri"
    ]

    private static func audioProcessObjectIDs() -> [AudioObjectID] {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyProcessObjectList,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        let systemObjectID = AudioObjectID(kAudioObjectSystemObject)
        var dataSize: UInt32 = 0

        guard AudioObjectGetPropertyDataSize(systemObjectID, &address, 0, nil, &dataSize) == noErr else {
            return []
        }

        let count = Int(dataSize) / MemoryLayout<AudioObjectID>.size
        guard count > 0 else { return [] }

        var processObjectIDs = [AudioObjectID](repeating: 0, count: count)
        guard AudioObjectGetPropertyData(systemObjectID, &address, 0, nil, &dataSize, &processObjectIDs) == noErr else {
            return []
        }

        return processObjectIDs
    }

    private static func pid(for processObjectID: AudioObjectID) -> pid_t? {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioProcessPropertyPID,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var value: pid_t = 0
        var dataSize = UInt32(MemoryLayout<pid_t>.size)

        guard AudioObjectGetPropertyData(processObjectID, &address, 0, nil, &dataSize, &value) == noErr else {
            return nil
        }

        return value
    }

    private static func isRunningOutput(_ processObjectID: AudioObjectID) -> Bool {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioProcessPropertyIsRunningOutput,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var value: UInt32 = 0
        var dataSize = UInt32(MemoryLayout<UInt32>.size)

        guard AudioObjectGetPropertyData(processObjectID, &address, 0, nil, &dataSize, &value) == noErr else {
            return false
        }

        return value != 0
    }
}
