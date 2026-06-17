# Release 1.0.0 Checklist

## Build Identity

- App name: Thock Studio
- Bundle ID: `com.thockstudio.app`
- Version: `1.0.0`
- Build: `1`
- Category: Utilities
- Minimum macOS: 13.0

## Binary Prep

- Build local QA app: `./scripts/build_app.sh`
- Install local QA build: `./scripts/install_local_app.sh`
- Build sandboxed App Store test app: `THOCK_STUDIO_SIGNING_PROFILE=appstore ./scripts/build_app.sh`
- Verify Info.plist version: `plutil -p ".build/Thock Studio.app/Contents/Info.plist"`
- Verify local QA build has no sandbox entitlements: `codesign -d --entitlements :- ".build/Thock Studio.app"`
- Verify App Store test build sandbox entitlements: `codesign -dvvv --entitlements - ".build/Thock Studio.app"`
- Verify privacy manifest is bundled: `test -f ".build/Thock Studio.app/Contents/Resources/PrivacyInfo.xcprivacy"`

## Manual QA

- Fresh launch from `~/Applications/Thock Studio.app`, not `.build`.
- Clean permission state: `./scripts/reset_input_monitoring_for_qa.sh`.
- Diagnostics tab: confirm audio preview plays.
- Diagnostics tab: confirm Input Monitoring status starts as needed after reset.
- Input Monitoring settings: use `+` and add `~/Applications/Thock Studio.app` if missing.
- Diagnostics tab: click Recheck and confirm keyboard listener running.
- Diagnostics tab: type in another app and confirm latest key event updates.
- Menu bar pack switching.
- Sound Packs preview speed.
- Mixer presets.
- Keys per-key assignment.
- App Profiles mute and pack override.
- Imported `.thockpack`, `.zip`, and folder pack.
- Mute 15 minutes, mute 30 minutes, mute until tomorrow.
- Reset local data.

## App Store Connect

- Create app record.
- Add app privacy answers: no tracking, no data collected.
- Add privacy policy URL.
- Add support URL.
- Add 1-10 screenshots.
- Paste App Review notes from `docs/APP_STORE_1.0.0.md`.
- Submit through Xcode Organizer or Transporter using Mac App Store distribution signing.

## Known Review Sensitivities

Input Monitoring is sensitive. The review note must make clear that Thock Studio only uses key events for immediate local sound playback and never stores typed text.

The app should not add analytics, crash reporting, or network activity before 1.0.0 unless the App Store privacy answers and privacy policy are updated.
