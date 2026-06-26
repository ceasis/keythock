# Release 1.0.0 Checklist

## Build Identity

- App name: KeyThock
- Bundle ID: `com.keythock.app`
- Version: `1.0.0`
- Build: `1`
- Category: Utilities
- Minimum macOS: 13.0

## Binary Prep

- Build local QA app: `./scripts/build_app.sh`
- Install local QA build: `./scripts/install_local_app.sh`
- Build sandboxed App Store test app: `KEYTHOCK_SIGNING_PROFILE=appstore ./scripts/build_app.sh`
- Verify Info.plist version: `plutil -p ".build/KeyThock.app/Contents/Info.plist"`
- Verify privacy manifest is bundled: `test -f ".build/KeyThock.app/Contents/Resources/PrivacyInfo.xcprivacy"`
- Generate Xcode app project: `xcodegen generate`
- Archive from `KeyThock.xcodeproj` with the `KeyThock` scheme. Do not archive from the Swift Package view, because that produces a generic archive without App Store distribution.
- Verify archive contains the app: `test -d "build/KeyThock.xcarchive/Products/Applications/KeyThock.app"`

## Manual QA

- Fresh launch from `~/Applications/KeyThock.app`, not `.build`.
- Diagnostics tab: confirm audio preview plays.
- Input Monitoring: enable `~/Applications/KeyThock.app` in System Settings if prompted.
- Diagnostics tab: type in another app and confirm latest key event updates.
- Diagnostics tab: click `Restart Listener` and confirm the keyboard listener returns to running.
- Menu bar pack switching.
- Sound Packs preview speed.
- Mixer presets.
- Keys per-key assignment.
- Imported `.thockpack`, `.zip`, and folder pack.
- Mute 30 minutes and mute until tomorrow.
- Reset local data.

## App Store Connect

- Create app record.
- Add app privacy answers: no tracking, no data collected.
- Add privacy policy URL.
- Add support URL.
- Add 1-10 screenshots.
- Paste App Review notes from `docs/APP_STORE_1.0.0.md`.
- Submit through Xcode Organizer or Transporter using Mac App Store distribution signing from `KeyThock.xcodeproj`.

## Known Review Sensitivities

Input Monitoring is sensitive. The review note must make clear that KeyThock uses keyboard events only for immediate local sound playback and never stores typed text.

The app should not add analytics, crash reporting, or network activity before 1.0.0 unless the App Store privacy answers and privacy policy are updated.
