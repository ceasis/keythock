# Thock Studio

Thock Studio is a native macOS menu bar app that adds low-latency mechanical keyboard, typewriter, and focus typing sounds to any Mac keyboard.

This repository implements the product spec in `thock_studio_ideas.md` as a SwiftUI/AppKit macOS app:

- Menu bar popover with volume, pack switching, mute controls, and focus actions.
- Full settings window with Home, Sound Packs, Mixer, App Profiles, Focus, Stats, Privacy, Settings, and Pro screens.
- Input Monitoring permission onboarding.
- Listen-only `CGEventTap` keyboard event pipeline.
- `AVAudioEngine` playback with preloaded procedural sound packs and sample/pitch variation.
- Eight built-in sound packs.
- Press/release sound support, key categories, repeat throttling, temporary mute, quiet hours, meeting-app mute profiles, focus stats, and privacy-safe local counters.
- `.thockpack`, `.zip`, and folder import validation for custom packs with real audio sample loading.
- StoreKit 2 Pro purchase plumbing with a local development unlock fallback.

## Run From Source

```sh
swift run ThockStudio
```

The app opens a SwiftUI settings window and installs a menu bar extra. For global typing sounds, grant Input Monitoring in System Settings when prompted.

## Build a macOS App Bundle

```sh
./scripts/build_app.sh
open ".build/Thock Studio.app"
```

The script builds the release executable, creates `.build/Thock Studio.app`, writes an `Info.plist`, and applies ad-hoc signing when `codesign` is available.

Local builds are signed without App Sandbox entitlements so global keyboard monitoring can work with macOS Input Monitoring. To create a sandboxed App Store test bundle, run:

```sh
THOCK_STUDIO_SIGNING_PROFILE=appstore ./scripts/build_app.sh
```

## Custom Sound Packs

See [docs/THOCKPACK.md](docs/THOCKPACK.md) for the supported manifest and folder layout.
