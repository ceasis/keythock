# KeyThock 1.0.0 App Store Connect Draft

## App Information

Name: KeyThock

Subtitle: Keyboard sounds for Mac

Bundle ID: `com.keythock.app`

SKU: `keythock-mac-001`

Primary Language: English (U.S.)

Primary Category: Utilities

Secondary Category: Music

Age Rating: 4+

Made for Kids: No

Price: Paid upfront recommended. Suggested starting price: USD 4.99.

Privacy Policy URL: TODO publish `docs/PRIVACY_POLICY.md` to a public URL before submission.

Support URL: TODO publish a simple support page or mailto-backed page before submission.

Marketing URL: Optional.

## Version Information

Version: `1.0.0`

Build: `1`

Copyright: Copyright KeyThock

What's New:

Initial release of KeyThock for Mac.

## Promotional Text

Make your Mac keyboard sound creamy, clacky, thocky, bubbly, or fully custom with local-only typing sounds.

## Description

KeyThock adds satisfying mechanical keyboard sounds to your Mac.

Choose from recorded keyboard sound packs, tune the feel with a simple mixer, and assign individual samples to specific keys. Want Space to sound deeper than A, or Enter to hit differently from the rest of the board? Open the Keys editor, click a key, and cycle through the samples in the active pack until it feels right.

Everything runs locally on your Mac. KeyThock uses macOS Input Monitoring only to detect key press timing and key category for sound playback. It does not store what you type, reconstruct words, send keystrokes to a server, read your clipboard, or take screenshots.

Features:
- Recorded sound packs including creamy, clacky, thocky, bubble, normal, plastic, marbly, clicky, poppy, typewriter, and Morse tones
- Per-key sample assignment with a full keyboard editor
- Mixer presets for balanced, soft, deep, crisp, and calm typing
- Pitch, bass, brightness, echo, reverb, ducking, repeat, release, and modifier controls
- App profiles for muting or changing sounds in specific apps
- Diagnostics for checking audio output, Input Monitoring, and keyboard listener status
- Menu bar controls for quick preview, muting, volume, effects, and sound switching
- Custom sound pack import using local `.thockpack`, `.zip`, or folder packs

KeyThock is for people who want their keyboard to feel more personal, cozy, and fun without changing hardware.

## Keywords

keyboard,mechanical,typing,sound,thock,clacky,creamy,mac,menu bar,asmr

## App Review Notes

KeyThock is a local keyboard sound utility for macOS.

The app requests Input Monitoring because it needs to detect keyboard events while the user types in other apps, then immediately play a local keypress sound. The app uses the event key code and event phase only for local sound selection.

Privacy-specific behavior:
- No typed text is stored.
- No words, sentences, passwords, or text content are reconstructed.
- No keyboard events are sent over the network.
- No analytics SDKs, ads, or tracking SDKs are included.
- The app does not read clipboard contents.
- The app does not capture screenshots.
- Settings and sound preferences are stored locally with UserDefaults.
- Imported sound packs are copied locally into the app's Application Support folder.

Suggested review flow:
1. Launch KeyThock.
2. Grant Input Monitoring permission when prompted, or open System Settings from the app.
3. Choose a sound pack from the menu bar or Sound Packs tab.
4. Use the Test Typing Pad or type in another app to hear local keyboard sounds.
5. Open the Keys tab and click keys to assign per-key samples.
6. Open Mixer and try presets such as Deep, Crisp, or Calm.
7. Open Diagnostics to verify audio output, permission status, keyboard listener status, and latest key event.

No account is required. No network service is required.

## App Privacy

Tracking: No.

Data collected: None.

Data linked to the user: None.

Data used to track the user: None.

Third-party SDKs: None.

Notes for App Store Connect privacy questionnaire:
- Do not list keystrokes as collected data because the app does not transmit, store, or use them outside local real-time sound playback.
- Local settings are stored on device only.
- User-selected imported sound packs remain local.

## Privacy Manifest

Bundled file: `Sources/KeyThock/Resources/PrivacyInfo.xcprivacy`

Declared tracking: false.

Declared collected data types: none.

Required reason API:
- `NSPrivacyAccessedAPICategoryUserDefaults`
- Reason: `CA92.1`, app-only settings storage.

## Permissions

Input Monitoring usage description:

KeyThock needs Input Monitoring to detect key presses locally and play keyboard sounds. It never stores typed text.

Sandbox entitlements:
- `com.apple.security.app-sandbox`
- `com.apple.security.files.user-selected.read-only`

Sandbox usage note:

The file access entitlement is used only when the user explicitly imports a local sound pack file, zip, thockpack, or folder.

Build note:

Local QA builds are intentionally signed without App Sandbox entitlements because global keyboard monitoring depends on macOS Input Monitoring. Use `KEYTHOCK_SIGNING_PROFILE=appstore ./scripts/build_app.sh` only when producing a sandboxed App Store validation build.

## Screenshots

App Store Connect requires at least one screenshot and accepts up to ten. Recommended set:

1. Sound Packs: recorded keyboard sounds and preview buttons.
2. Keys: full keyboard editor with per-key sample assignments.
3. Mixer: presets and level/tone/playback controls.
4. Menu Bar: compact controls for volume, pack switching, effects, preview, and mute.
5. Diagnostics: audio, Input Monitoring, listener, and typing test status.
6. Privacy: local-only explanation and Input Monitoring controls.

Optional app preview video:

Landscape macOS video showing sound pack preview, key assignment, and typing with the menu bar open.

## Release Checklist

- Publish privacy policy URL.
- Publish support URL.
- Create App Store Connect app record with Bundle ID `com.keythock.app`.
- Confirm primary category Utilities matches `LSApplicationCategoryType`.
- Upload at least one macOS screenshot.
- Verify App Sandbox information if App Store Connect asks for entitlement details.
- Archive from `KeyThock.xcodeproj` with the `KeyThock` scheme and a Mac App Store distribution certificate/provisioning profile.
- Do not archive from the Swift Package view; that creates a generic archive and Organizer will not show the App Store distribution option.
- Test permission flow on a clean macOS user account before submission.
- Confirm Input Monitoring review note is included.
- Confirm app privacy answers say no tracking and no data collected.

## Apple References

- App submission overview: https://developer.apple.com/app-store/submitting/
- App information fields: https://developer.apple.com/help/app-store-connect/reference/app-information/app-information
- Screenshots and app previews: https://developer.apple.com/help/app-store-connect/manage-app-information/upload-app-previews-and-screenshots
- App privacy details: https://developer.apple.com/app-store/app-privacy-details/
- App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- App Sandbox: https://developer.apple.com/documentation/security/app-sandbox
- Privacy manifests: https://developer.apple.com/documentation/bundleresources/privacy-manifest-files
