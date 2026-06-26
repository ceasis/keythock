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
        profiles.append(makeProfile(
            bundleId: bundleId,
            displayName: displayName,
            recipe: packId == nil ? .defaultSound : .custom,
            packId: packId
        ))
        saveProfiles()
    }

    func addSuggestedRecipes() {
        for suggestion in Self.suggestedRecipes {
            addRecipeApp(
                bundleId: suggestion.bundleId,
                displayName: suggestion.displayName,
                recipe: suggestion.recipe,
                replaceExisting: false
            )
        }
    }

    func applyRecipe(_ recipe: AppSoundRecipe, to profile: AppProfile) {
        guard recipe != .custom,
              let index = profiles.firstIndex(where: { $0.id == profile.id }) else { return }
        profiles[index].mute = recipe.mutes
        profiles[index].soundPackId = recipe.soundPackId
        profiles[index].behavior = recipe.rawValue
        if recipe == .defaultSound {
            profiles[index].volume = nil
        }
        saveProfiles()
    }

    private func addRecipeApp(
        bundleId: String,
        displayName: String,
        recipe: AppSoundRecipe,
        replaceExisting: Bool
    ) {
        guard bundleId != Bundle.main.bundleIdentifier else { return }
        if let index = profiles.firstIndex(where: { $0.bundleId == bundleId }) {
            guard replaceExisting else { return }
            profiles[index] = makeProfile(bundleId: bundleId, displayName: displayName, recipe: recipe)
        } else {
            profiles.append(makeProfile(bundleId: bundleId, displayName: displayName, recipe: recipe))
        }
        saveProfiles()
    }

    private func makeProfile(
        bundleId: String,
        displayName: String,
        recipe: AppSoundRecipe,
        packId: String? = nil
    ) -> AppProfile {
        AppProfile(
            id: "profile-\(bundleId)",
            bundleId: bundleId,
            displayName: displayName,
            enabled: true,
            behavior: recipe.rawValue,
            soundPackId: packId ?? recipe.soundPackId,
            volume: nil,
            mute: recipe.mutes,
            repeatMode: .reduced,
            notes: ""
        )
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
        profiles[index].mute = false
        profiles[index].behavior = packId == nil ? AppSoundRecipe.defaultSound.rawValue : AppSoundRecipe.custom.rawValue
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

    private static let suggestedRecipes: [SuggestedAppRecipe] = [
        .init(bundleId: "com.apple.Notes", displayName: "Notes", recipe: .creamyWriting),
        .init(bundleId: "com.apple.TextEdit", displayName: "TextEdit", recipe: .creamyWriting),
        .init(bundleId: "com.apple.Pages", displayName: "Pages", recipe: .creamyWriting),
        .init(bundleId: "com.literatureandlatte.scrivener3", displayName: "Scrivener", recipe: .creamyWriting),
        .init(bundleId: "com.microsoft.VSCode", displayName: "Visual Studio Code", recipe: .clickyCoding),
        .init(bundleId: "com.apple.dt.Xcode", displayName: "Xcode", recipe: .clickyCoding),
        .init(bundleId: "com.jetbrains.intellij", displayName: "IntelliJ IDEA", recipe: .clickyCoding),
        .init(bundleId: "com.jetbrains.WebStorm", displayName: "WebStorm", recipe: .clickyCoding),
        .init(bundleId: "us.zoom.xos", displayName: "Zoom", recipe: .mutedCalls),
        .init(bundleId: "com.microsoft.teams2", displayName: "Microsoft Teams", recipe: .mutedCalls),
        .init(bundleId: "com.microsoft.teams", displayName: "Microsoft Teams Classic", recipe: .mutedCalls),
        .init(bundleId: "com.apple.FaceTime", displayName: "FaceTime", recipe: .mutedCalls),
        .init(bundleId: "com.hnc.Discord", displayName: "Discord", recipe: .mutedCalls),
        .init(bundleId: "Cisco-Systems.Spark", displayName: "Webex", recipe: .mutedCalls)
    ]
}

private struct SuggestedAppRecipe {
    let bundleId: String
    let displayName: String
    let recipe: AppSoundRecipe
}
