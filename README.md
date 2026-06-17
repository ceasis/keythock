# Thock Studio

Thock Studio is a native macOS menu bar app that makes any keyboard feel more satisfying by playing recorded keyboard sounds as you type. Choose a sound pack, tune the mixer, assign individual key sounds, and keep everything local on your Mac.

The app is built with SwiftUI, AppKit, CoreGraphics keyboard event taps, and AVAudioEngine.

## Highlights

- Menu bar popover for quick sound selection, volume, preview, mute timers, settings, and diagnostics.
- Recorded keyboard sound packs, including Creamy, Clacky, Thocky, Bubble, Normal, Plastic, Marbly, Poppy, and Clicky variants.
- Low-latency AVAudioEngine playback with preloaded samples, pitch shift, pitch variation, and sample variation.
- Mixer controls for volume, press/release balance, spacebar/modifier levels, bass, brightness, room amount, repeat behavior, and presets.
- Per-key sound assignment with a full keyboard layout.
- Optional app profiles for per-app mute or sound-pack rules.
- Diagnostics for audio output, Input Monitoring, keyboard listener state, and the latest playback decision.
- Privacy-first design: no typed text is stored, reconstructed, or sent anywhere.
- Custom `.thockpack`, `.zip`, and folder import support.

## Requirements

- macOS 13 or later
- Swift 5.9 or later
- Input Monitoring permission for real typing sounds outside the app

## Quick Start

Run from source:

```sh
swift run ThockStudio
```

Build, install, and launch the local app bundle:

```sh
./scripts/install_local_app.sh
```

The installed app lives at:

```text
~/Applications/Thock Studio.app
```

Use this installed copy when granting Input Monitoring permission. macOS permissions are tied to the app bundle identity and location, so testing from `.build` and `~/Applications` can behave differently.

## Input Monitoring

Thock Studio needs macOS Input Monitoring permission so it can detect key press events while you type in other apps. It uses those events only to choose and play local audio samples.

To enable it:

1. Launch Thock Studio.
2. Open the menu bar popover or Diagnostics tab.
3. Click `Open Settings` or `Open Input Monitoring`.
4. In System Settings, add or enable `~/Applications/Thock Studio.app`.
5. Return to Thock Studio and click `Recheck`, or quit and reopen the app.

If preview works but real typing is silent, open `Diagnostics` and check:

- `Audio`: confirms the sound engine is running.
- `Input Monitoring`: confirms keyboard access.
- `Keyboard Listener`: confirms event taps are active.
- `Last key event`: confirms macOS is delivering keyboard events.
- `Last playback decision`: explains whether a key was played or skipped.

The debug log is written to:

```text
~/Library/Logs/Thock Studio/debug.log
```

## Sound Packs

Built-in packs are stored in `Sources/ThockStudio/Resources/SoundPacks`.

Current recorded packs:

- `Bubble-1`
- `Clacky-1`
- `Clacky-2`
- `Clicky-1`
- `Creamy-1`
- `Creamy-2`
- `Creamy-3`
- `Marbly-1`
- `Normal-1`
- `Plastic-1`
- `Poppy-1`
- `Thocky-1`
- `Thocky-2`

Custom packs can be imported from a `.thockpack`, `.zip`, or folder. See [docs/THOCKPACK.md](docs/THOCKPACK.md) for the manifest format and folder layout.

## App Structure

```text
Sources/ThockStudio/
├── AppModel.swift              # Main app state and playback decision pipeline
├── AudioEngineService.swift    # AVAudioEngine sample loading and playback
├── KeyboardEventService.swift  # Global keyboard event monitoring
├── PermissionService.swift     # Input Monitoring permission helpers
├── SoundPackManager.swift      # Built-in and imported sound packs
├── SettingsStore.swift         # Local settings persistence
├── Views.swift                 # Main SwiftUI views
├── KeySoundsView.swift         # Per-key assignment UI
└── Resources/                  # Privacy manifest and bundled sound packs
```

Supporting files:

- `scripts/build_app.sh`: builds `.build/Thock Studio.app`.
- `scripts/install_local_app.sh`: installs to `~/Applications` and launches.
- `scripts/reset_input_monitoring_for_qa.sh`: resets Thock Studio's local permission state for QA.
- `docs/LOCAL_QA.md`: clean local QA flow.
- `docs/RELEASE_1.0.0.md`: release checklist.
- `docs/APP_STORE_1.0.0.md`: App Store Connect draft.
- `docs/PRIVACY_POLICY.md`: privacy policy draft.

## Build Modes

Local QA builds are intentionally signed without App Sandbox entitlements because global keyboard monitoring depends on macOS Input Monitoring.

```sh
./scripts/build_app.sh
```

To build a sandboxed App Store validation bundle:

```sh
THOCK_STUDIO_SIGNING_PROFILE=appstore ./scripts/build_app.sh
```

To verify whether the local app has entitlements:

```sh
codesign -d --entitlements :- "$HOME/Applications/Thock Studio.app"
```

For local QA, the expected output is empty because the app is ad-hoc signed without sandbox entitlements.

## Privacy

Thock Studio is designed as a local utility:

- It does not store typed text.
- It does not reconstruct words, sentences, or documents.
- It does not read the clipboard.
- It does not take screenshots.
- It does not require an account or backend service.
- It does not include analytics, advertising, or tracking SDKs.

The app stores local preferences such as selected sound pack, volume, mixer settings, mute state, app profiles, and per-key sound assignments.

## Troubleshooting

### Preview plays, but real typing is silent

1. Confirm you are running `~/Applications/Thock Studio.app`.
2. Open System Settings > Privacy & Security > Input Monitoring.
3. Remove old Thock Studio entries if needed.
4. Add `~/Applications/Thock Studio.app`.
5. Enable it, then quit and reopen Thock Studio.
6. Open Diagnostics and type in another app.

### Thock Studio is not listed in Input Monitoring

Use the `Show App` button in Thock Studio, then add that exact app bundle with the `+` button in System Settings.

### Sounds are doubled or too busy

Open `Mixer` and adjust repeat behavior, sample variation, press/release balance, and per-key overrides.

### Imported pack does not appear

Check that the pack has a valid `manifest.json`, at least one `alpha.press` sample, and supported audio files. See [docs/THOCKPACK.md](docs/THOCKPACK.md).

## Development Notes

The app currently prioritizes local/direct-distribution behavior for keyboard monitoring. App Store submission may require additional review work because Input Monitoring and sandboxing are sensitive macOS areas.

Before release, run through [docs/LOCAL_QA.md](docs/LOCAL_QA.md) and [docs/RELEASE_1.0.0.md](docs/RELEASE_1.0.0.md).

## License

See [LICENSE](LICENSE).
