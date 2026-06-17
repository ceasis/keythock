import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct RootWindowView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        Group {
            if model.settings.onboardingCompletedVersion == nil {
                OnboardingView()
            } else {
                SettingsRootView()
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            model.refreshPermissionStatus()
        }
    }
}

struct MenuBarPopoverView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: model.menuBarSymbol)
                    .font(.title2)
                    .frame(width: 32, height: 32)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 2) {
                    Text(model.currentPack.name)
                        .font(.headline)
                    Text(model.visibleStatus)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { model.settings.appEnabled },
                    set: { model.settings.appEnabled = $0 }
                ))
                .toggleStyle(.switch)
                .labelsHidden()
            }

            SliderRow(
                title: "Volume",
                value: Binding(
                    get: { Double(model.settings.masterVolume) },
                    set: { model.settings.masterVolume = Float($0) }
                ),
                range: 0...1
            )

            Picker("Sound", selection: Binding(
                get: { model.settings.currentPackId },
                set: { model.selectPack(model.packs.pack(with: $0)) }
            )) {
                ForEach(model.packs.allPacks) { pack in
                    Text(pack.name)
                        .tag(pack.id)
                }
            }

            HStack(spacing: 8) {
                IconButton(systemName: "play.fill", title: "Preview") {
                    model.preview(model.currentPack)
                }
                IconButton(systemName: "15.circle", title: "Mute 15 minutes") {
                    model.settings.mute(for: 15 * 60)
                }
                IconButton(systemName: "30.circle", title: "Mute 30 minutes") {
                    model.settings.mute(for: 30 * 60)
                }
                IconButton(systemName: "gearshape", title: "Settings") {
                    openWindow(id: "main")
                    NSApp.activate(ignoringOtherApps: true)
                }
            }

            if model.settings.temporaryMuteUntil != nil {
                Button {
                    model.settings.clearTemporaryMute()
                } label: {
                    Label("Resume Now", systemImage: "speaker.wave.2")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }

            if model.permissions.state != .approved {
                InputMonitoringShortcutPanel(compact: true)
            }

            if let error = model.audio.lastError {
                VStack(alignment: .leading, spacing: 8) {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.red)
                    Button {
                        model.restartAudio()
                    } label: {
                        Label("Restart Audio", systemImage: "speaker.wave.2")
                            .frame(maxWidth: .infinity)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Label(model.listenerStatusText, systemImage: model.listenerState.isRunning ? "checkmark.circle" : "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(model.listenerState.isRunning ? Color.secondary : Color.orange)
                    .lineLimit(2)
                Label(model.lastKeyboardEventText, systemImage: "keyboard")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Label(model.lastTypingPlaybackDecisionText, systemImage: "speaker.wave.2")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Button {
                    model.restartKeyboardListener()
                } label: {
                    Label("Restart Keyboard Listener", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .font(.caption)
            }

            Divider()

            HStack {
                Label(
                    model.permissions.state == .approved ? "Local input access ready" : model.permissions.state.label,
                    systemImage: model.permissions.state == .approved ? "checkmark.shield" : "lock.shield"
                )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .font(.caption)
            }
        }
        .padding(16)
        .onAppear {
            model.refreshPermissionStatus()
        }
    }
}

struct SettingsRootView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationSplitView {
            List(SettingsTab.allCases, selection: Binding(
                get: { model.selectedTab },
                set: { model.selectedTab = $0 ?? .home }
            )) { tab in
                Label(tab.rawValue, systemImage: tab.symbolName)
                    .tag(tab)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    switch model.selectedTab {
                    case .home:
                        HomeView()
                    case .soundPacks:
                        SoundPacksView()
                    case .mixer:
                        MixerView()
                    case .keySounds:
                        KeySoundsView()
                    case .appProfiles:
                        AppProfilesView()
                    case .diagnostics:
                        DiagnosticsView()
                    case .privacy:
                        PrivacyView()
                    case .settings:
                        GeneralSettingsView()
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct OnboardingView: View {
    @EnvironmentObject private var model: AppModel
    @State private var step = 0
    @State private var launchAtLogin = false
    @State private var hideDock = true

    private let firstSoundPackIds = [
        "com.thockstudio.pack.creamykeyboard.recording",
        "com.thockstudio.pack.creamy2.recording",
        "com.thockstudio.pack.clacky1.recording",
        "com.thockstudio.pack.thocky1.recording",
        "com.thockstudio.pack.bubble1.recording",
        "com.thockstudio.pack.normal1.recording"
    ]
    private let trySoundPackIds = [
        "com.thockstudio.pack.creamykeyboard.recording",
        "com.thockstudio.pack.creamy2.recording",
        "com.thockstudio.pack.creamy3.recording",
        "com.thockstudio.pack.clacky1.recording",
        "com.thockstudio.pack.clacky2.recording",
        "com.thockstudio.pack.clicky1.recording",
        "com.thockstudio.pack.thocky1.recording",
        "com.thockstudio.pack.thocky2.recording",
        "com.thockstudio.pack.bubble1.recording",
        "com.thockstudio.pack.normal1.recording",
        "com.thockstudio.pack.plastic1.recording",
        "com.thockstudio.pack.marbly1.recording",
        "com.thockstudio.pack.poppy1.recording"
    ]

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 12)
            Image(systemName: onboardingSymbol)
                .font(.system(size: 54, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .frame(width: 92, height: 92)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))

            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 640)
            }

            content
                .frame(maxWidth: 680)

            HStack {
                if step > 0 {
                    Button("Back") { step -= 1 }
                }
                Spacer()
                Button(primaryTitle) {
                    primaryAction()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .frame(maxWidth: 680)
            Spacer(minLength: 12)
        }
        .padding(32)
    }

    @ViewBuilder private var content: some View {
        switch step {
        case 0:
            HStack(spacing: 12) {
                FeaturePill(symbol: "waveform", text: "Mechanical")
                FeaturePill(symbol: "keyboard", text: "Typewriter")
                FeaturePill(symbol: "moon", text: "ASMR")
            }
        case 1:
            VStack(alignment: .leading, spacing: 10) {
                PrivacyBullet(text: "We never store what you type.")
                PrivacyBullet(text: "We never send keystrokes to a server.")
                PrivacyBullet(text: "Keyboard events only choose local sounds.")
                PrivacyBullet(text: "Everything runs locally on your Mac.")
            }
        case 2:
            VStack(spacing: 14) {
                InputMonitoringShortcutPanel()
            }
        case 3:
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 12)], spacing: 12) {
                ForEach(firstSoundPackIds, id: \.self) { id in
                    SoundPackCard(pack: model.packs.pack(with: id), compact: true)
                }
            }
        case 4:
            VStack(alignment: .leading, spacing: 12) {
                Picker("Sound", selection: Binding(
                    get: { model.settings.currentPackId },
                    set: { model.selectPack(model.packs.pack(with: $0)) }
                )) {
                    ForEach(trySoundPackIds, id: \.self) { id in
                        let pack = model.packs.pack(with: id)
                        Text(pack.name).tag(pack.id)
                    }
                }
                .pickerStyle(.menu)

                TestTypingPad()
                    .frame(height: 160)
            }
        default:
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Launch at login", isOn: $launchAtLogin)
                Toggle("Hide Dock icon after onboarding", isOn: $hideDock)
                Toggle("Menu bar animation", isOn: Binding(
                    get: { model.settings.menuBarAnimation },
                    set: { model.settings.menuBarAnimation = $0 }
                ))
            }
            .padding(16)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
    }

    private var onboardingSymbol: String {
        ["keyboard", "lock.shield", "gearshape.2", "waveform", "text.cursor", "checkmark.circle"][min(step, 5)]
    }

    private var title: String {
        switch step {
        case 0: return "Make your Mac keyboard sound premium."
        case 1: return "Private by design."
        case 2: return "One macOS permission is needed."
        case 3: return "Choose your first keyboard sound."
        case 4: return "Try it now."
        default: return "You are ready."
        }
    }

    private var subtitle: String {
        switch step {
        case 0: return "Choose a switch sound. Start typing. That is it."
        case 1: return "Thock Studio reacts to keys without knowing what you typed."
        case 2: return "macOS requires permission before apps can react to keyboard events in other apps."
        case 3: return "Pick from the recorded Creamy, Clacky, and Thocky samples."
        case 4: return "Type in the test pad and tune the volume."
        default: return "Thock Studio will keep running from the menu bar."
        }
    }

    private var primaryTitle: String {
        step == 5 ? "Start Typing" : "Continue"
    }

    private func primaryAction() {
        if step < 5 {
            step += 1
        } else {
            model.settings.launchAtLogin = launchAtLogin
            model.settings.showDockIcon = !hideDock
            model.settings.completeOnboarding()
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HeaderView(
                title: "Your Mac keyboard, upgraded.",
                subtitle: "Choose a premium typing sound and make every keystroke feel satisfying."
            )

            HStack(alignment: .top, spacing: 16) {
                Panel {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(model.currentPack.name)
                                    .font(.title2.bold())
                                Text("\(model.currentPack.category) • \(model.currentPack.tone) • \(model.currentPack.bestFor)")
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { model.settings.appEnabled },
                                set: { model.settings.appEnabled = $0 }
                            ))
                            .toggleStyle(.switch)
                            .labelsHidden()
                        }
                        SliderRow(
                            title: "Volume",
                            value: Binding(get: { Double(model.settings.masterVolume) }, set: { model.settings.masterVolume = Float($0) }),
                            range: 0...1
                        )
                        TestTypingPad()
                            .frame(height: 130)
                    }
                }

                VStack(spacing: 12) {
                    InputMonitoringShortcutPanel()
                    StatusBanner(symbol: "app.badge", title: model.profileService.activeAppName, message: model.profileService.isActiveAppMuted() ? "Muted by app profile." : "Current app can use keyboard sounds.")
                }
                .frame(width: 280)
            }

            SectionTitle("Recommended Sounds")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 210), spacing: 12)], spacing: 12) {
                ForEach(model.packs.builtInPacks.prefix(4)) { pack in
                    SoundPackCard(pack: pack, compact: true)
                }
            }
        }
    }
}

struct SoundPacksView: View {
    @EnvironmentObject private var model: AppModel
    @State private var search = ""
    @State private var category = "All"
    @State private var showImporter = false

    private var categories: [String] {
        ["All"] + Array(Set(model.packs.allPacks.map(\.category))).sorted()
    }

    private var filteredPacks: [SoundPack] {
        model.packs.allPacks.filter { pack in
            let matchesSearch = search.isEmpty || pack.searchText.contains(search.lowercased())
            let matchesCategory = category == "All" || pack.category == category
            return matchesSearch && matchesCategory
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderView(title: "Sound Packs", subtitle: "Browse built-in packs, preview tones, and import custom keyboards.")
            HStack {
                TextField("Search", text: $search)
                    .textFieldStyle(.roundedBorder)
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { Text($0).tag($0) }
                }
                Button {
                    showImporter = true
                } label: {
                    Label("Import", systemImage: "square.and.arrow.down")
                }
            }

            if let message = model.packs.importMessage {
                StatusBanner(symbol: "info.circle", title: "Import", message: message)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 12)], spacing: 12) {
                ForEach(filteredPacks) { pack in
                    SoundPackCard(pack: pack)
                }
            }
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.folder, .zip, UTType(filenameExtension: "thockpack") ?? .data],
            allowsMultipleSelection: false
        ) { result in
            if case let .success(urls) = result, let url = urls.first {
                model.importPack(from: url)
            } else if case let .failure(error) = result {
                model.packs.importMessage = error.localizedDescription
            }
        }
    }
}

struct MixerView: View {
    @EnvironmentObject private var model: AppModel
    @State private var selectedPreset: MixerPreset?

    private let columns = [GridItem(.adaptive(minimum: 300), spacing: 16)]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HeaderView(title: "Mixer", subtitle: "Shape \(model.currentPack.name) for the way you type.")

            Panel {
                HStack(spacing: 14) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                        .frame(width: 42, height: 42)
                        .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(model.currentPack.name)
                            .font(.title3.bold())
                        Text("\(model.currentPack.category) • \(model.currentPack.tone) • \(model.currentPack.loudness)")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        model.preview(model.currentPack)
                    } label: {
                        Label("Preview", systemImage: "play.fill")
                    }
                    Button {
                        selectedPreset = nil
                        model.settings.resetMixer()
                        model.audio.applyMixer(settings: model.settings.snapshot)
                        model.preview(model.currentPack)
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                }
            }

            Panel {
                VStack(alignment: .leading, spacing: 12) {
                    MixerHeader(symbol: "wand.and.stars", title: "Presets")
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 118), spacing: 10)], spacing: 10) {
                        ForEach(MixerPreset.allCases) { preset in
                            MixerPresetButton(
                                preset: preset,
                                isSelected: selectedPreset == preset
                            ) {
                                selectedPreset = preset
                                preset.apply(to: model.settings)
                                model.audio.applyMixer(settings: model.settings.snapshot)
                                model.preview(model.currentPack)
                            }
                        }
                    }
                }
            }

            LazyVGrid(columns: columns, spacing: 16) {
                Panel {
                    VStack(alignment: .leading, spacing: 14) {
                        MixerHeader(symbol: "speaker.wave.2", title: "Levels")
                        SliderRow(title: "Master", value: bind(\.masterVolume), range: 0...1)
                        SliderRow(title: "Press", value: bind(\.pressVolume), range: 0...1.4)
                        SliderRow(title: "Release", value: bind(\.releaseVolume), range: 0...1)
                        SliderRow(title: "Spacebar", value: bind(\.spacebarVolume), range: 0...1.5)
                        SliderRow(title: "Modifiers", value: bind(\.modifierVolume), range: 0...1)
                    }
                }

                Panel {
                    VStack(alignment: .leading, spacing: 14) {
                        MixerHeader(symbol: "waveform.path.ecg", title: "Tone")
                        SliderRow(title: "Pitch", value: bind(\.pitchShiftSemitones), range: -6...6)
                        SliderRow(title: "Variation", value: bind(\.pitchVariation), range: 0...0.08)
                        SliderRow(title: "Bass", value: bind(\.bassBoost), range: -1...1)
                        SliderRow(title: "Brightness", value: bind(\.brightness), range: -1...1)
                        SliderRow(title: "Room", value: bind(\.roomAmount), range: 0...0.3)
                    }
                }

                Panel {
                    VStack(alignment: .leading, spacing: 14) {
                        MixerHeader(symbol: "keyboard.badge.ellipsis", title: "Playback")
                        Toggle("Sample variation", isOn: Binding(get: { model.settings.sampleVariation }, set: { model.settings.sampleVariation = $0 }))
                        Toggle("Release sounds", isOn: Binding(get: { model.settings.releaseSoundsEnabled }, set: { model.settings.releaseSoundsEnabled = $0 }))
                        Toggle("Modifier sounds", isOn: Binding(get: { model.settings.modifierSoundsEnabled }, set: { model.settings.modifierSoundsEnabled = $0 }))
                        Toggle("Limiter", isOn: Binding(get: { model.settings.limiterEnabled }, set: { model.settings.limiterEnabled = $0 }))
                        Picker("Key Repeat", selection: Binding(get: { model.settings.repeatMode }, set: { model.settings.repeatMode = $0 })) {
                            ForEach(RepeatMode.allCases) { mode in
                                Text(mode.label).tag(mode)
                            }
                        }
                        SliderRow(
                            title: "Repeat Rate",
                            value: Binding(get: { model.settings.maxRepeatSoundsPerSecond }, set: { model.settings.maxRepeatSoundsPerSecond = $0 }),
                            range: 1...20
                        )
                    }
                }
            }
        }
    }

    private func bind(_ keyPath: ReferenceWritableKeyPath<SettingsStore, Float>) -> Binding<Double> {
        Binding(
            get: { Double(model.settings[keyPath: keyPath]) },
            set: {
                model.settings[keyPath: keyPath] = Float($0)
                selectedPreset = nil
                model.audio.applyMixer(settings: model.settings.snapshot)
            }
        )
    }
}

private enum MixerPreset: String, CaseIterable, Identifiable {
    case balanced
    case soft
    case deep
    case crisp
    case calm

    var id: String { rawValue }

    var label: String {
        switch self {
        case .balanced: return "Balanced"
        case .soft: return "Soft"
        case .deep: return "Deep"
        case .crisp: return "Crisp"
        case .calm: return "Calm"
        }
    }

    var symbol: String {
        switch self {
        case .balanced: return "circle.lefthalf.filled"
        case .soft: return "moon"
        case .deep: return "speaker.wave.3"
        case .crisp: return "bolt"
        case .calm: return "leaf"
        }
    }

    @MainActor
    func apply(to settings: SettingsStore) {
        switch self {
        case .balanced:
            assign(settings, master: 0.55, press: 1.0, release: 0.35, spacebar: 1.15, modifiers: 0.30, pitch: 0, variation: 0.020, bass: 0, brightness: 0, room: 0.05, sampleVariation: true, releaseSounds: true, modifierSounds: true, repeatMode: .reduced, repeatRate: 10)
        case .soft:
            assign(settings, master: 0.38, press: 0.80, release: 0.22, spacebar: 0.88, modifiers: 0.16, pitch: -0.75, variation: 0.012, bass: 0.12, brightness: -0.25, room: 0.03, sampleVariation: true, releaseSounds: true, modifierSounds: false, repeatMode: .firstOnly, repeatRate: 7)
        case .deep:
            assign(settings, master: 0.52, press: 1.0, release: 0.28, spacebar: 1.25, modifiers: 0.22, pitch: -2.0, variation: 0.018, bass: 0.55, brightness: -0.35, room: 0.04, sampleVariation: true, releaseSounds: true, modifierSounds: true, repeatMode: .reduced, repeatRate: 9)
        case .crisp:
            assign(settings, master: 0.48, press: 1.05, release: 0.25, spacebar: 1.0, modifiers: 0.20, pitch: 0.75, variation: 0.012, bass: -0.15, brightness: 0.45, room: 0.02, sampleVariation: true, releaseSounds: false, modifierSounds: true, repeatMode: .reduced, repeatRate: 12)
        case .calm:
            assign(settings, master: 0.36, press: 0.72, release: 0.18, spacebar: 0.90, modifiers: 0.12, pitch: -0.25, variation: 0.008, bass: 0.20, brightness: -0.15, room: 0.12, sampleVariation: true, releaseSounds: false, modifierSounds: false, repeatMode: .firstOnly, repeatRate: 6)
        }
    }

    @MainActor
    private func assign(
        _ settings: SettingsStore,
        master: Float,
        press: Float,
        release: Float,
        spacebar: Float,
        modifiers: Float,
        pitch: Float,
        variation: Float,
        bass: Float,
        brightness: Float,
        room: Float,
        sampleVariation: Bool,
        releaseSounds: Bool,
        modifierSounds: Bool,
        repeatMode: RepeatMode,
        repeatRate: Double
    ) {
        settings.masterVolume = master
        settings.pressVolume = press
        settings.releaseVolume = release
        settings.spacebarVolume = spacebar
        settings.modifierVolume = modifiers
        settings.pitchShiftSemitones = pitch
        settings.pitchVariation = variation
        settings.bassBoost = bass
        settings.brightness = brightness
        settings.roomAmount = room
        settings.sampleVariation = sampleVariation
        settings.releaseSoundsEnabled = releaseSounds
        settings.modifierSoundsEnabled = modifierSounds
        settings.limiterEnabled = true
        settings.repeatMode = repeatMode
        settings.maxRepeatSoundsPerSecond = repeatRate
    }
}

private struct MixerHeader: View {
    let symbol: String
    let title: String

    var body: some View {
        Label(title, systemImage: symbol)
            .font(.headline)
    }
}

private struct MixerPresetButton: View {
    let preset: MixerPreset
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: preset.symbol)
                    .frame(width: 18)
                Text(preset.label)
                    .font(.callout.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.accentColor.opacity(0.18) : Color.secondary.opacity(0.10), in: RoundedRectangle(cornerRadius: 7))
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.18), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .help(preset.label)
    }
}

struct AppProfilesView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderView(title: "App Profiles", subtitle: "Create optional per-app sound rules.")
            HStack {
                Button {
                    model.profileService.addCurrentApp(packId: model.settings.currentPackId)
                } label: {
                    Label("Add Current App", systemImage: "plus.app")
                }
                Button("Clear Profiles") {
                    model.profileService.resetDefaults()
                }
            }

            if model.profileService.profiles.isEmpty {
                StatusBanner(
                    symbol: "app.badge",
                    title: "No app-specific rules",
                    message: "Typing sounds use the active sound pack in every app until you add a rule."
                )
            }

            ForEach(model.profileService.profiles) { profile in
                Panel {
                    HStack(spacing: 14) {
                        Image(systemName: profile.mute ? "speaker.slash" : "speaker.wave.2")
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile.displayName)
                                .font(.headline)
                            Text(profile.bundleId)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Toggle("Enabled", isOn: Binding(
                            get: { profile.enabled },
                            set: { _ in model.profileService.toggleEnabled(profile) }
                        ))
                        Toggle("Mute", isOn: Binding(
                            get: { profile.mute },
                            set: { _ in model.profileService.toggleMute(profile) }
                        ))
                        Picker("Pack", selection: Binding(
                            get: { profile.soundPackId ?? "" },
                            set: { model.profileService.setSoundPack(profile, packId: $0.isEmpty ? nil : $0) }
                        )) {
                            Text("Default").tag("")
                            ForEach(model.packs.allPacks) { pack in
                                Text(pack.name).tag(pack.id)
                            }
                        }
                        .frame(width: 180)
                        Button(role: .destructive) {
                            model.profileService.delete(profile)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .help("Delete")
                    }
                }
            }
        }
    }
}

struct PrivacyView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HeaderView(title: "Privacy", subtitle: "Thock Studio does not know what you typed.")
            Panel {
                VStack(alignment: .leading, spacing: 12) {
                    PrivacyBullet(text: "No typed text is stored.")
                    PrivacyBullet(text: "No key activity is sent to servers.")
                    PrivacyBullet(text: "No screenshots or clipboard content are read.")
                    PrivacyBullet(text: "No password fields are bypassed.")
                    PrivacyBullet(text: "Keyboard events are used only to select local audio.")
                }
            }
            HStack {
                InputMonitoringShortcutPanel()
            }
            Button(role: .destructive) {
                model.resetLocalData()
            } label: {
                Label("Delete Local Data", systemImage: "trash")
            }
        }
    }
}

struct DiagnosticsView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HeaderView(title: "Diagnostics", subtitle: "Check audio, permission, and typing detection in one place.")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 12)], spacing: 12) {
                DiagnosticTile(
                    symbol: model.audio.isRunning ? "speaker.wave.2.fill" : "speaker.slash",
                    title: "Audio",
                    value: model.audioStatusText,
                    good: model.audio.isRunning && model.audio.lastError == nil
                )
                DiagnosticTile(
                    symbol: model.permissions.state == .approved ? "checkmark.shield.fill" : "lock.shield",
                    title: "Input Monitoring",
                    value: model.permissions.state.label,
                    good: model.permissions.state == .approved
                )
                DiagnosticTile(
                    symbol: model.listenerState.isRunning ? "keyboard.badge.ellipsis" : "exclamationmark.triangle",
                    title: "Keyboard Listener",
                    value: model.listenerStatusText,
                    good: model.listenerState.isRunning
                )
                DiagnosticTile(
                    symbol: model.typingPlaybackReady ? "speaker.wave.2" : "speaker.slash.fill",
                    title: "Playback State",
                    value: model.typingPlaybackStatusText,
                    good: model.typingPlaybackReady
                )
            }

            Panel {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Sound Test")
                        .font(.headline)
                    Text("Preview uses the same loaded samples as regular typing. If this is silent, check output device and volume first.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    HStack {
                        Button {
                            model.preview(model.currentPack)
                        } label: {
                            Label("Play Preview", systemImage: "play.fill")
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            model.restartAudio()
                        } label: {
                            Label("Restart Audio", systemImage: "speaker.wave.2")
                        }

                        Text(model.lastSoundPlayedText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Panel {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Typing Test")
                        .font(.headline)
                    Text("Type anywhere outside the test pad after Input Monitoring is enabled. This line should update with the latest key event.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    HStack {
                        Label(model.lastKeyboardEventText, systemImage: "keyboard")
                            .font(.callout)
                        Spacer()
                        Button("Recheck") {
                            model.refreshPermissionStatus()
                            model.restartKeyboardListener()
                        }
                    }
                    Label(model.lastTypingPlaybackDecisionText, systemImage: "speaker.wave.2")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    HStack {
                        Label(model.debugLogPathText, systemImage: "doc.text")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer()
                        Button {
                            model.openDebugLog()
                        } label: {
                            Label("Open Debug Log", systemImage: "doc.text.magnifyingglass")
                        }
                    }
                    InputMonitoringShortcutPanel(framed: false)
                }
            }

            Panel {
                VStack(alignment: .leading, spacing: 12) {
                    Text("In-App Pad")
                        .font(.headline)
                    Text("This pad previews sounds without relying on Input Monitoring. It is useful for separating audio issues from permission issues.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    TestTypingPad()
                        .frame(height: 130)
                }
            }
        }
    }
}

struct DiagnosticTile: View {
    let symbol: String
    let title: String
    let value: String
    let good: Bool

    var body: some View {
        Panel {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: symbol)
                    .font(.title3)
                    .frame(width: 30, height: 30)
                    .foregroundStyle(good ? Color.green : Color.orange)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(value)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
    }
}

struct GeneralSettingsView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HeaderView(title: "Settings", subtitle: "General behavior, quiet hours, and troubleshooting.")
            Panel {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Launch at login", isOn: Binding(get: { model.settings.launchAtLogin }, set: { model.settings.launchAtLogin = $0 }))
                    Toggle("Show Dock icon", isOn: Binding(get: { model.settings.showDockIcon }, set: { model.settings.showDockIcon = $0 }))
                    Toggle("Menu bar animation", isOn: Binding(get: { model.settings.menuBarAnimation }, set: { model.settings.menuBarAnimation = $0 }))
                    Toggle("Global mute hotkey", isOn: Binding(
                        get: { model.settings.globalMuteHotkeyEnabled },
                        set: { model.setGlobalMuteHotkeyEnabled($0) }
                    ))
                    Picker("Shortcut", selection: Binding(
                        get: { model.settings.globalMuteHotkey },
                        set: { model.setGlobalMuteHotkey($0) }
                    )) {
                        ForEach(GlobalMuteHotkey.allCases) { hotkey in
                            Text(hotkey.label).tag(hotkey)
                        }
                    }
                    .disabled(!model.settings.globalMuteHotkeyEnabled)
                    HStack {
                        Label(model.hotkeys.statusText, systemImage: model.hotkeys.isRegistered ? "keyboard.badge.ellipsis" : "exclamationmark.triangle")
                        Spacer()
                        Text(model.hotkeys.isRegistered ? "Ready" : "Not registered")
                            .foregroundStyle(.secondary)
                    }
                    .font(.callout)
                }
            }
            Panel {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sound")
                        .font(.headline)
                    SliderRow(
                        title: "Pitch",
                        value: Binding(
                            get: { Double(model.settings.pitchShiftSemitones) },
                            set: { model.settings.pitchShiftSemitones = Float($0) }
                        ),
                        range: -6...6
                    )
                    HStack {
                        Text("Negative values make the samples deeper. Positive values make them brighter.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Reset Pitch") {
                            model.settings.pitchShiftSemitones = 0
                        }
                    }
                }
            }
            Panel {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Quiet Hours", isOn: Binding(get: { model.settings.quietHoursEnabled }, set: { model.settings.quietHoursEnabled = $0 }))
                    TimeStepper(title: "Start", minutes: Binding(get: { model.settings.quietHoursStartMinutes }, set: { model.settings.quietHoursStartMinutes = $0 }))
                    TimeStepper(title: "End", minutes: Binding(get: { model.settings.quietHoursEndMinutes }, set: { model.settings.quietHoursEndMinutes = $0 }))
                    Toggle("Lower volume instead of muting", isOn: Binding(get: { model.settings.quietHoursLowerVolume }, set: { model.settings.quietHoursLowerVolume = $0 }))
                    SliderRow(title: "Quiet Volume", value: Binding(get: { Double(model.settings.quietHoursVolume) }, set: { model.settings.quietHoursVolume = Float($0) }), range: 0...1)
                }
            }
            Panel {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Troubleshooting")
                        .font(.headline)
                    InputMonitoringShortcutPanel(framed: false)
                    Button("Restart Audio Engine") { model.restartAudio() }
                    Button("Restart Keyboard Listener") { model.restartKeyboardListener() }
                    Button("Mute for 30 Minutes") {
                        model.settings.mute(for: 30 * 60)
                    }
                    Button("Mute Until Tomorrow") {
                        model.settings.muteUntilTomorrow()
                    }
                    if let error = model.audio.lastError {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }
}

struct SoundPackCard: View {
    @EnvironmentObject private var model: AppModel
    let pack: SoundPack
    var compact = false

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: pack.category == "Clicky" ? "bolt" : "waveform")
                        .frame(width: 28, height: 28)
                        .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 6))
                    Spacer()
                    Button {
                        model.packs.toggleFavorite(pack)
                    } label: {
                        Image(systemName: model.packs.favorites.contains(pack.id) ? "star.fill" : "star")
                    }
                    .buttonStyle(.plain)
                    .help("Favorite")
                }
                Text(pack.name)
                    .font(compact ? .headline : .title3.bold())
                    .lineLimit(1)
                Text(pack.description)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(compact ? 2 : 3)
                HStack {
                    Tag(pack.category)
                    Tag(pack.loudness)
                    Tag(pack.tone)
                }
                HStack {
                    Button {
                        model.preview(pack)
                    } label: {
                        Label("Preview", systemImage: "play.fill")
                    }
                    if model.settings.currentPackId == pack.id {
                        Button {
                            model.selectPack(pack)
                        } label: {
                            Label("Using", systemImage: "checkmark")
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button {
                            model.selectPack(pack)
                        } label: {
                            Label("Use", systemImage: "checkmark")
                        }
                        .buttonStyle(.bordered)
                    }
                    if case .imported = pack.source {
                        Button(role: .destructive) {
                            model.packs.deleteImportedPack(pack)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .help("Delete imported pack")
                    }
                }
            }
        }
    }
}

struct TestTypingPad: View {
    @EnvironmentObject private var model: AppModel
    @State private var text = ""
    @FocusState private var focused: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(.system(.body, design: .monospaced))
                .focused($focused)
                .scrollContentBackground(.hidden)
                .padding(10)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(model.transientPulse ? Color.accentColor : Color.secondary.opacity(0.2), lineWidth: 1)
                )
                .onChange(of: text) { newValue in
                    guard focused else { return }
                    let category: KeyCategory = newValue.last == " " ? .space : .alpha
                    model.previewKey(category: category)
                }
                .onChange(of: focused) { isFocused in
                    model.isTypingPreviewFocused = isFocused
                }
                .onDisappear {
                    if focused {
                        model.isTypingPreviewFocused = false
                    }
                }
            if text.isEmpty {
                Text("Type here and listen.")
                    .foregroundStyle(.tertiary)
                    .padding(18)
                    .allowsHitTesting(false)
            }
        }
    }
}

struct HeaderView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 28, weight: .bold))
            Text(subtitle)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }
}

struct Panel<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct SliderRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>

    var body: some View {
        HStack {
            Text(title)
                .frame(width: 150, alignment: .leading)
            Slider(value: $value, in: range)
            Text(value.formatted(.number.precision(.fractionLength(2))))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 44, alignment: .trailing)
        }
    }
}

struct IconButton: View {
    let systemName: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .frame(width: 32, height: 28)
        }
        .help(title)
    }
}

struct StatusBanner: View {
    let symbol: String
    let title: String
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: symbol)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct InputMonitoringShortcutPanel: View {
    @EnvironmentObject private var model: AppModel
    var compact = false
    var framed = true

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: model.permissions.state == .approved ? "checkmark.shield" : "keyboard.badge.ellipsis")
                    .frame(width: 24)
                    .foregroundStyle(model.permissions.state == .approved ? Color.green : Color.orange)
                VStack(alignment: .leading, spacing: 3) {
                    Text(model.permissions.state == .approved ? "Input Monitoring is on" : "Input Monitoring is needed")
                        .font(compact ? .caption.weight(.semibold) : .headline)
                    Text(model.permissions.state == .approved ? "Typing sounds can work across apps." : "Open Input Monitoring, add Thock Studio with + if it is missing, turn it on, then recheck.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(compact ? 2 : nil)
                }
            }

            if compact {
                VStack(spacing: 8) {
                    permissionButtons
                }
            } else {
                HStack(spacing: 8) {
                    permissionButtons
                }
            }
        }
        .padding(compact || !framed ? 0 : 12)
        .background(Color.secondary.opacity(compact || !framed ? 0 : 0.08), in: RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder private var permissionButtons: some View {
        if compact {
            Button {
                model.openSettingsForPermission()
            } label: {
                Label("Open Input Monitoring", systemImage: "gearshape")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        } else {
            Button {
                model.openSettingsForPermission()
            } label: {
                Label("Open Input Monitoring", systemImage: "gearshape")
            }
            .buttonStyle(.bordered)
        }

        Button {
            model.requestPermission()
        } label: {
            Label("Prompt Permission", systemImage: "keyboard")
                .frame(maxWidth: compact ? .infinity : nil)
        }
        .buttonStyle(.bordered)

        Button {
            model.revealAppForPermission()
        } label: {
            Label("Show App", systemImage: "folder")
                .frame(maxWidth: compact ? .infinity : nil)
        }
        .buttonStyle(.bordered)

        Button {
            model.refreshPermissionStatus()
            model.restartKeyboardListener()
        } label: {
            Label("Recheck", systemImage: "arrow.clockwise")
                .frame(maxWidth: compact ? .infinity : nil)
        }
        .buttonStyle(.bordered)
    }
}

struct PrivacyBullet: View {
    let text: String

    var body: some View {
        Label(text, systemImage: "checkmark.circle")
            .font(.callout)
    }
}

struct FeaturePill: View {
    let symbol: String
    let text: String

    var body: some View {
        Label(text, systemImage: symbol)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct FeatureTile: View {
    let symbol: String
    let title: String
    let text: String

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: symbol)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                Text(text)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct MetricView: View {
    let title: String
    let value: String

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 6) {
                Text(value)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct Tag: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 6))
    }
}

struct SectionTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.headline)
    }
}

struct TimeStepper: View {
    let title: String
    @Binding var minutes: Int

    var body: some View {
        Stepper(value: $minutes, in: 0...(24 * 60 - 15), step: 15) {
            Text("\(title): \(formatted(minutes))")
        }
    }

    private func formatted(_ minutes: Int) -> String {
        let hour = minutes / 60
        let minute = minutes % 60
        return String(format: "%02d:%02d", hour, minute)
    }
}
