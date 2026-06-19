import AppKit
import Foundation

@MainActor
final class ProfileService: ObservableObject {
    @Published private(set) var profiles: [AppProfile] = []
    @Published private(set) var activeAppName: String = "Unknown"
    @Published private(set) var activeBundleId: String?

    private let profilesKey = "appProfiles.v1"
    init() {
        loadProfiles()
        removeSuggestedDefaults()
        refreshActiveApp()
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(frontmostAppChanged),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
    }

    var enabledProfiles: [AppProfile] {
        profiles.filter(\.enabled)
    }

    func profileForActiveApp() -> AppProfile? {
        guard let activeBundleId else { return nil }
        return profiles.first { $0.enabled && $0.bundleId == activeBundleId }
    }

    func isActiveAppMuted() -> Bool {
        profileForActiveApp()?.mute == true
    }

    func addCurrentApp(packId: String?) {
        refreshActiveApp()
        guard let bundleId = activeBundleId else { return }
        guard bundleId != Bundle.main.bundleIdentifier else { return }
        addApp(bundleId: bundleId, displayName: activeAppName, packId: packId)
    }

    func addApp(from url: URL, packId: String?) {
        let bundle = Bundle(url: url)
        guard let bundleId = bundle?.bundleIdentifier else { return }
        let displayName = bundle?.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? bundle?.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? url.deletingPathExtension().lastPathComponent
        addApp(bundleId: bundleId, displayName: displayName, packId: packId)
    }

    func addApp(bundleId: String, displayName: String, packId: String?) {
        guard bundleId != Bundle.main.bundleIdentifier else { return }
        if profiles.contains(where: { $0.bundleId == bundleId }) { return }
        profiles.append(AppProfile(
            id: "profile-\(bundleId)",
            bundleId: bundleId,
            displayName: displayName,
            enabled: true,
            behavior: "custom",
            soundPackId: packId,
            volume: nil,
            mute: false,
            repeatMode: .reduced,
            notes: ""
        ))
        saveProfiles()
    }

    func toggleEnabled(_ profile: AppProfile) {
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else { return }
        profiles[index].enabled.toggle()
        saveProfiles()
    }

    func toggleMute(_ profile: AppProfile) {
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else { return }
        profiles[index].mute.toggle()
        profiles[index].behavior = profiles[index].mute ? "muted" : "custom"
        saveProfiles()
    }

    func setVolume(_ profile: AppProfile, volume: Float?) {
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else { return }
        profiles[index].volume = volume
        saveProfiles()
    }

    func setSoundPack(_ profile: AppProfile, packId: String?) {
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else { return }
        profiles[index].soundPackId = packId
        saveProfiles()
    }

    func delete(_ profile: AppProfile) {
        profiles.removeAll { $0.id == profile.id }
        saveProfiles()
    }

    func resetDefaults() {
        profiles = []
        saveProfiles()
    }

    func refreshActiveApp() {
        let app = NSWorkspace.shared.frontmostApplication
        activeAppName = app?.localizedName ?? "Unknown"
        activeBundleId = app?.bundleIdentifier
    }

    @objc private func frontmostAppChanged() {
        refreshActiveApp()
    }

    private func loadProfiles() {
        if let data = UserDefaults.standard.data(forKey: profilesKey),
           let decoded = try? JSONDecoder().decode([AppProfile].self, from: data) {
            profiles = decoded
        } else {
            profiles = Self.defaultProfiles()
            saveProfiles()
        }
    }

    private func removeSuggestedDefaults() {
        let suggestedBundleIds: Set<String> = [
            "us.zoom.xos",
            "com.microsoft.teams2",
            "com.microsoft.teams",
            "com.apple.FaceTime",
            "com.hnc.Discord",
            "Cisco-Systems.Spark",
            "com.apple.QuickTimePlayerX"
        ]
        let originalCount = profiles.count
        profiles.removeAll { profile in
            suggestedBundleIds.contains(profile.bundleId)
                && profile.behavior == "muted"
                && profile.notes == "Suggested meeting mute rule"
        }
        if profiles.count != originalCount {
            saveProfiles()
        }
    }

    private func saveProfiles() {
        guard let data = try? JSONEncoder.pretty.encode(profiles) else { return }
        UserDefaults.standard.set(data, forKey: profilesKey)
    }

    private static func defaultProfiles() -> [AppProfile] {
        []
    }
}
