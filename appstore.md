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

KeyThock adds satisfying mechanical keyboard sounds to your Mac while you type in your normal apps.

Choose from recorded keyboard sound packs, tune the feel with a simple mixer, and assign individual samples to specific keys. Want Space to sound deeper than A, or Enter to hit differently from the rest of the board? Open the Keys editor, click a key, and cycle through the samples in the active pack until it feels right.

Everything runs locally on your Mac. KeyThock uses macOS Input Monitoring only to detect key press timing and key identity for immediate local sound playback. It does not store what you type, reconstruct words, send keystrokes to a server, read your clipboard, or take screenshots.

Features:
- Recorded sound packs including creamy, clacky, thocky, bubble, normal, plastic, marbly, clicky, poppy, typewriter, and Morse tones
- System-wide typing sounds while using normal Mac apps
- Per-key sample assignment with a full keyboard editor
- Per-app sound recipes for writing apps, code editors, and call apps
- Pomodoro focus timer and private typed-character countdown
- Mixer presets for balanced, soft, deep, crisp, and calm typing
- Pitch, bass, brightness, echo, reverb, ducking, repeat, release, and modifier controls
- Diagnostics for checking audio output, Input Monitoring, keyboard listener status, and playback
- Menu bar controls for quick preview, muting, volume, effects, and sound switching
- Custom sound pack import using local `.thockpack`, `.zip`, or folder packs

KeyThock is for people who want their keyboard to feel more personal, cozy, and fun without changing hardware.

## Keywords

keyboard,mechanical,typing,sound,thock,clacky,creamy,mac,menu bar,asmr

## App Review Notes

KeyThock is a local keyboard sound utility for macOS. Its core feature is to play a short local sound at the moment the user presses a physical key while typing in their normal Mac apps.

`NSEvent.addLocalMonitorForEvents` is not sufficient for this app because it only observes events delivered to KeyThock itself. KeyThock needs to respond while the user types in other apps, so it requests macOS Input Monitoring and uses a listen-only keyboard event tap for timing and key identity.

The app does not use Accessibility APIs to inspect UI elements, control other apps, automate the Mac, read screen contents, or provide non-accessibility UI control. Keyboard access is used only for immediate local audio playback.

Privacy-specific behavior:
- Input Monitoring is used only to detect key press and key release timing for local sound playback.
- Event key identity is used only to choose the matching local audio sample.
- No typed text is stored.
- No words, sentences, passwords, or text content are reconstructed.
- Raw key events and live key identities are not logged or persisted after playback.
- The typed-character countdown stores only a remaining count, not typed characters.
- No keyboard events are sent over the network.
- No analytics SDKs, ads, or tracking SDKs are included.
- The app does not read clipboard contents.
- The app does not capture screenshots.
- Settings and sound preferences are stored locally with UserDefaults.
- User-created per-key sample assignments are stored locally only as settings and are not derived from a typing history.
- Imported sound packs are copied locally into the app's Application Support folder.

Suggested review flow:
1. Launch KeyThock.
2. Grant Input Monitoring permission when prompted, or open System Settings from the app.
3. Quit and reopen KeyThock if macOS asks after enabling the permission.
4. Choose a sound pack from the menu bar or Sound Packs tab.
5. Type in Notes, TextEdit, Safari, or another normal Mac app to hear local keyboard sounds.
6. Open the Keys tab and click keys to assign per-key samples.
7. Open Recipes and add suggested per-app recipes.
8. Open Focus and try the Pomodoro timer or typed-character countdown.
9. Open Mixer and try presets such as Deep, Crisp, or Calm.
10. Open Diagnostics to verify audio output, Input Monitoring, keyboard listener status, and latest key event.

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

Use `KEYTHOCK_SIGNING_PROFILE=appstore ./scripts/build_app.sh` when producing a sandboxed App Store validation build.

## Screenshots

App Store Connect requires at least one screenshot and accepts up to ten. Recommended set:

1. Sound Packs: recorded keyboard sounds and preview buttons.
2. Keys: full keyboard editor with per-key sample assignments.
3. Mixer: presets and level/tone/playback controls.
4. Menu Bar: compact controls for volume, pack switching, effects, preview, and mute.
5. Diagnostics: audio, Input Monitoring, listener, and typing status.
6. Privacy: local-only explanation and Input Monitoring purpose.

Optional app preview video:

Landscape macOS video showing sound pack preview, key assignment, mixer changes, and typing in a normal Mac app.

## Release Checklist

- Publish privacy policy URL.
- Publish support URL.
- Create App Store Connect app record with Bundle ID `com.keythock.app`.
- Confirm primary category Utilities matches `LSApplicationCategoryType`.
- Upload at least one macOS screenshot.
- Verify App Sandbox information if App Store Connect asks for entitlement details.
- Archive from `KeyThock.xcodeproj` with the `KeyThock` scheme and a Mac App Store distribution certificate/provisioning profile.
- Do not archive from the Swift Package view; that creates a generic archive and Organizer will not show the App Store distribution option.
- Test Input Monitoring on a clean macOS user account before submission.
- Confirm review notes explain why Input Monitoring is required for system-wide typing sounds.
- Confirm app privacy answers say no tracking and no data collected.

## Apple References

- App submission overview: https://developer.apple.com/app-store/submitting/
- App information fields: https://developer.apple.com/help/app-store-connect/reference/app-information/app-information
- Screenshots and app previews: https://developer.apple.com/help/app-store-connect/manage-app-information/upload-app-previews-and-screenshots
- App privacy details: https://developer.apple.com/app-store/app-privacy-details/
- App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- App Sandbox: https://developer.apple.com/documentation/security/app-sandbox
- Privacy manifests: https://developer.apple.com/documentation/bundleresources/privacy-manifest-files
