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
        VStack(alignment: .leading, spacing: 12) {
            MenuHeaderView()

            MenuControlPanel()

            if model.menuBarHasPermissionIssue {
                MenuPermissionCallout()
            }

            if model.settings.temporaryMuteUntil != nil {
                Button {
                    model.settings.clearTemporaryMute()
                } label: {
                    Label("Resume Sounds", systemImage: "speaker.wave.2.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }

            if let error = model.audio.lastError {
                MenuAudioErrorView(error: error)
            }

            MenuFooterView(openWindow: openWindow)
        }
        .padding(14)
        .onAppear {
            model.refreshPermissionStatus()
        }
    }
}

private struct MenuHeaderView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        HStack(spacing: 11) {
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: model.menuBarSymbol)
                    .font(.title3)
                    .frame(width: 38, height: 38)
                    .background(Color.secondary.opacity(0.10), in: RoundedRectangle(cornerRadius: 8))
                Circle()
                    .fill(statusColor)
                    .frame(width: 9, height: 9)
                    .overlay(Circle().stroke(Color(nsColor: .windowBackgroundColor), lineWidth: 1.5))
                    .offset(x: 1, y: 1)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("KeyThock")
                    .font(.headline)
                    .lineLimit(1)
                Text(model.visibleStatus)
                    .font(.caption)
                    .foregroundStyle(statusColor)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Toggle("", isOn: Binding(
                get: { model.settings.appEnabled },
                set: { model.settings.appEnabled = $0 }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
        }
    }

    private var statusColor: Color {
        if model.isMutedNow { return .secondary }
        return .green
    }
}

private struct MenuControlPanel: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Text("Volume")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 50, alignment: .leading)
                MenuVolumeControl()
                Spacer(minLength: 0)
            }

            HStack(spacing: 10) {
                Text("Sound")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 50, alignment: .leading)
                MenuSoundSelector()
                Spacer(minLength: 0)
            }

            HStack(alignment: .top, spacing: 10) {
                Text("Effects")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 50, height: 24, alignment: .leading)
                VStack(alignment: .leading, spacing: 7) {
                    HStack(spacing: 8) {
                        MenuEffectToggle(title: "Echo", isOn: Binding(
                            get: { model.echoEnabled },
                            set: { model.setEchoEnabled($0) }
                        ), onChange: {
                            model.preview(model.currentPack)
                        })
                        MenuEffectToggle(title: "Reverb", isOn: Binding(
                            get: { model.reverbEnabled },
                            set: { model.setReverbEnabled($0) }
                        ), onChange: {
                            model.preview(model.currentPack)
                        })
                    }
                    HStack(spacing: 8) {
                        MenuEffectToggle(title: "Ducking", isOn: Binding(
                            get: { model.settings.autoDuckingEnabled },
                            set: { model.setAutoDuckingEnabled($0) }
                        ))
                        Spacer(minLength: 0)
                    }
                }
                .frame(width: 222, alignment: .leading)
                Spacer(minLength: 0)
            }

            HStack(spacing: 8) {
                MenuPopoverIconButton(systemName: "play.fill", title: "Preview", wide: true) {
                    model.preview(model.currentPack)
                }
                MenuPopoverIconButton(systemName: "30.circle", title: "Mute 30 minutes", wide: true) {
                    model.settings.mute(for: 30 * 60)
                }
            }
        }
        .padding(11)
        .background(Color.secondary.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct MenuPermissionCallout: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "keyboard.badge.ellipsis")
                    .font(.headline)
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color.orange)
                    .background(Color.orange.opacity(0.14), in: RoundedRectangle(cornerRadius: 7))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Enable keyboard sounds")
                        .font(.callout.weight(.semibold))
                    Text("Allow Input Monitoring so KeyThock can play sounds while you type.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 8) {
                Button {
                    model.openSettingsForPermission()
                } label: {
                    Label("Open Settings", systemImage: "switch.2")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                MenuPopoverIconButton(systemName: "folder", title: "Show App") {
                    model.revealAppForPermission()
                }

                MenuPopoverIconButton(systemName: "arrow.clockwise", title: "Recheck") {
                    model.refreshPermissionStatus()
                    model.restartKeyboardListener()
                }
            }

            Button {
                model.selectedTab = .diagnostics
                openWindow(id: "main")
                NSApp.activate(ignoringOtherApps: true)
            } label: {
                Label("Open Diagnostics", systemImage: "stethoscope")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(11)
        .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct MenuAudioErrorView: View {
    @EnvironmentObject private var model: AppModel
    let error: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(Color.red)
                .frame(width: 24)
            Text(error)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Spacer(minLength: 0)
            MenuPopoverIconButton(systemName: "speaker.wave.2", title: "Restart Audio") {
                model.restartAudio()
            }
        }
        .padding(10)
        .background(Color.red.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct MenuFooterView: View {
    @EnvironmentObject private var model: AppModel
    let openWindow: OpenWindowAction

    var body: some View {
        HStack(spacing: 10) {
            Label(model.focusMenuStatusText, systemImage: footerSymbol)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer(minLength: 0)

            Button {
                model.selectedTab = .focus
                openWindow(id: "main")
                NSApp.activate(ignoringOtherApps: true)
            } label: {
                Image(systemName: "timer")
                    .frame(width: 24, height: 22)
            }
            .buttonStyle(.borderless)
            .help("Focus")

            Button {
                model.selectedTab = .diagnostics
                openWindow(id: "main")
                NSApp.activate(ignoringOtherApps: true)
            } label: {
                Image(systemName: "stethoscope")
                    .frame(width: 24, height: 22)
            }
            .buttonStyle(.borderless)
            .help("Diagnostics")

            Button {
                model.selectedTab = .mixer
                openWindow(id: "main")
                NSApp.activate(ignoringOtherApps: true)
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .frame(width: 24, height: 22)
            }
            .buttonStyle(.borderless)
            .help("Open Mixer")

            Button {
                model.selectedTab = .settings
                openWindow(id: "main")
                NSApp.activate(ignoringOtherApps: true)
            } label: {
                Image(systemName: "gearshape")
                    .frame(width: 24, height: 22)
            }
            .buttonStyle(.borderless)
            .help("Settings")

            Button("Quit") {
                NSApp.terminate(nil)
            }
            .font(.caption)
        }
        .padding(.top, 2)
    }

    private var footerSymbol: String {
        model.focusMenuSymbol
    }
}

private struct MenuPopoverIconButton: View {
    let systemName: String
    let title: String
    var compact = false
    var wide = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: compact ? 12 : 14, weight: .semibold))
                .frame(width: wide ? 52 : (compact ? 28 : 38), height: 30)
                .background(Color.secondary.opacity(0.11), in: RoundedRectangle(cornerRadius: 7))
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color.secondary.opacity(0.10), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .help(title)
        .accessibilityLabel(title)
    }
}

private struct MenuVolumeControl: View {
    @EnvironmentObject private var model: AppModel
    @State private var volumePercent = 25

    var body: some View {
        HStack(spacing: 8) {
            MenuPopoverRepeatButton(systemName: "chevron.left", title: "Volume down") {
                adjustVolumePercent(by: -1)
            }

            VStack(spacing: 0) {
                Slider(
                    value: Binding(
                        get: { Double(volumePercent) / 100 },
                        set: { setVolumePercent(clampedPercent(Float($0))) }
                    ),
                    in: 0...1
                )
                .controlSize(.small)
                .frame(width: 150)

                Text("\(volumePercent)%")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .frame(width: 150, alignment: .center)
            }
            .frame(width: 150, height: 32)

            MenuPopoverRepeatButton(systemName: "chevron.right", title: "Volume up") {
                adjustVolumePercent(by: 1)
            }
        }
        .onAppear {
            volumePercent = clampedPercent(model.settings.masterVolume)
        }
        .onReceive(model.settings.$masterVolume) { value in
            volumePercent = clampedPercent(value)
        }
    }

    private func adjustVolumePercent(by delta: Int) {
        setVolumePercent(volumePercent + delta)
    }

    private func setVolumePercent(_ percent: Int) {
        let nextPercent = min(100, max(0, percent))
        volumePercent = nextPercent
        model.settings.masterVolume = Float(nextPercent) / 100
    }

    private func clampedPercent(_ volume: Float) -> Int {
        min(100, max(0, Int((volume * 100).rounded())))
    }
}

private struct MenuPopoverRepeatButton: View {
    let systemName: String
    let title: String
    let action: () -> Void

    @State private var isPressed = false
    @State private var delayTimer: Timer?
    @State private var repeatTimer: Timer?

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 12, weight: .semibold))
            .frame(width: 28, height: 30)
            .background(Color.secondary.opacity(isPressed ? 0.18 : 0.11), in: RoundedRectangle(cornerRadius: 7))
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color.secondary.opacity(0.10), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 7))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in startPressing() }
                    .onEnded { _ in stopPressing() }
            )
            .onDisappear {
                stopPressing()
            }
            .help(title)
            .accessibilityLabel(title)
            .accessibilityAddTraits(.isButton)
    }

    private func startPressing() {
        guard !isPressed else { return }
        isPressed = true
        action()

        let delay = Timer(timeInterval: 0.35, repeats: false) { _ in
            guard isPressed else { return }
            action()
            let repeating = Timer(timeInterval: 0.08, repeats: true) { _ in
                action()
            }
            repeatTimer = repeating
            RunLoop.main.add(repeating, forMode: .common)
        }
        delayTimer = delay
        RunLoop.main.add(delay, forMode: .common)
    }

    private func stopPressing() {
        isPressed = false
        delayTimer?.invalidate()
        repeatTimer?.invalidate()
        delayTimer = nil
        repeatTimer = nil
    }
}

private struct MenuEffectToggle: View {
    let title: String
    let isOn: Binding<Bool>
    var onChange: (() -> Void)?

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            Toggle("", isOn: isOn)
                .toggleStyle(.switch)
                .labelsHidden()
                .controlSize(.small)
                .onChange(of: isOn.wrappedValue) { _ in
                    onChange?()
                }
        }
        .frame(width: 104, alignment: .leading)
        .help(title)
    }
}

private struct MenuSoundSelector: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        HStack(spacing: 8) {
            MenuPopoverIconButton(systemName: "chevron.left", title: "Previous sound", compact: true) {
                model.selectAdjacentPack(delta: -1)
            }

            Menu {
                ForEach(model.packs.allPacks) { pack in
                    Button {
                        model.selectPackAndPreview(pack)
                    } label: {
                        if pack.id == model.settings.currentPackId {
                            Label(pack.name, systemImage: "checkmark")
                        } else {
                            Text(pack.name)
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(model.currentPack.name)
                        .font(.callout.weight(.semibold))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10)
                .frame(width: 150, height: 30)
                .background(Color.secondary.opacity(0.11), in: RoundedRectangle(cornerRadius: 7))
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color.secondary.opacity(0.10), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .help("Choose sound")
            .accessibilityLabel("Choose sound")

            MenuPopoverIconButton(systemName: "chevron.right", title: "Next sound", compact: true) {
                model.selectAdjacentPack(delta: 1)
            }
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
                    case .focus:
                        FocusView()
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
        "com.keythock.pack.creamykeyboard.recording",
        "com.keythock.pack.creamy2.recording",
        "com.keythock.pack.clacky1.recording",
        "com.keythock.pack.thocky1.recording",
        "com.keythock.pack.bubble1.recording",
        "com.keythock.pack.normal1.recording",
        "com.keythock.pack.typewriter1.recording"
    ]
    private let trySoundPackIds = [
        "com.keythock.pack.creamykeyboard.recording",
        "com.keythock.pack.creamy2.recording",
        "com.keythock.pack.clacky1.recording",
        "com.keythock.pack.clicky1.recording",
        "com.keythock.pack.thocky1.recording",
        "com.keythock.pack.thocky2.recording",
        "com.keythock.pack.bubble1.recording",
        "com.keythock.pack.normal1.recording",
        "com.keythock.pack.typewriter1.recording",
        "com.keythock.pack.morse1.synth",
        "com.keythock.pack.morse2.synth",
        "com.keythock.pack.morse3.synth",
        "com.keythock.pack.plastic1.recording",
        "com.keythock.pack.marbly1.recording",
        "com.keythock.pack.poppy1.recording"
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: onboardingSymbol)
                        .font(.system(size: 48, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                        .frame(width: 80, height: 80)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))

                    VStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                        Text(subtitle)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 640)
                    }

                    content
                        .frame(maxWidth: 680)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 32)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.automatic)

            Divider()
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
            .padding(.horizontal, 32)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(.bar)
        }
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
                LocalPlaybackPanel()
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
        case 2: return "Built for the Mac App Store."
        case 3: return "Choose your first keyboard sound."
        case 4: return "Try it now."
        default: return "You are ready."
        }
    }

    private var subtitle: String {
        switch step {
        case 0: return "Choose a switch sound. Start typing. That is it."
        case 1: return "KeyThock reacts to keys without knowing what you typed."
        case 2: return "Allow keyboard access once, then hear sounds while you type across your Mac."
        case 3: return "Pick from the recorded Creamy, Clacky, and Thocky samples."
        case 4: return "Type in the test pad and tune the volume."
        default: return "KeyThock will keep running from the menu bar."
        }
    }

    private var primaryTitle: String {
        step == 5 ? "Start Typing" : "Next"
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

    private var favoritePacks: [SoundPack] {
        model.packs.allPacks
            .filter { model.packs.favorites.contains($0.id) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

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
                    LocalPlaybackPanel()
                    CurrentAppStatusView()
                }
                .frame(width: 280)
            }

            if !favoritePacks.isEmpty {
                SectionTitle("Favorite Sounds")
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 210), spacing: 12)], spacing: 12) {
                    ForEach(favoritePacks) { pack in
                        SoundPackCard(pack: pack, compact: true)
                    }
                }
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

private enum SoundPackScope: String, CaseIterable, Identifiable {
    case all = "All"
    case favorites = "Favorites"
    case imported = "Imported"

    var id: String { rawValue }
}

struct SoundPacksView: View {
    @EnvironmentObject private var model: AppModel
    @State private var search = ""
    @State private var category = "All"
    @State private var scope: SoundPackScope = .all
    @State private var showImporter = false

    private var categories: [String] {
        ["All"] + Array(Set(model.packs.allPacks.map(\.category))).sorted()
    }

    private var filteredPacks: [SoundPack] {
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return model.packs.allPacks.filter { pack in
            let matchesScope: Bool
            switch scope {
            case .all:
                matchesScope = true
            case .favorites:
                matchesScope = model.packs.favorites.contains(pack.id)
            case .imported:
                if case .imported = pack.source {
                    matchesScope = true
                } else {
                    matchesScope = false
                }
            }
            let matchesSearch = query.isEmpty || pack.searchText.contains(query)
            let matchesCategory = category == "All" || pack.category == category
            return matchesScope && matchesSearch && matchesCategory
        }
        .sorted { lhs, rhs in
            let lhsFavorite = model.packs.favorites.contains(lhs.id)
            let rhsFavorite = model.packs.favorites.contains(rhs.id)
            if lhsFavorite != rhsFavorite { return lhsFavorite }
            if lhs.id == model.settings.currentPackId { return true }
            if rhs.id == model.settings.currentPackId { return false }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderView(title: "Sound Packs", subtitle: "Browse built-in packs, preview tones, and import custom keyboards.")
            HStack {
                Picker("View", selection: $scope) {
                    ForEach(SoundPackScope.allCases) { scope in
                        Text(scope.rawValue).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 260)
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

            if let report = model.packs.importReport {
                SoundPackImportReportView(report: report)
            } else if let message = model.packs.importMessage {
                StatusBanner(symbol: "info.circle", title: "Import", message: message)
            }

            if filteredPacks.isEmpty {
                StatusBanner(
                    symbol: scope == .favorites ? "star" : "magnifyingglass",
                    title: scope == .favorites ? "No favorite packs yet" : "No sound packs found",
                    message: scope == .favorites ? "Star packs you use often and they will appear here." : "Try another search or category."
                )
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 12)], spacing: 12) {
                    ForEach(filteredPacks) { pack in
                        SoundPackCard(pack: pack)
                    }
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
    @State private var selectedCustomPresetId: String?
    @State private var customPresetName = ""
    @State private var showAdvanced = false

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
                    Toggle("Echo", isOn: Binding(
                        get: { model.echoEnabled },
                        set: {
                            selectedPreset = nil
                            selectedCustomPresetId = nil
                            model.setEchoEnabled($0)
                        }
                    ))
                    .toggleStyle(.switch)
                    .help("Add or remove a short delay echo.")
                    Toggle("Reverb", isOn: Binding(
                        get: { model.reverbEnabled },
                        set: {
                            selectedPreset = nil
                            selectedCustomPresetId = nil
                            model.setReverbEnabled($0)
                        }
                    ))
                    .toggleStyle(.switch)
                    .help("Add or remove room reverb.")
                    Toggle("Ducking", isOn: Binding(
                        get: { model.settings.autoDuckingEnabled },
                        set: {
                            selectedPreset = nil
                            selectedCustomPresetId = nil
                            model.setAutoDuckingEnabled($0)
                        }
                    ))
                    .toggleStyle(.switch)
                    .help("Lower Thock sounds while other Mac audio is active.")
                    Button {
                        model.preview(model.currentPack)
                    } label: {
                        Label("Preview", systemImage: "play.fill")
                    }
                    Button {
                        selectedPreset = nil
                        selectedCustomPresetId = nil
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
                                selectedCustomPresetId = nil
                                preset.apply(to: model.settings)
                                model.audio.applyMixer(settings: model.settings.snapshot)
                                model.preview(model.currentPack)
                            }
                        }
                    }

                    Divider()

                    HStack(spacing: 10) {
                        MixerHeader(symbol: "tray.and.arrow.down", title: "Saved Presets")
                        Spacer()
                        TextField("Preset name", text: $customPresetName)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 180)
                        Button {
                            model.settings.saveCustomMixerPreset(named: customPresetName)
                            customPresetName = ""
                            selectedPreset = nil
                            selectedCustomPresetId = model.settings.customMixerPresets.first?.id
                        } label: {
                            Label("Save", systemImage: "plus")
                        }
                    }

                    if model.settings.customMixerPresets.isEmpty {
                        Text("Save your current mixer settings when you find a sound you want to keep.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 190), spacing: 10)], spacing: 10) {
                            ForEach(model.settings.customMixerPresets) { preset in
                                CustomMixerPresetButton(
                                    preset: preset,
                                    isSelected: selectedCustomPresetId == preset.id,
                                    apply: {
                                        selectedPreset = nil
                                        selectedCustomPresetId = preset.id
                                        model.settings.applyCustomMixerPreset(preset)
                                        model.audio.applyMixer(settings: model.settings.snapshot)
                                        if model.settings.autoDuckingEnabled {
                                            model.audioActivity.refreshIfNeeded(force: true)
                                        } else {
                                            model.audioActivity.clear()
                                        }
                                        model.preview(model.currentPack)
                                    },
                                    delete: {
                                        if selectedCustomPresetId == preset.id {
                                            selectedCustomPresetId = nil
                                        }
                                        model.settings.deleteCustomMixerPreset(preset)
                                    }
                                )
                            }
                        }
                    }
                }
            }

            Panel {
                VStack(alignment: .leading, spacing: showAdvanced ? 14 : 0) {
                    Button {
                        withAnimation(.snappy(duration: 0.18)) {
                            showAdvanced.toggle()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: showAdvanced ? "chevron.down" : "chevron.right")
                                .font(.caption.weight(.semibold))
                                .frame(width: 14)
                            Image(systemName: "slider.horizontal.3")
                                .frame(width: 20)
                            Text("Advanced")
                                .font(.headline)
                            Spacer()
                            Text(showAdvanced ? "Hide detailed controls" : "Levels, tone, playback")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())

                    if showAdvanced {
                        LazyVGrid(columns: columns, spacing: 16) {
                            advancedLevelsPanel
                            advancedTonePanel
                            advancedPlaybackPanel
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
        }
    }

    private var advancedLevelsPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            MixerHeader(symbol: "speaker.wave.2", title: "Levels")
            SliderRow(title: "Master", value: bind(\.masterVolume), range: 0...1)
            SliderRow(title: "Press", value: bind(\.pressVolume), range: 0...1.4)
            SliderRow(title: "Release", value: bind(\.releaseVolume), range: 0...1)
            SliderRow(title: "Spacebar", value: bind(\.spacebarVolume), range: 0...1.5)
            SliderRow(title: "Modifiers", value: bind(\.modifierVolume), range: 0...1)
        }
        .padding(12)
        .background(Color.secondary.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
    }

    private var advancedTonePanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            MixerHeader(symbol: "waveform.path.ecg", title: "Tone")
            SliderRow(title: "Pitch", value: bind(\.pitchShiftSemitones), range: -6...6)
            SliderRow(title: "Variation", value: bind(\.pitchVariation), range: 0...0.08)
            SliderRow(title: "Bass", value: bind(\.bassBoost), range: -1...1)
            SliderRow(title: "Brightness", value: bind(\.brightness), range: -1...1)
            SliderRow(title: "Echo Amount", value: bind(\.echoAmount), range: 0...0.3)
            SliderRow(title: "Reverb Amount", value: bind(\.roomAmount), range: 0...0.3)
        }
        .padding(12)
        .background(Color.secondary.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
    }

    private var advancedPlaybackPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            MixerHeader(symbol: "keyboard.badge.ellipsis", title: "Playback")
            Picker("Sample Mode", selection: Binding(get: { model.settings.samplePlaybackMode }, set: {
                selectedPreset = nil
                selectedCustomPresetId = nil
                model.settings.samplePlaybackMode = $0
            })) {
                ForEach(SamplePlaybackMode.allCases) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .help(model.settings.samplePlaybackMode.helpText)
            Toggle("Release sounds", isOn: Binding(get: { model.settings.releaseSoundsEnabled }, set: {
                selectedPreset = nil
                selectedCustomPresetId = nil
                model.settings.releaseSoundsEnabled = $0
            }))
            Toggle("Modifier sounds", isOn: Binding(get: { model.settings.modifierSoundsEnabled }, set: {
                selectedPreset = nil
                selectedCustomPresetId = nil
                model.settings.modifierSoundsEnabled = $0
            }))
            Toggle("Limiter", isOn: Binding(get: { model.settings.limiterEnabled }, set: {
                selectedPreset = nil
                selectedCustomPresetId = nil
                model.settings.limiterEnabled = $0
            }))
            Picker("Key Repeat", selection: Binding(get: { model.settings.repeatMode }, set: {
                selectedPreset = nil
                selectedCustomPresetId = nil
                model.settings.repeatMode = $0
            })) {
                ForEach(RepeatMode.allCases) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            SliderRow(
                title: "Repeat Rate",
                value: Binding(
                    get: { model.settings.maxRepeatSoundsPerSecond },
                    set: { model.settings.maxRepeatSoundsPerSecond = $0 }
                ),
                range: 1...20
            )
        }
        .padding(12)
        .background(Color.secondary.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
    }

    private func bind(_ keyPath: ReferenceWritableKeyPath<SettingsStore, Float>) -> Binding<Double> {
        Binding(
            get: { Double(model.settings[keyPath: keyPath]) },
            set: {
                model.settings[keyPath: keyPath] = Float($0)
                selectedPreset = nil
                selectedCustomPresetId = nil
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
            assign(settings, master: 0.55, press: 1.0, release: 0.35, spacebar: 1.15, modifiers: 0.30, pitch: 0, variation: 0.020, bass: 0, brightness: 0, room: 0, sampleMode: .stablePerKey, releaseSounds: false, modifierSounds: true, repeatMode: .reduced, repeatRate: 10)
        case .soft:
            assign(settings, master: 0.38, press: 0.80, release: 0.22, spacebar: 0.88, modifiers: 0.16, pitch: -0.75, variation: 0.012, bass: 0.12, brightness: -0.25, room: 0, sampleMode: .stablePerKey, releaseSounds: false, modifierSounds: false, repeatMode: .firstOnly, repeatRate: 7)
        case .deep:
            assign(settings, master: 0.52, press: 1.0, release: 0.28, spacebar: 1.25, modifiers: 0.22, pitch: -2.0, variation: 0.018, bass: 0.55, brightness: -0.35, room: 0, sampleMode: .stablePerKey, releaseSounds: false, modifierSounds: true, repeatMode: .reduced, repeatRate: 9)
        case .crisp:
            assign(settings, master: 0.48, press: 1.05, release: 0.25, spacebar: 1.0, modifiers: 0.20, pitch: 0.75, variation: 0.012, bass: -0.15, brightness: 0.45, room: 0, sampleMode: .stablePerKey, releaseSounds: false, modifierSounds: true, repeatMode: .reduced, repeatRate: 12)
        case .calm:
            assign(settings, master: 0.36, press: 0.72, release: 0.18, spacebar: 0.90, modifiers: 0.12, pitch: -0.25, variation: 0.008, bass: 0.20, brightness: -0.15, room: 0, sampleMode: .stablePerKey, releaseSounds: false, modifierSounds: false, repeatMode: .firstOnly, repeatRate: 6)
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
        sampleMode: SamplePlaybackMode,
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
        settings.echoAmount = 0
        settings.roomAmount = room
        settings.samplePlaybackMode = sampleMode
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

private struct CustomMixerPresetButton: View {
    let preset: CustomMixerPreset
    let isSelected: Bool
    let apply: () -> Void
    let delete: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button(action: apply) {
                HStack(spacing: 8) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "slider.horizontal.3")
                        .frame(width: 18)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(preset.name)
                            .font(.callout.weight(.semibold))
                            .lineLimit(1)
                        Text("\(Int((preset.masterVolume * 100).rounded()))% volume")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
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
            .help("Apply \(preset.name)")

            Button(role: .destructive, action: delete) {
                Image(systemName: "trash")
                    .frame(width: 26, height: 26)
            }
            .buttonStyle(.plain)
            .help("Delete \(preset.name)")
        }
    }
}

struct AppProfilesView: View {
    @EnvironmentObject private var model: AppModel
    @State private var showAppPicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderView(title: "Sound Recipes", subtitle: "Use creamy sounds in writing apps, clicky sounds in code editors, and mute calls automatically.")
            HStack {
                Button {
                    showAppPicker = true
                } label: {
                    Label("Choose App", systemImage: "plus.app")
                }
                Button {
                    model.profileService.addCurrentApp(packId: model.settings.currentPackId)
                } label: {
                    Label("Add Frontmost", systemImage: "scope")
                }
                Button {
                    model.profileService.addSuggestedRecipes()
                } label: {
                    Label("Add Suggested", systemImage: "sparkles")
                }
                Button("Clear Profiles") {
                    model.profileService.resetDefaults()
                }
            }
            Text("Suggested recipes add common writing apps, code editors, and call apps. Switch to another app first, then use Add Frontmost for anything custom.")
                .font(.caption)
                .foregroundStyle(.secondary)

            if model.profileService.profiles.isEmpty {
                StatusBanner(
                    symbol: "paintpalette",
                    title: "No sound recipes yet",
                    message: "Typing sounds use the active sound pack in every app until you add a recipe."
                )
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 12)], spacing: 12) {
                RecipeHintCard(recipe: .creamyWriting, text: "For Notes, Pages, TextEdit, and long writing sessions.")
                RecipeHintCard(recipe: .clickyCoding, text: "For Xcode, VS Code, and focused coding.")
                RecipeHintCard(recipe: .mutedCalls, text: "For Zoom, Teams, FaceTime, Discord, and Webex.")
            }

            ForEach(model.profileService.profiles) { profile in
                Panel {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 14) {
                            Image(systemName: AppSoundRecipe.inferred(from: profile).symbolName)
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
                            Button(role: .destructive) {
                                model.profileService.delete(profile)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .help("Delete")
                        }

                        HStack(spacing: 12) {
                            Picker("Recipe", selection: Binding(
                                get: { AppSoundRecipe.inferred(from: profile) },
                                set: { model.profileService.applyRecipe($0, to: profile) }
                            )) {
                                ForEach(AppSoundRecipe.allCases) { recipe in
                                    Label(recipe.label, systemImage: recipe.symbolName).tag(recipe)
                                }
                            }
                            .frame(width: 180)

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
                            .frame(width: 190)
                        }
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $showAppPicker,
            allowedContentTypes: [UTType.application],
            allowsMultipleSelection: false
        ) { result in
            if case let .success(urls) = result, let url = urls.first {
                model.profileService.addApp(from: url, packId: model.settings.currentPackId)
            }
        }
    }
}

private struct RecipeHintCard: View {
    let recipe: AppSoundRecipe
    let text: String

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: recipe.symbolName)
                    .font(.title3)
                Text(recipe.title)
                    .font(.headline)
                Text(text)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct FocusView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HeaderView(title: "Focus", subtitle: "Pomodoro sessions and character countdowns for writing with keyboard sounds.")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 14)], spacing: 14) {
                Panel {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Label(model.pomodoroPhase.label, systemImage: model.pomodoroPhase.symbolName)
                                .font(.headline)
                            Spacer()
                            Text(model.pomodoroStatusText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Text(model.pomodoroTimeText)
                            .font(.system(size: 44, weight: .bold, design: .rounded).monospacedDigit())
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)

                        ProgressView(value: model.pomodoroProgress)

                        Stepper(value: Binding(
                            get: { model.settings.pomodoroWorkMinutes },
                            set: {
                                model.settings.pomodoroWorkMinutes = $0
                                if model.pomodoroPhase == .idle && !model.pomodoroIsRunning {
                                    model.resetPomodoro()
                                }
                            }
                        ), in: 5...90, step: 5) {
                            Text("Focus: \(model.settings.pomodoroWorkMinutes) min")
                        }

                        Stepper(value: Binding(
                            get: { model.settings.pomodoroBreakMinutes },
                            set: {
                                model.settings.pomodoroBreakMinutes = $0
                                if model.pomodoroPhase == .breakTime && !model.pomodoroIsRunning {
                                    model.startPomodoroBreak()
                                    model.pausePomodoro()
                                }
                            }
                        ), in: 1...30, step: 1) {
                            Text("Break: \(model.settings.pomodoroBreakMinutes) min")
                        }

                        HStack {
                            Button {
                                model.startPomodoroWork()
                            } label: {
                                Label("Start Focus", systemImage: "play.fill")
                            }
                            .buttonStyle(.borderedProminent)

                            Button {
                                if model.pomodoroIsRunning {
                                    model.pausePomodoro()
                                } else {
                                    model.resumePomodoro()
                                }
                            } label: {
                                Label(model.pomodoroIsRunning ? "Pause" : "Resume", systemImage: model.pomodoroIsRunning ? "pause.fill" : "play")
                            }
                            .disabled(model.pomodoroPhase == .idle || model.pomodoroRemainingSeconds == 0)

                            Button {
                                model.startPomodoroBreak()
                            } label: {
                                Label("Break", systemImage: "cup.and.saucer")
                            }

                            Button("Reset") {
                                model.resetPomodoro()
                            }
                        }
                    }
                }

                Panel {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Label("Character Countdown", systemImage: "textformat.123")
                                .font(.headline)
                            Spacer()
                            Text(model.characterCountdownStatusText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Text(model.characterCountdownText)
                            .font(.system(size: 40, weight: .bold, design: .rounded).monospacedDigit())
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)

                        ProgressView(value: model.characterCountdownProgress)

                        Stepper(value: Binding(
                            get: { model.settings.characterCountdownTarget },
                            set: {
                                model.settings.characterCountdownTarget = $0
                                if !model.characterCountdownActive {
                                    model.resetCharacterCountdown()
                                }
                            }
                        ), in: 50...10_000, step: 50) {
                            Text("Goal: \(model.settings.characterCountdownTarget) characters")
                        }

                        Text("Counts text-like key presses such as letters, numbers, punctuation, spaces, tabs, and returns. It does not store the characters.")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack {
                            Button {
                                model.startCharacterCountdown()
                            } label: {
                                Label("Start", systemImage: "play.fill")
                            }
                            .buttonStyle(.borderedProminent)

                            Button {
                                model.pauseCharacterCountdown()
                            } label: {
                                Label("Pause", systemImage: "pause.fill")
                            }
                            .disabled(!model.characterCountdownActive)

                            Button("Reset") {
                                model.resetCharacterCountdown()
                            }
                        }
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
            HeaderView(title: "Privacy", subtitle: "KeyThock does not know what you typed.")
            Panel {
                VStack(alignment: .leading, spacing: 12) {
                    PrivacyBullet(text: "No typed text is stored.")
                    PrivacyBullet(text: "No key activity is sent to servers.")
                    PrivacyBullet(text: "No screenshots or clipboard content are read.")
                    PrivacyBullet(text: "No password fields are bypassed.")
                    PrivacyBullet(text: "Keyboard events are used only for local audio, recipes, and private counters.")
                }
            }
            HStack {
                LocalPlaybackPanel()
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
            HeaderView(title: "Diagnostics", subtitle: "Check audio and local typing detection in one place.")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 12)], spacing: 12) {
                DiagnosticTile(
                    symbol: model.audio.isRunning ? "speaker.wave.2.fill" : "speaker.slash",
                    title: "Audio",
                    value: model.audioStatusText,
                    good: model.audio.isRunning && model.audio.lastError == nil
                )
                DiagnosticTile(
                    symbol: model.listenerState.isRunning ? "checkmark.shield.fill" : "lock.shield",
                    title: "Keyboard Input",
                    value: model.permissions.state.label,
                    good: model.listenerState.isRunning
                )
                DiagnosticTile(
                    symbol: model.listenerState.isRunning ? "keyboard.badge.ellipsis" : "exclamationmark.triangle",
                    title: "Local Listener",
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
                    Text("Type in the in-app pad to verify local keyboard sounds.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    HStack {
                        Label(model.lastKeyboardEventText, systemImage: "keyboard")
                            .font(.callout)
                        Spacer()
                        Button("Restart Listener") {
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
                    LocalPlaybackPanel(framed: false)
                }
            }

            Panel {
                VStack(alignment: .leading, spacing: 12) {
                    Text("In-App Pad")
                        .font(.headline)
                    Text("This pad uses local app keyboard events, which are allowed for Mac App Store apps.")
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
                    LocalPlaybackPanel(framed: false)
                    Button("Restart Audio Engine") { model.restartAudio() }
                    Button("Restart Local Listener") { model.restartKeyboardListener() }
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

struct SoundPackImportReportView: View {
    let report: SoundPackImportReport

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.green)
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Imported \(report.packName)")
                            .font(.headline)
                        Text("Found \(report.sampleCount) samples across \(report.categories.count) categories.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }

                HStack(spacing: 10) {
                    ImportReportMetric(title: "Press", value: "\(report.pressSampleCount)")
                    ImportReportMetric(title: "Release", value: "\(report.releaseSampleCount)")
                    ImportReportMetric(title: "Categories", value: "\(report.categories.count)")
                }

                Text(report.categories.joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                if !report.missingReleaseCategories.isEmpty {
                    Label("Release samples missing for \(report.missingReleaseCategories.joined(separator: ", ")); press samples will be reused.", systemImage: "info.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct ImportReportMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.headline.monospacedDigit())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 7))
    }
}

struct CurrentAppStatusView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: model.profileService.isActiveAppMuted() ? "speaker.slash" : "app.badge")
                .font(.callout)
                .frame(width: 26, height: 26)
                .foregroundStyle(model.profileService.isActiveAppMuted() ? Color.orange : Color.secondary)
                .background(Color.secondary.opacity(0.10), in: RoundedRectangle(cornerRadius: 6))
            VStack(alignment: .leading, spacing: 2) {
                Text(model.profileService.activeAppName)
                    .font(.callout.weight(.semibold))
                    .lineLimit(1)
                Text(model.profileService.isActiveAppMuted() ? "Muted by app profile" : "Using default sound")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.secondary.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct LocalPlaybackPanel: View {
    @EnvironmentObject private var model: AppModel
    var compact = false
    var framed = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 11) {
                Image(systemName: permissionSymbol)
                    .font(.headline)
                    .frame(width: 32, height: 32)
                    .foregroundStyle(permissionColor)
                    .background(permissionColor.opacity(0.13), in: RoundedRectangle(cornerRadius: 7))
                VStack(alignment: .leading, spacing: 4) {
                    Text(permissionTitle)
                        .font(compact ? .caption.weight(.semibold) : .callout.weight(.semibold))
                        .lineLimit(1)
                    Text(permissionMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 8) {
                permissionIconButton(
                    systemName: "keyboard",
                    title: "Open Settings",
                    help: "Open Input Monitoring settings."
                ) {
                    model.openSettingsForPermission()
                }
                permissionIconButton(
                    systemName: "arrow.clockwise",
                    title: "Restart",
                    help: "Restart keyboard monitoring."
                ) {
                    model.refreshPermissionStatus()
                    model.restartKeyboardListener()
                }
            }
        }
        .padding(compact || !framed ? 0 : 12)
        .background(Color.secondary.opacity(compact || !framed ? 0 : 0.07), in: RoundedRectangle(cornerRadius: 8))
    }

    private var permissionSymbol: String {
        model.listenerState.isRunning ? "checkmark.shield.fill" : "keyboard.badge.ellipsis"
    }

    private var permissionColor: Color {
        model.listenerState.isRunning ? .green : .orange
    }

    private var permissionTitle: String {
        model.listenerState.isRunning ? "Keyboard access ready" : "Keyboard access needed"
    }

    private var permissionMessage: String {
        model.listenerState.isRunning
            ? "Type in any app to hear sounds."
            : "Enable Input Monitoring if typing is silent."
    }

    private func permissionIconButton(
        systemName: String,
        title: String,
        help: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .frame(width: 34, height: 28)
        }
        .buttonStyle(.bordered)
        .help(help)
        .accessibilityLabel(title)
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
