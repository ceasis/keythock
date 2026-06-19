<p align="center">
  <img src="Assets/AppIconSource.png" alt="KeyThock icon" width="96">
</p>

# KeyThock

KeyThock is a native macOS menu bar app that makes any keyboard sound and feel more satisfying. It plays recorded keyboard samples as you type, with sound packs for creamy, clacky, thocky, bubble, normal, plastic, marbly, poppy, and clicky keyboard tones.

It is built for people who spend all day typing: developers, writers, students, note-takers, desk setup people, and anyone who wants their Mac keyboard to feel a little more alive.

Everything runs locally on the Mac. KeyThock does not store what you type, reconstruct words, read the clipboard, take screenshots, or send keystrokes anywhere.

## What It Does

- Plays recorded keyboard sounds while you type in any app.
- Runs from a compact menu bar popover.
- Lets you switch sound packs instantly.
- Includes volume, preview, mute timers, and quick diagnostics.
- Provides a full settings window for sound packs, mixer, per-key sounds, app profiles, diagnostics, privacy, and general settings.
- Lets you tune sound with mixer presets, pitch, brightness, bass, room amount, repeat behavior, and key-category levels.
- Lets you assign specific samples to individual keys using a full keyboard layout.
- Supports optional per-app profiles for muting or changing sound packs in specific apps.
- Imports custom `.thockpack`, `.zip`, or folder-based sound packs.

## Current Sound Packs

Built-in packs are generated from user-provided recordings and live in `Sources/KeyThock/Resources/SoundPacks`.

| Pack | Character |
| --- | --- |
| `Creamy-1` | Original creamy keyboard recording |
| `Creamy-2` | Creamy section from the Creamy/Clacky/Thocky recording |
| `Creamy-3` | Additional creamy keyboard recording |
| `Clacky-1` | Clacky section from the Creamy/Clacky/Thocky recording |
| `Clacky-2` | Additional clacky recording |
| `Clicky-1` | Clicky switch recording |
| `Thocky-1` | Thocky section from the Creamy/Clacky/Thocky recording |
| `Thocky-2` | Additional thocky recording |
| `Bubble-1` | Bubble keyboard recording |
| `Normal-1` | Normal keyboard recording |
| `Plastic-1` | Plastic keyboard recording |
| `Marbly-1` | Marbly keyboard recording |
| `Poppy-1` | Poppy keyboard recording |

## Requirements

- macOS 13 or later
- Swift 5.9 or later
- Input Monitoring permission for real typing sounds outside KeyThock

## Quick Start

For normal local testing, build and install the app bundle:

```sh
./scripts/install_local_app.sh
```

This builds KeyThock, installs it to:

```text
~/Applications/KeyThock.app
```

and launches that installed copy.

Use the installed copy when granting macOS permissions. Input Monitoring is tied to the app bundle identity and location, so running from `.build` and running from `~/Applications` can produce different permission behavior.

You can also run directly from SwiftPM:

```sh
swift run KeyThock
```

That is useful for development, but less reliable for permission QA.

## Input Monitoring Setup

KeyThock needs macOS Input Monitoring permission so it can observe key press events while you type in other apps. It uses those events only to choose and play local audio samples.

To enable typing sounds:

1. Launch `~/Applications/KeyThock.app`.
2. Open the KeyThock menu bar popover.
3. Click `Open Settings` in the keyboard access callout.
4. In System Settings, open `Privacy & Security` > `Input Monitoring`.
5. Enable `KeyThock.app`.
6. If KeyThock is missing, click `+` and add `~/Applications/KeyThock.app`.
7. Return to KeyThock and click `Recheck`, or quit and reopen the app.

If preview sounds work but real typing is silent, open `Diagnostics`. The most important fields are:

| Diagnostic | Meaning |
| --- | --- |
| `Audio` | Whether AVAudioEngine is running |
| `Input Monitoring` | Whether macOS permission appears available |
| `Keyboard Listener` | Whether keyboard event taps are active |
| `Last key event` | Whether KeyThock is receiving real keyboard events |
| `Last playback decision` | Why the app played or skipped the latest key |

Debug logs are written to:

```text
~/Library/Logs/KeyThock/debug.log
```

## Using The App

### Menu Bar

The menu bar popover is for daily use:

- Turn sounds on or off.
- Adjust volume.
- Choose a sound pack.
- Preview the current pack.
- Mute for 30 minutes.
- Open Mixer, Settings, or Diagnostics.
- Fix Input Monitoring if keyboard access is blocked.

### Sound Packs

Browse built-in packs, preview them, select the active pack, and import custom packs.

### Mixer

Shape the active pack with presets and detailed controls:

- Master volume
- Press and release volume
- Spacebar and modifier volume
- Pitch shift and pitch variation
- Sample variation
- Bass, brightness, and room amount
- Repeat handling

### Keys

Assign a specific sample to each key. Click a key to cycle through samples in the current sound pack. The selected sample becomes the sound used for that key while typing.

### App Profiles

Create optional per-app rules. For example, mute KeyThock in a meeting app or use a different sound pack in a writing app.

### Diagnostics

Use Diagnostics when something feels wrong. It separates audio output, permission state, keyboard listener state, and playback decisions so issues are easier to isolate.

## Custom Sound Packs

KeyThock can import `.thockpack`, `.zip`, or folder sound packs.

Minimum structure:

```text
MyPack.thockpack
├── manifest.json
├── artwork.png
├── preview.wav
└── samples
    ├── alpha
    │   ├── press_01.wav
    │   └── release_01.wav
    ├── space
    ├── enter
    ├── backspace
    ├── tab
    ├── escape
    ├── arrow
    ├── modifier
    └── function
```

At least one `alpha.press` sample is required. WAV, AIFF, CAF, and M4A files are supported when AVFoundation can decode them.

See [docs/THOCKPACK.md](docs/THOCKPACK.md) for the full manifest format.

## Project Structure

| Path | Purpose |
| --- | --- |
| `Sources/KeyThock/AppModel.swift` | Main app state and playback decision pipeline |
| `Sources/KeyThock/AudioEngineService.swift` | AVAudioEngine setup, sample loading, playback, preview sequences |
| `Sources/KeyThock/KeyboardEventService.swift` | Global keyboard event monitoring and fallback taps |
| `Sources/KeyThock/PermissionService.swift` | Input Monitoring permission checks and settings shortcuts |
| `Sources/KeyThock/SoundPackManager.swift` | Built-in and imported sound pack management |
| `Sources/KeyThock/SettingsStore.swift` | UserDefaults-backed settings persistence |
| `Sources/KeyThock/ProfileService.swift` | Optional per-app sound rules |
| `Sources/KeyThock/HotkeyService.swift` | Global mute/unmute shortcut |
| `Sources/KeyThock/Views.swift` | Main SwiftUI interface |
| `Sources/KeyThock/KeySoundsView.swift` | Per-key assignment interface |
| `Sources/KeyThock/Resources` | Bundled sound packs and privacy manifest |

## Build Commands

Run from source:

```sh
swift run KeyThock
```

Build an app bundle:

```sh
./scripts/build_app.sh
```

Install and launch the local QA app:

```sh
./scripts/install_local_app.sh
```

Reset KeyThock's Input Monitoring state for clean QA:

```sh
./scripts/reset_input_monitoring_for_qa.sh
```

## App Store Archive

Use the generated Xcode app project for App Store distribution:

```sh
xcodegen generate
open KeyThock.xcodeproj
```

In Xcode, select the `KeyThock` scheme, then use `Product` > `Archive`. The archive must contain `Products/Applications/KeyThock.app`; if you archive from the Swift Package view, Xcode creates a generic archive and Organizer will not show the App Store distribution option.

Command-line equivalent:

```sh
xcodebuild -project KeyThock.xcodeproj \
  -scheme KeyThock \
  -configuration Release \
  -destination 'generic/platform=macOS' \
  -archivePath build/KeyThock.xcarchive \
  archive
```

## Signing Modes

Local builds are intentionally signed without App Sandbox entitlements:

```sh
./scripts/build_app.sh
```

This is the expected mode for local QA because global keyboard monitoring depends on macOS Input Monitoring and is sensitive to sandboxing.

To create a sandboxed App Store validation build:

```sh
KEYTHOCK_SIGNING_PROFILE=appstore ./scripts/build_app.sh
```

Verify entitlements:

```sh
codesign -d --entitlements :- "$HOME/Applications/KeyThock.app"
```

For local QA, empty entitlement output is expected.

## Privacy Model

KeyThock is designed as a local Mac utility.

It does not:

- Store typed text
- Reconstruct words or sentences
- Read clipboard contents
- Capture screenshots
- Upload key activity
- Require an account
- Include analytics, advertising, or tracking SDKs

It does store local preferences, including:

- Selected sound pack
- Volume and mixer settings
- Mute settings
- Per-key sample assignments
- Optional app profiles
- Imported sound pack files

See [docs/PRIVACY_POLICY.md](docs/PRIVACY_POLICY.md) for the privacy policy draft.

## Troubleshooting

### Preview works, but typing in other apps is silent

1. Confirm the running app is `~/Applications/KeyThock.app`.
2. Confirm `KeyThock.app` is enabled in System Settings > Privacy & Security > Input Monitoring.
3. Quit and reopen KeyThock after enabling permission.
4. Open Diagnostics and type in another app.
5. Check `Last key event` and `Last playback decision`.

If `Last key event` updates, the app is receiving keyboard events. If `Last playback decision` says a sound was skipped, it will also say why.

### Input Monitoring says enabled, but KeyThock says blocked

macOS permission state can lag behind the actual event stream after rebuilding or re-signing. Quit and reopen KeyThock, then type in another app and check Diagnostics. KeyThock trusts observed keyboard events when macOS delivers them.

If the issue persists, remove KeyThock from Input Monitoring, add `~/Applications/KeyThock.app` again, enable it, and restart the app.

### KeyThock is missing from Input Monitoring

Use `Show App` in KeyThock, then add that exact app bundle with the `+` button in System Settings.

### Sounds are doubled or too busy

Open Mixer and adjust repeat behavior, press/release balance, sample variation, and per-key overrides.

### Imported sound pack fails

Check that:

- `manifest.json` exists.
- The manifest uses schema version `1`.
- At least one `alpha.press` sample is present.
- Sample paths stay inside the pack folder.
- Audio files are decodable by AVFoundation.

## Release Notes And QA

Useful documents:

- [docs/LOCAL_QA.md](docs/LOCAL_QA.md)
- [docs/RELEASE_1.0.0.md](docs/RELEASE_1.0.0.md)
- [docs/APP_STORE_1.0.0.md](docs/APP_STORE_1.0.0.md)
- [docs/PRIVACY_POLICY.md](docs/PRIVACY_POLICY.md)

App Store distribution needs special care because Input Monitoring and App Sandbox are sensitive macOS review areas. The local build path is currently the most reliable path for keyboard monitoring QA.

## License

See [LICENSE](LICENSE).
