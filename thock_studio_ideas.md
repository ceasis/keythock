# ideas.md

# Thock Studio — Premium Mechanical Keyboard Sound App for macOS

Version: 1.0  
Document type: Developer-ready product specification  
Platform: macOS  
Working product name: Thock Studio  
Alternative names: KeyTone Pro, MechaKeys, ClackLab, SwitchSound, Typing Studio  
Recommended first product name: Thock Studio  
Recommended App Store subtitle: Mechanical keyboard sounds  
Recommended tagline: Make any Mac keyboard sound premium.

---

## 1. Product Summary

Thock Studio is a native macOS menu bar app that makes any Mac keyboard sound like a premium mechanical keyboard. Every keystroke triggers realistic, low-latency sound feedback using professionally recorded switch sound packs. The app should feel polished, lightweight, private, and instantly satisfying.

The core promise is simple:

> Turn your quiet Mac keyboard into a satisfying mechanical keyboard experience without buying new hardware.

The app is for people who type all day: developers, writers, students, office workers, creators, gamers, mechanical keyboard fans, ASMR fans, and productivity enthusiasts. The app should make typing feel more enjoyable, focused, and premium.

The product must not feel like a toy. It should feel like a beautifully designed Mac utility: minimal, fast, elegant, privacy-first, and worth paying for.

---

## 2. Product Positioning

### 2.1 Category

macOS utility / productivity / audio personalization / ASMR typing app.

### 2.2 Core User Problem

Many Mac users like the satisfying sound of mechanical keyboards, but they may not want to buy, carry, or use an actual mechanical keyboard. Some users work on MacBooks, silent office keyboards, or low-profile keyboards that feel boring. They want their typing to feel more alive, more focused, and more enjoyable.

### 2.3 Product Solution

Thock Studio listens for keyboard events locally on the Mac and plays realistic switch sounds immediately. It does not record typed text, does not send keystroke data to a server, and does not require an account. It gives the user a premium typing atmosphere with selectable sound packs, volume controls, app-specific profiles, focus tools, and a beautiful Mac-native interface.

### 2.4 Market Gap

Current keyboard sound apps prove that demand exists. However, the product can win by being more premium in these areas:

1. Faster perceived audio response.
2. Better onboarding for macOS privacy permissions.
3. Better sound quality and switch realism.
4. Better UI/UX and more premium branding.
5. Better per-app profiles.
6. Better privacy messaging.
7. Better sound pack management.
8. Better focus/productivity positioning.
9. Better one-time purchase offer.
10. Better experience for developers and writers.

### 2.5 Differentiation

Thock Studio should not be positioned as just “keyboard click sounds.” It should be positioned as a premium typing environment.

Main differentiators:

- Native Swift/SwiftUI macOS app.
- Menu bar first, with optional full settings window.
- Local-only keystroke handling.
- No typed text logging.
- Studio-recorded sound packs.
- Per-key sound mapping.
- Separate press and release sounds.
- Randomized pitch and sample variation.
- App-specific sound profiles.
- Meeting mode and quiet hours.
- Built-in focus sessions.
- Sound pack importer for power users.
- Clean, trust-building privacy onboarding.
- Simple lifetime pricing.

---

## 3. Target Users

### 3.1 Primary Personas

#### Persona 1: The Developer

The developer spends many hours in VS Code, Xcode, Terminal, JetBrains IDEs, or similar tools. They like mechanical keyboards, desk setups, and productivity tools. They want typing to feel satisfying while coding.

Main needs:

- Low latency.
- Works in Terminal and code editors.
- Does not interfere with shortcuts.
- Can mute automatically during meetings.
- Has darker, thocky, premium sounds.
- Runs quietly in the menu bar.
- Does not collect sensitive code or passwords.

Best sound packs for this persona:

- Deep Thock Linear.
- Gateron Black Ink style.
- Topre Soft.
- Terminal Retro.
- Silent Tactile.

#### Persona 2: The Writer

The writer uses Apple Notes, Pages, Scrivener, Google Docs, Notion, Obsidian, or Ulysses. They want typing to feel rhythmic and relaxing.

Main needs:

- Gentle sounds.
- Focus mode.
- Writing session stats.
- Comfortable volume.
- Typewriter option.
- App-specific presets.
- No distraction.

Best sound packs:

- Creamy Tactile.
- Soft Typewriter.
- Rainy Desk.
- Library Keys.
- Vintage Writer.

#### Persona 3: The Office Worker

The office worker uses email, documents, spreadsheets, chat apps, browser tools, and productivity apps. They want their workspace to feel more fun without being annoying.

Main needs:

- Simple on/off.
- Low volume.
- Meeting detection or quick mute.
- App-specific quiet mode for Zoom/Teams.
- Launch at login.
- Easy setup.

Best sound packs:

- Office Soft.
- Low Profile Mac.
- Quiet Brown.
- Minimal Click.

#### Persona 4: The Mechanical Keyboard Hobbyist

The hobbyist already knows switch types, keycaps, thock, clack, tactile, clicky, linear, lubed switches, plate materials, and keyboard acoustics. They want realistic control.

Main needs:

- Real switch names or switch-inspired packs.
- Press/release samples.
- Spacebar, enter, backspace, modifier differences.
- Sound pack import/export.
- Fine tuning.
- Pitch randomization.
- Resonance and room controls.
- Ability to build custom packs.

Best sound packs:

- Lubed Linear.
- Clicky Blue.
- Tactile Brown.
- Topre.
- Buckling Spring.
- Aluminum Case.
- Polycarbonate Case.

#### Persona 5: The ASMR / Focus User

This user wants relaxing typing sounds for mood, focus, or content creation. They may not care about switch realism. They care about pleasant audio texture.

Main needs:

- Soft, consistent, soothing sounds.
- Ambient layers.
- Timer.
- Presets for deep work.
- Headphone-friendly sound.
- No harsh clicks.

Best sound packs:

- Soft Rain Keys.
- Cozy Desk.
- Cafe Typing.
- Midnight Keyboard.
- Gentle Thock.

---

## 4. Product Goals

### 4.1 Business Goals

1. Launch a polished macOS utility that feels instantly understandable.
2. Create a product users can buy impulsively because the value is clear within 10 seconds.
3. Use one-time lifetime pricing to reduce friction.
4. Make the free version useful enough to build trust but limited enough to convert.
5. Build a product that can expand through premium sound packs.
6. Create a brand that works for App Store, Gumroad-style direct sales, TikTok demos, YouTube Shorts, and desk setup communities.

### 4.2 User Experience Goals

1. User installs app.
2. User grants permission.
3. User selects a sound pack.
4. User types and immediately smiles.
5. User can control volume and mute quickly.
6. User trusts that the app is not keylogging.
7. User can leave it running all day.

### 4.3 Technical Goals

1. Audio response target: under 10 ms from keyboard event received to sample playback scheduling on supported hardware.
2. CPU usage target while typing normally: under 3% on Apple Silicon.
3. Idle CPU target: under 0.3%.
4. Memory target: under 150 MB with several sound packs preloaded.
5. No typed text persistence.
6. No outbound network calls required for core app usage.
7. Support Apple Silicon and Intel Macs.
8. Support macOS 13 Ventura and later.
9. Gracefully handle missing permissions.
10. Gracefully handle Secure Input and system event tap limitations.

---

## 5. Non-Goals

The first version should not attempt to do the following:

1. It should not record or reconstruct typed words.
2. It should not upload key activity to a server.
3. It should not replace actual keyboard firmware behavior.
4. It should not modify keyboard input.
5. It should not remap keys.
6. It should not act as a full productivity tracker.
7. It should not require a user account.
8. It should not include cloud sync in MVP.
9. It should not include AI sound generation in MVP.
10. It should not rely on Electron for the main app.
11. It should not use invasive permissions beyond what is needed.
12. It should not play sounds in password fields if macOS secure input blocks event monitoring.
13. It should not attempt to bypass macOS security protections.

---

## 6. MVP Definition

### 6.1 MVP Must-Have Features

The first release must include:

1. macOS native menu bar app.
2. Permission onboarding for Input Monitoring.
3. Real-time keystroke sound playback.
4. Separate sound handling for common key categories:
   - Letters and numbers.
   - Spacebar.
   - Enter/Return.
   - Backspace/Delete.
   - Tab.
   - Escape.
   - Arrow keys.
   - Modifier keys.
5. At least 8 built-in sound packs.
6. Volume slider.
7. Master on/off toggle.
8. Launch at login toggle.
9. App-specific mute list.
10. Meeting mode / temporary mute.
11. Randomized sample variation.
12. Randomized pitch variation.
13. Press and release sound support.
14. Privacy screen explaining exactly what is and is not captured.
15. Basic usage stats, with privacy-safe counters only.
16. Dark mode and light mode support.
17. One-time Pro unlock.
18. Trial or free tier.
19. Crash-safe audio engine restart.
20. First-run test typing area.

### 6.2 MVP Should-Have Features

These should be included if development time allows:

1. Sound pack browser with search/filter.
2. Import custom sound packs.
3. Export custom pack as `.thockpack`.
4. Per-app sound pack profiles.
5. Quiet hours schedule.
6. Typing streak focus timer.
7. Menu bar waveform animation.
8. Optional dock icon visibility setting.
9. Bluetooth latency warning.
10. In-app sound latency test.

### 6.3 MVP Nice-to-Have Features

These can wait until version 1.1 or later:

1. Sound pack marketplace.
2. iCloud sync.
3. Community sound packs.
4. Spatial audio positioning controls.
5. Advanced equalizer.
6. Recording assistant for creating packs.
7. AI-generated sound packs.
8. Team license management.
9. Streamer mode.
10. Keyboard layout visualizer.

---

## 7. Recommended Product Name and Branding

### 7.1 Recommended Name

Thock Studio

Reason:

- “Thock” is familiar to mechanical keyboard fans.
- “Studio” makes it feel premium, audio-focused, and customizable.
- The name is short, memorable, and productizable.
- It sounds better than generic names like Keyboard Sound App.

### 7.2 Alternative Names

1. KeyTone Pro
2. MechaKeys
3. ClackLab
4. SwitchSound
5. KeyClack Studio
6. Typing Studio
7. ThockKeys
8. SoundKeys
9. ClickForge
10. ClackDesk

### 7.3 Brand Personality

The brand should feel:

- Premium.
- Minimal.
- Mac-native.
- Calm.
- Satisfying.
- Trustworthy.
- Desk setup friendly.
- Useful, not gimmicky.

### 7.4 Visual Style

The UI should feel like a modern macOS utility:

- Rounded panels.
- Soft shadows.
- Frosted glass accents where appropriate.
- Clean typography.
- Large sound pack cards.
- Smooth but subtle animations.
- Dark mode first, but perfect in light mode.
- No childish graphics.
- No clutter.

### 7.5 Logo Concept

Icon concept:

A rounded square app icon with a stylized keyboard keycap in the center. The keycap has a small sound wave line coming out from the top-right corner. The keycap should look premium, not cartoonish.

Possible icon colors:

- Deep charcoal background.
- Warm cream keycap.
- Small orange/gold sound wave.
- Optional blue accent for Pro.

The logo must be recognizable at 16 px in the menu bar and at 1024 px in the App Store.

---

## 8. Platform Requirements

### 8.1 Supported Platform

- macOS 13 Ventura and later.
- Apple Silicon native support.
- Intel Mac support if feasible.
- Universal binary recommended.

### 8.2 Recommended Technology Stack

Use a native Mac stack for maximum performance and trust:

- Language: Swift.
- UI: SwiftUI.
- Mac-specific behavior: AppKit where needed.
- Audio: AVAudioEngine and/or AVAudioPlayerNode.
- Event listening: CGEventTap with listen-only behavior.
- App lifecycle/menu bar: NSStatusItem.
- Frontmost app detection: NSWorkspace.
- Launch at login: SMAppService.
- Persistence: UserDefaults for simple settings; Application Support folder for sound packs.
- Purchases: StoreKit 2 for Mac App Store version.
- Direct license option: separate licensing module for direct website version if needed.
- Crash reporting: privacy-safe crash reports only, opt-in if external service is used.
- Analytics: local-only in MVP; optional opt-in analytics later.

### 8.3 Distribution Options

Recommended distribution:

1. Mac App Store version for trust and discoverability.
2. Direct notarized download from website for faster updates and bundles.

The app should be designed to pass review by being transparent about permissions, privacy, and utility value. It must not hide key monitoring behavior. It must clearly explain that it listens for keyboard events only to play local sound feedback.

---

## 9. macOS Permission Strategy

### 9.1 Required Permission

The app needs Input Monitoring permission so it can detect keyboard events globally while the user types in other apps.

### 9.2 Permission UX Principle

The permission screen must not scare users. It should be honest, simple, and specific.

Bad copy:

> We need to monitor your keyboard.

Good copy:

> Thock Studio needs Input Monitoring so it can detect key presses and play a sound. It never stores what you type, never records words, and never sends keystrokes anywhere.

### 9.3 Permission Flow

First launch flow:

1. Show welcome screen.
2. Show one-sentence product promise.
3. Show privacy guarantee.
4. Show “Enable Input Monitoring” button.
5. Trigger permission request where supported.
6. Open System Settings > Privacy & Security > Input Monitoring if needed.
7. Show exact instruction:
   - Turn on Thock Studio.
   - Restart the app if macOS asks.
8. App automatically rechecks permission when returning to foreground.
9. User reaches test typing screen.
10. User types in test area and hears first sound.

### 9.4 Permission State UI

States:

1. `notDetermined`
   - Show explanation and enable button.
2. `denied`
   - Show “Open System Settings” and troubleshooting.
3. `approved`
   - Show checkmark and continue.
4. `unknownOrBlocked`
   - Show “macOS is currently blocking keyboard events, possibly due to Secure Input or another system state.”

### 9.5 Privacy Guarantees

The app must guarantee:

1. No typed text is stored.
2. No typed text is sent to servers.
3. No screenshots are captured.
4. No clipboard content is read.
5. No password fields are bypassed.
6. No key remapping is performed.
7. Keyboard events are used only to select and play local audio samples.
8. Stats are aggregated counters only.
9. User can disable stats entirely.
10. Core app works without internet.

### 9.6 Implementation Notes

The event listener should use listen-only behavior. It should not modify, block, delay, or inject keyboard events.

The app should listen for:

- Key down.
- Key up.
- Modifier flag changes.

The app should ignore:

- Events generated by the app itself if applicable.
- Repeated key events depending on user setting.
- Events during app-level mute conditions.
- Events while global mute is enabled.

The app should not attempt to capture actual typed strings. Keycodes are sufficient for selecting sound categories.

---

## 10. Core User Flow

### 10.1 First-Time User Flow

1. User downloads and opens Thock Studio.
2. App appears in menu bar and opens onboarding window.
3. Welcome screen says:
   - “Make your Mac keyboard sound premium.”
   - “Choose a switch sound. Start typing. That’s it.”
4. User clicks “Get Started.”
5. App shows privacy explanation.
6. User enables Input Monitoring.
7. App verifies permission.
8. User chooses first sound pack from three recommended options:
   - Deep Thock.
   - Clicky Blue.
   - Soft Writer.
9. User reaches test pad:
   - “Type here to test your new keyboard sound.”
10. User hears sound and sees a small satisfying visual response.
11. User clicks “Keep This Sound.”
12. App offers optional launch at login.
13. App collapses into menu bar.

### 10.2 Daily Usage Flow

1. User starts Mac.
2. App launches silently in menu bar.
3. User types normally.
4. Sounds play instantly.
5. User clicks menu bar icon to:
   - Toggle on/off.
   - Change sound pack.
   - Adjust volume.
   - Start focus mode.
   - Mute for 30 minutes.
6. User can open full settings only when needed.

### 10.3 Upgrade Flow

1. Free user selects a Pro sound pack.
2. Locked pack opens preview mode.
3. User can type 10 sample keystrokes to hear it.
4. After preview limit, CTA appears:
   - “Unlock all premium sound packs forever.”
5. User purchases one-time Pro unlock.
6. All current sound packs and future base packs unlock.

---

## 11. Feature Specification

## 11.1 Real-Time Keyboard Sound Engine

### Description

The core feature plays a selected sound sample whenever the user presses or releases a key.

### Requirements

1. Must work globally across apps.
2. Must not change actual keyboard input.
3. Must support press sounds.
4. Must support release sounds.
5. Must support key repeat control.
6. Must support modifier keys.
7. Must support different sound categories.
8. Must support sample randomization.
9. Must support pitch randomization.
10. Must support per-app mute.
11. Must support global mute.
12. Must support temporary mute.

### Key Categories

The app should map physical keycodes to categories:

- `alpha`
- `number`
- `space`
- `enter`
- `backspace`
- `tab`
- `escape`
- `arrow`
- `modifier`
- `function`
- `punctuation`
- `numpad`
- `unknown`

### Special Keys

Special key sound behavior:

- Spacebar should sound deeper and wider.
- Enter should sound slightly heavier.
- Backspace should sound sharper.
- Escape should sound short and crisp.
- Modifiers should be very soft or optional.
- Arrow keys should be lighter.
- Function keys should be optional.
- Caps Lock should have a distinct toggle sound.
- Key release sounds should be quieter than key press sounds.

### Key Repeat

Setting options:

- Play every repeat.
- Play first press only.
- Play repeat at reduced volume.
- Disable repeat sounds.

Default:

- Play first press and then play reduced-volume repeats at maximum 10 sounds per second per held key.

---

## 11.2 Sound Packs

### Description

Sound packs are collections of audio samples mapped to key categories. They should feel like different keyboards, switches, rooms, and moods.

### Built-In MVP Sound Packs

The first release should include at least 8 sound packs:

1. Deep Thock
   - Premium linear switch sound.
   - Deep, warm, satisfying.
   - Best for developers.

2. Clicky Blue
   - Bright clicky switch sound.
   - Loud, energetic.
   - Best for mechanical keyboard fans.

3. Soft Brown
   - Tactile but balanced.
   - Comfortable for daily work.
   - Best default sound.

4. Creamy Linear
   - Smooth, lubed switch style.
   - Soft top-end, rich body.
   - Best for long sessions.

5. Topre Cloud
   - Soft rubber dome electro-capacitive feel.
   - Rounded and pleasant.
   - Best for writers.

6. Vintage Typewriter
   - Classic mechanical typewriter feel.
   - Includes carriage-inspired return sound.
   - Best for writing mode.

7. Laptop Low Profile
   - Clean modern Mac-like sound but enhanced.
   - Subtle and office-friendly.
   - Best for work.

8. Cozy Desk ASMR
   - Gentle keystrokes with optional room ambience.
   - Soft, relaxing.
   - Best for focus.

### Premium Sound Packs for Pro

Future or Pro-only packs:

1. Buckling Spring
2. Aluminum Case Thock
3. Polycarbonate Pop
4. Marble Desk Clack
5. Gaming Linear
6. Silent Tactile
7. Rainy Night Writer
8. Cafe Keyboard
9. Terminal Retro
10. Creator Stream Pack
11. Heavy Spacebar Pack
12. Office Quiet Pack
13. Neon Cyber Keys
14. Minimal Zen Keys
15. Keyboard Hobbyist Pack

### Sound Pack Card Fields

Each sound pack card should display:

- Name.
- Category: Linear, Tactile, Clicky, Typewriter, ASMR, Office.
- Loudness rating: Soft / Medium / Loud.
- Tone rating: Deep / Balanced / Bright.
- Best for: Coding / Writing / Work / ASMR / Gaming.
- Lock badge if Pro.
- Favorite button.
- Preview button.
- “Use” button.

---

## 11.3 Sound Pack Preview

### Description

Users must be able to test sounds before selecting or buying.

### Preview Modes

1. Click Preview
   - Plays a short typing demo sequence.

2. Type Preview
   - Opens a mini input area where user types and hears the selected pack.

3. Comparison Preview
   - User can switch between two packs while typing.

4. Locked Pack Preview
   - Free users can test locked packs for a short limit.

### Requirements

- Preview must not require changing the active global pack.
- Preview should be instant.
- Preview should stop when user closes the panel.
- Preview should respect master volume.
- Preview should not trigger duplicate sounds from global listener inside test field.

---

## 11.4 App-Specific Profiles

### Description

Users can set different behavior depending on the active app.

### Examples

- Xcode: Deep Thock, 70% volume.
- VS Code: Creamy Linear, 65% volume.
- Terminal: Terminal Retro, 75% volume.
- Zoom: Muted.
- Microsoft Teams: Muted.
- Slack: Laptop Low Profile, 25% volume.
- Safari: Soft Brown, 40% volume.
- Games: Disabled.

### Profile Rule Fields

Each app rule includes:

- App bundle identifier.
- App display name.
- Enabled/disabled.
- Sound pack override.
- Volume override.
- Pitch override.
- Key repeat behavior.
- Press/release behavior.
- Mute status.
- Focus stats inclusion.
- Notes.

### Default Profile Rules

On first install, create suggested mute rules for:

- Zoom.
- Microsoft Teams.
- FaceTime.
- Google Meet in browser cannot be detected reliably by app alone, so browser-level rules should be manual.
- Discord.
- QuickTime Player recording mode if detectable by active app only.

### UX

The app profile screen should show a list:

- App icon.
- App name.
- Current behavior.
- Toggle.
- Edit button.

There should be a “Add Current App” button that uses the currently active foreground app.

---

## 11.5 Meeting Mode

### Description

Meeting Mode temporarily mutes keyboard sounds.

### Controls

Menu bar quick actions:

- Mute for 15 minutes.
- Mute for 30 minutes.
- Mute for 1 hour.
- Mute until tomorrow.
- Mute while this app is active.
- Resume now.

### Behavior

When Meeting Mode is active:

- Menu bar icon changes state.
- No keyboard sounds play.
- Optional notification appears when sounds resume.
- User can resume instantly.

### Smart Meeting Detection

MVP should use app-based rules, not microphone monitoring.

Default muted apps:

- Zoom.
- Microsoft Teams.
- FaceTime.
- Discord.
- Webex.
- Google Meet can be handled by browser rule or manual mute because page-level detection is not reliable without browser integration.

Do not request microphone permission just to detect meetings.

---

## 11.6 Focus Mode

### Description

Focus Mode turns the keyboard sound app into a productivity ritual.

### Features

1. Start a focus session:
   - 15 minutes.
   - 25 minutes.
   - 45 minutes.
   - 60 minutes.
   - Custom.

2. Choose session sound:
   - Keep current pack.
   - Use soft focus pack.
   - Use writing pack.

3. Optional ambient layer:
   - Rain.
   - Cafe.
   - Brown noise.
   - None.

4. Session stats:
   - Keystrokes count.
   - Active typing minutes.
   - Longest typing streak.
   - Estimated rhythm consistency.
   - No words captured.

5. End screen:
   - “You typed 2,840 keystrokes in 25 minutes.”
   - “Longest streak: 7 minutes.”
   - “Great session.”

### Privacy

Focus Mode must not count words by reading text. If word estimate is ever added, it must be clearly labeled as estimated from keystroke count and disabled by default.

---

## 11.7 Sound Mixer

### Description

The sound mixer lets users shape the sound without being overwhelmed.

### Basic Controls

- Master volume.
- Key press volume.
- Key release volume.
- Spacebar volume.
- Modifier volume.
- Pitch variation.
- Sample variation.
- Bass boost.
- Brightness.
- Room amount.
- Compression/limiting toggle.

### Recommended Default Values

- Master volume: 55%.
- Press volume: 100%.
- Release volume: 35%.
- Spacebar volume: 115%.
- Modifier volume: 30%.
- Pitch variation: 2%.
- Sample variation: enabled.
- Bass boost: 0.
- Brightness: 0.
- Room amount: 5%.
- Limiter: enabled.

### Advanced Controls

Advanced controls should be hidden under “Advanced”:

- Per-category volume.
- Per-category pitch.
- Randomization seed behavior.
- Maximum sounds per second.
- Release delay offset.
- Key repeat throttling.
- Output device selection if available.
- Audio engine buffer preference.

---

## 11.8 Custom Sound Pack Import

### Description

Power users can import custom sound packs.

### Supported Import Formats

MVP:

- `.thockpack` bundle.
- `.zip` containing a valid manifest and audio files.
- Folder import.

Supported audio:

- WAV.
- AIFF.
- CAF.
- M4A if conversion pipeline is implemented.

Recommended internal format:

- Uncompressed PCM WAV/CAF for low-latency playback.

### Import Requirements

1. Validate manifest.
2. Validate audio file existence.
3. Validate sample duration.
4. Validate loudness range.
5. Normalize preview if needed.
6. Copy files into app support directory.
7. Show import summary.
8. Allow delete.
9. Allow export.
10. Handle duplicate pack names.

### Custom Pack MVP Limitation

The app does not need to include a full sample editor in MVP. It only needs import, preview, and use.

---

## 11.9 Sound Pack Studio

### Description

Sound Pack Studio is an advanced feature for creating a custom keyboard sound profile inside the app.

### MVP Scope

For version 1.0, include a basic editor:

- Create new pack.
- Choose base pack.
- Adjust volume/tone.
- Replace samples by key category.
- Save as custom pack.
- Export as `.thockpack`.

### Later Scope

Future version:

- Record key samples using microphone.
- Auto-trim silence.
- Auto-normalize.
- Detect press/release samples.
- Generate missing key category variants from one base sample.
- Add keyboard case resonance simulation.

---

## 11.10 Usage Stats

### Description

Usage stats make the app sticky while staying privacy-safe.

### Metrics Allowed

- Total keystrokes today.
- Total typing sessions.
- Active typing minutes.
- Current streak.
- Best focus session.
- Favorite sound pack.
- Apps where sounds were active.
- Number of muted sessions.

### Metrics Not Allowed

- Typed words.
- Typed characters.
- Passwords.
- Text snippets.
- URLs typed.
- Chat content.
- Document content.
- Clipboard contents.

### UX

Stats should be optional and can be disabled.

Stats screen sections:

1. Today
2. This Week
3. Focus Sessions
4. Favorite Sounds
5. Privacy note

Example copy:

> Stats are based on anonymous local counters. Thock Studio never stores what you type.

---

## 11.11 Global Hotkeys

### Description

Users should control the app quickly.

### Default Hotkeys

Do not enable global hotkeys by default unless necessary, to avoid permission confusion.

Optional configurable hotkeys:

- Toggle sounds on/off.
- Mute for 30 minutes.
- Cycle sound pack.
- Open menu panel.
- Start focus session.

### Requirements

- User must explicitly enable hotkeys.
- Hotkeys must be customizable.
- Hotkeys must not conflict silently.
- UI should warn if a shortcut is already used.

---

## 11.12 Quiet Hours

### Description

Quiet Hours automatically mutes the app during a schedule.

### Fields

- Enabled/disabled.
- Start time.
- End time.
- Repeat days.
- Behavior:
  - Mute completely.
  - Lower volume.
  - Use quiet sound pack.
- Notification on resume.

### Defaults

Do not enable by default. Suggest setup during onboarding only after the user has experienced the product.

---

## 11.13 Output Device Awareness

### Description

Audio output device can affect latency. Bluetooth speakers/headphones may introduce delay.

### Requirements

1. Detect current output device name where available.
2. Show a gentle warning when Bluetooth output is active:
   - “Bluetooth audio may add delay. For the tightest typing feel, use built-in speakers or wired headphones.”
3. Allow user to hide warning.
4. Do not block usage.

### Future Feature

Allow per-output-device profiles:

- Built-in speakers: 40% volume.
- AirPods: 35% volume.
- External monitor speakers: muted.
- Wired headphones: 55% volume.

---

## 12. UI/UX Specification

## 12.1 UX Principles

The app must be:

1. Instant.
2. Calm.
3. Obvious.
4. Premium.
5. Trustworthy.
6. Minimal by default.
7. Powerful when expanded.

Every screen should answer one user question:

- Is the app on?
- What sound am I using?
- How loud is it?
- Is my privacy safe?
- How do I mute it fast?
- How do I make it sound better?

Avoid clutter. The product should feel like a premium Mac utility, not a complicated audio workstation.

---

## 12.2 App Structure

The app has two main surfaces:

1. Menu Bar Popover
   - Daily quick controls.

2. Full Settings Window
   - Detailed configuration.

The app should support hiding the dock icon.

Default behavior:

- App lives in menu bar.
- Dock icon hidden after onboarding unless user chooses otherwise.
- Full window can be opened from menu bar.

---

## 12.3 Menu Bar Popover

### Purpose

Fast control without opening full settings.

### Layout

Top area:

- App icon.
- Current sound pack name.
- Status: On / Muted / Permission Needed / Meeting Mode.
- Master toggle.

Main controls:

- Volume slider.
- Sound pack quick selector.
- Preview button.
- Mute buttons.

Quick action buttons:

- Mute 15m.
- Mute 30m.
- Focus.
- Settings.

Footer:

- Privacy status indicator.
- Pro badge if applicable.
- Quit.

### Visual Details

Popover width: 360 px.  
Corner radius: 16 px.  
Padding: 16 px.  
Sound pack cards: horizontal scroll or compact dropdown.  
Animation: subtle pulse when key sounds are active, but not distracting.

### Menu Bar Icon States

- Normal: keycap icon.
- Active typing: tiny sound wave animates subtly.
- Muted: keycap with slash.
- Permission needed: warning dot.
- Focus mode: keycap with small timer dot.

---

## 12.4 Main Settings Window

### Window Size

Default size: 920 x 640 px.  
Minimum size: 760 x 520 px.

### Sidebar Sections

1. Home
2. Sound Packs
3. Mixer
4. App Profiles
5. Focus
6. Stats
7. Privacy
8. Settings
9. Pro

### Home Screen

Purpose: The control center.

Content:

- Current sound pack card.
- Big on/off toggle.
- Volume slider.
- Typing test field.
- Quick mute options.
- Current permission status.
- Recommended sounds.
- Focus session button.

Hero copy:

> Your Mac keyboard, upgraded.

Subcopy:

> Choose a premium typing sound and make every keystroke feel satisfying.

### Sound Packs Screen

Purpose: Browse and choose sounds.

Features:

- Search.
- Category filters.
- Loudness filter.
- Tone filter.
- Favorites.
- Free/Pro filter.
- Import button.
- Preview mode.

Card design:

- Large pack name.
- Small waveform or keycap image.
- Tags.
- Preview button.
- Use button.
- Pro lock if needed.

### Mixer Screen

Purpose: Fine-tune selected sound.

Sections:

1. Volume
2. Key Categories
3. Tone
4. Randomization
5. Advanced

Use sliders with live preview. Every slider should have a reset button.

### App Profiles Screen

Purpose: Control behavior per app.

Features:

- Add current app.
- Add from installed apps list.
- Search apps.
- Toggle per app.
- Mute app.
- Override sound pack.
- Override volume.
- Delete rule.

### Focus Screen

Purpose: Start and review focused typing sessions.

Features:

- Timer presets.
- Ambient layer choice.
- Sound pack choice.
- Start button.
- Current session view.
- Past sessions list.

### Stats Screen

Purpose: Fun, privacy-safe insights.

Show:

- Today’s keystrokes.
- Active typing minutes.
- Focus sessions.
- Most used sound pack.
- Streak calendar.

Always include privacy note.

### Privacy Screen

Purpose: Build trust.

Sections:

1. What the app needs.
2. What the app does not collect.
3. Local-only design.
4. Permissions status.
5. Data reset button.
6. Export settings button.
7. Delete all local data button.

Strong copy:

> Thock Studio does not know what you typed. It only reacts to key press events to play sounds.

### Settings Screen

Sections:

- General.
- Launch at login.
- Dock icon visibility.
- Menu bar icon animation.
- Notifications.
- Quiet hours.
- Sound output.
- Updates.
- Troubleshooting.
- Reset.

### Pro Screen

Purpose: Convert free users.

Content:

- Unlock all sound packs.
- Unlock custom sound import.
- Unlock per-app profiles.
- Unlock focus mode history.
- Lifetime purchase.
- Restore purchases.
- Trial status if applicable.

---

## 13. Onboarding Specification

## 13.1 Screen 1: Welcome

Title:

> Make your Mac keyboard sound premium.

Subtitle:

> Add satisfying mechanical, typewriter, and ASMR typing sounds to every keystroke.

Primary button:

> Get Started

Secondary link:

> How privacy works

Visual:

Animated keycap with soft sound wave.

---

## 13.2 Screen 2: Privacy Promise

Title:

> Private by design.

Bullets:

- We never store what you type.
- We never send keystrokes to a server.
- We only use key press events to play local sounds.
- You can turn everything off anytime.

Primary button:

> Continue

---

## 13.3 Screen 3: Enable Input Monitoring

Title:

> One macOS permission is needed.

Subtitle:

> macOS requires permission before any app can react to keyboard events in other apps.

Steps:

1. Click Enable Permission.
2. Open Input Monitoring.
3. Turn on Thock Studio.
4. Return here.

Primary button:

> Enable Permission

Secondary button:

> Open System Settings

Troubleshooting link:

> I do not see Thock Studio in the list

---

## 13.4 Screen 4: Choose First Sound

Title:

> Choose your first keyboard sound.

Recommended cards:

1. Soft Brown — Best starter.
2. Deep Thock — Best for coding.
3. Cozy Desk — Best for focus.

Each card:

- Preview.
- Use this sound.

---

## 13.5 Screen 5: Test Typing

Title:

> Try it now.

Input placeholder:

> Type here and listen.

Actions:

- Change sound.
- Adjust volume.
- Continue.

---

## 13.6 Screen 6: Finish

Title:

> You’re ready.

Toggles:

- Launch at login.
- Hide dock icon.
- Show menu bar animation.

Button:

> Start Typing

---

## 14. Sound Design Specification

## 14.1 Recording Requirements

Each sound pack should include multiple samples per key category.

Recommended minimum per pack:

- Alpha: 12 press samples, 8 release samples.
- Number: 8 press samples, 6 release samples.
- Space: 6 press samples, 4 release samples.
- Enter: 6 press samples, 4 release samples.
- Backspace: 6 press samples, 4 release samples.
- Tab: 4 press samples, 4 release samples.
- Escape: 4 press samples, 4 release samples.
- Arrow: 6 press samples, 4 release samples.
- Modifier: 4 press samples, 4 release samples.
- Function: 4 press samples, 4 release samples.

### Recording Format

Recommended source format:

- 24-bit WAV.
- 48 kHz sample rate.
- Mono or stereo depending on pack.
- Clean noise floor.
- No clipping.
- Short sample length.

### Sample Length

Recommended duration:

- Normal key press: 40–140 ms.
- Key release: 20–90 ms.
- Spacebar: 80–220 ms.
- Enter: 80–200 ms.
- Typewriter return: up to 700 ms, but only for typewriter pack and only on Enter.

### Loudness

Sound packs should be normalized to avoid painful volume jumps.

Recommended:

- Peak below -3 dBFS.
- Use consistent perceived loudness.
- Apply gentle limiting during playback.

---

## 14.2 Audio Playback Behavior

For each key event:

1. Determine active app.
2. Check mute rules.
3. Check key category.
4. Select sample pool.
5. Select random sample avoiding immediate repetition.
6. Apply pitch variation.
7. Apply volume variation.
8. Apply category volume.
9. Apply master volume.
10. Schedule playback immediately.
11. Apply limiter if needed.

### Randomization

Randomization prevents machine-gun repetition.

Default:

- Sample variation: enabled.
- Pitch variation: ±2%.
- Volume variation: ±4%.
- Immediate repeat avoidance: enabled.

### Dynamic Typing Response

Optional but recommended:

- Faster typing slightly reduces release volume.
- Heavy keys like space and enter remain distinct.
- Repeated held key uses reduced volume.
- If typing speed is very high, throttle to avoid messy audio.

### Audio Engine Resilience

The audio engine must:

- Start on app launch.
- Preload active pack.
- Keep next likely samples ready.
- Restart if output device changes.
- Restart if engine fails.
- Avoid blocking the main thread.
- Avoid disk reads during keystroke playback.

---

## 15. Sound Pack File Format

## 15.1 `.thockpack` Structure

A `.thockpack` is a zipped folder with this structure:

```text
DeepThock.thockpack
├── manifest.json
├── artwork.png
├── preview.wav
└── samples
    ├── alpha
    │   ├── press_01.wav
    │   ├── press_02.wav
    │   └── release_01.wav
    ├── space
    │   ├── press_01.wav
    │   └── release_01.wav
    ├── enter
    ├── backspace
    ├── tab
    ├── escape
    ├── arrow
    ├── modifier
    └── function
```

## 15.2 Manifest Example

```json
{
  "schemaVersion": 1,
  "packId": "com.thockstudio.pack.deepthock",
  "name": "Deep Thock",
  "version": "1.0.0",
  "author": "Thock Studio",
  "category": "linear",
  "tone": "deep",
  "loudness": "medium",
  "description": "Warm, deep, premium linear mechanical keyboard sound.",
  "isPremium": false,
  "supportsPress": true,
  "supportsRelease": true,
  "recommendedVolume": 0.55,
  "pitchVariationDefault": 0.02,
  "sampleVariationDefault": true,
  "artwork": "artwork.png",
  "preview": "preview.wav",
  "samples": {
    "alpha": {
      "press": [
        "samples/alpha/press_01.wav",
        "samples/alpha/press_02.wav"
      ],
      "release": [
        "samples/alpha/release_01.wav"
      ]
    },
    "space": {
      "press": [
        "samples/space/press_01.wav"
      ],
      "release": [
        "samples/space/release_01.wav"
      ]
    }
  }
}
```

## 15.3 Validation Rules

A pack is valid if:

1. Manifest exists.
2. Required fields exist.
3. Pack ID is unique.
4. Version is valid semantic version format.
5. Audio files exist.
6. Audio files are readable.
7. At least alpha press samples exist.
8. Sample duration is acceptable.
9. No file path escapes the pack folder.
10. Total pack size is below configured limit.

Recommended pack size limit:

- Free import: 100 MB per pack.
- Pro import: 500 MB per pack.

---

## 16. Technical Architecture

## 16.1 High-Level Architecture

The app should be modular:

1. `AppShell`
   - SwiftUI app lifecycle.
   - Menu bar item.
   - Windows.
   - Settings navigation.

2. `PermissionService`
   - Checks Input Monitoring permission.
   - Requests permission.
   - Opens System Settings.
   - Tracks permission state.

3. `KeyboardEventService`
   - Creates listen-only event tap.
   - Receives key events.
   - Converts raw events into internal `KeyEvent`.
   - Handles tap disabled events.
   - Restarts tap if needed.

4. `AudioEngineService`
   - Manages AVAudioEngine.
   - Manages player nodes.
   - Preloads sound buffers.
   - Schedules playback.
   - Handles output changes.

5. `SoundPackManager`
   - Loads built-in packs.
   - Imports custom packs.
   - Validates manifests.
   - Provides sample pools.

6. `ProfileService`
   - Tracks frontmost app.
   - Applies app-specific rules.
   - Applies quiet hours.
   - Applies meeting mode.

7. `SettingsStore`
   - Saves user preferences.
   - Supports migration.
   - Supports reset.

8. `StatsService`
   - Tracks privacy-safe counters.
   - Stores local stats.
   - Can be disabled.

9. `PurchaseService`
   - Handles StoreKit purchases.
   - Handles restore.
   - Exposes Pro entitlement.

10. `NotificationService`
   - Handles mute expiration notifications.
   - Handles permission reminders.
   - Handles focus completion.

---

## 16.2 Event Monitoring Design

### Event Types

Monitor:

- Key down.
- Key up.
- Flags changed.

### Event Tap Behavior

Use listen-only event monitoring. The app must not modify events.

Internal event object:

```swift
struct KeyEvent {
    let keyCode: Int
    let category: KeyCategory
    let phase: KeyPhase
    let isRepeat: Bool
    let timestamp: TimeInterval
    let flags: ModifierFlags
    let sourceAppBundleId: String?
}
```

### Key Phase

```swift
enum KeyPhase {
    case down
    case up
    case modifierChanged
}
```

### Key Category

```swift
enum KeyCategory {
    case alpha
    case number
    case punctuation
    case space
    case enter
    case backspace
    case tab
    case escape
    case arrow
    case modifier
    case function
    case numpad
    case unknown
}
```

### Event Pipeline

```text
CGEventTap
   ↓
KeyboardEventService
   ↓
KeyClassifier
   ↓
ProfileService
   ↓
SoundPlaybackRequest
   ↓
AudioEngineService
```

### Tap Failure Handling

If event tap is disabled:

1. Log local diagnostic.
2. Attempt safe restart.
3. If restart fails, update UI status.
4. Do not spam notifications.
5. Show troubleshooting button.

Possible UI copy:

> Keyboard sounds are paused because macOS stopped the event listener. Click to restart.

---

## 16.3 Audio Engine Design

### Requirements

1. Preload active sound pack into memory.
2. Do not load from disk during key press.
3. Use multiple player nodes or a sound pool.
4. Support overlapping sounds.
5. Avoid cutting off previous samples during fast typing.
6. Support volume and pitch changes.
7. Apply a limiter to prevent harsh clipping.
8. Handle output device changes.

### Playback Request

```swift
struct SoundPlaybackRequest {
    let packId: String
    let keyCategory: KeyCategory
    let phase: KeyPhase
    let volume: Float
    let pitchSemitones: Float
    let timestamp: TimeInterval
    let appProfileId: String?
}
```

### Buffer Strategy

For each active pack:

- Load all required samples into `AVAudioPCMBuffer`.
- Keep sample pools by category and phase.
- Maintain a small pool of player nodes.
- Reuse nodes after playback completion.
- Use a fallback sample if category-specific sample is missing.

### Latency Strategy

1. Initialize audio engine during app launch.
2. Warm up engine with silent buffer.
3. Preload selected pack.
4. Keep active audio session ready.
5. Avoid main-thread disk IO.
6. Avoid heavy processing per key event.
7. Keep event processing simple.
8. Use low-cost randomization.

---

## 16.4 Active App Detection

Use active application detection to apply profiles.

Data needed:

- Bundle identifier.
- App name.
- App icon.
- Process ID if useful.

Behavior:

- Update active app on workspace activation notifications.
- Cache profile decision.
- Do not inspect app contents.
- Do not inspect document names.
- Do not inspect browser URLs.

---

## 16.5 Persistence

### Settings Storage

Use UserDefaults for simple preferences:

- Current pack ID.
- Master volume.
- Enabled/disabled.
- Launch at login.
- Dock icon visibility.
- Menu bar animation.
- Quiet hours.
- Last onboarding version.
- Stats enabled.
- Pro entitlement cache.

### File Storage

Use Application Support for:

- Imported sound packs.
- Custom pack artwork.
- Local stats database if needed.
- Logs if user enables diagnostics.

Recommended paths:

Non-sandboxed direct build:

```text
~/Library/Application Support/Thock Studio/
```

Sandboxed Mac App Store build:

```text
~/Library/Containers/<bundle-id>/Data/Library/Application Support/Thock Studio/
```

### Data Reset

The app must include:

- Reset settings.
- Delete imported packs.
- Delete stats.
- Delete all local data.

---

## 16.6 StoreKit / Licensing

### Free Tier

Free tier includes:

- 3 sound packs.
- Basic volume control.
- Menu bar toggle.
- Permission onboarding.
- Launch at login.
- Basic privacy screen.

### Pro Tier

Pro unlock includes:

- All built-in sound packs.
- Custom sound pack import.
- App-specific profiles.
- Advanced mixer.
- Focus mode history.
- Quiet hours.
- Premium updates.
- Future base sound packs.

### Recommended Pricing

Best initial pricing:

- Free download.
- Pro lifetime unlock: $4.99 to $9.99.
- Launch discount: $4.99.
- Normal price: $7.99 or $9.99.
- No subscription for version 1.

Reason:

This product is a delightful utility. A simple lifetime price is easier to sell than a subscription.

### Future Monetization

After product-market fit:

- Premium sound pack bundles.
- Creator sound packs.
- Desk setup bundle.
- Team pack for productivity-focused companies.
- Direct website bundle.

Avoid aggressive upsells. The product should feel clean.

---

## 17. Data Models

## 17.1 UserSettings

```json
{
  "appEnabled": true,
  "currentPackId": "com.thockstudio.pack.softbrown",
  "masterVolume": 0.55,
  "pressVolume": 1.0,
  "releaseVolume": 0.35,
  "pitchVariation": 0.02,
  "sampleVariation": true,
  "launchAtLogin": true,
  "showDockIcon": false,
  "menuBarAnimation": true,
  "statsEnabled": true,
  "quietHoursEnabled": false,
  "onboardingCompletedVersion": "1.0"
}
```

## 17.2 AppProfile

```json
{
  "id": "profile-vscode",
  "bundleId": "com.microsoft.VSCode",
  "displayName": "Visual Studio Code",
  "enabled": true,
  "behavior": "custom",
  "soundPackId": "com.thockstudio.pack.deepthock",
  "volume": 0.65,
  "mute": false,
  "repeatMode": "reduced",
  "includeInStats": true
}
```

## 17.3 MuteState

```json
{
  "isMuted": true,
  "reason": "meetingMode",
  "expiresAt": "2026-06-17T15:30:00+08:00",
  "resumeBehavior": "restorePrevious"
}
```

## 17.4 FocusSession

```json
{
  "id": "session-uuid",
  "startedAt": "2026-06-17T14:00:00+08:00",
  "endedAt": "2026-06-17T14:25:00+08:00",
  "durationMinutes": 25,
  "keystrokes": 2840,
  "activeTypingSeconds": 1180,
  "longestStreakSeconds": 420,
  "soundPackId": "com.thockstudio.pack.cozydesk"
}
```

## 17.5 LocalStatsDaily

```json
{
  "date": "2026-06-17",
  "totalKeystrokes": 9250,
  "activeTypingSeconds": 5420,
  "focusSessions": 3,
  "mostUsedPackId": "com.thockstudio.pack.deepthock"
}
```

---

## 18. Functional Requirements

## 18.1 Keyboard Sound Playback

- The app must play sound when the user presses supported keys.
- The app must support global typing across apps.
- The app must support key release sounds.
- The app must support modifier keys separately.
- The app must allow disabling modifier sounds.
- The app must allow disabling release sounds.
- The app must throttle repeat events.
- The app must not block keyboard input.
- The app must not modify events.
- The app must continue running from the menu bar.

## 18.2 Sound Pack Management

- The app must show built-in packs.
- The app must show locked premium packs.
- The app must preview packs.
- The app must switch packs instantly.
- The app must favorite packs.
- The app must import custom packs for Pro users.
- The app must validate imported packs.
- The app must delete imported packs.
- The app must export custom packs.

## 18.3 App Profiles

- The app must detect the active app.
- The app must allow adding current app as profile.
- The app must allow muting specific apps.
- The app must allow custom sound per app.
- The app must allow custom volume per app.
- The app must apply changes without restart.

## 18.4 Mute Controls

- The app must have master on/off.
- The app must support temporary mute.
- The app must support app-based mute.
- The app must support quiet hours.
- The app must show mute status clearly.
- The app must resume after temporary mute expires.

## 18.5 Focus Mode

- The app must start a timed session.
- The app must show countdown.
- The app must track local keystroke counters.
- The app must show end summary.
- The app must not store typed content.
- The app must allow disabling stats.

## 18.6 Permissions

- The app must detect whether Input Monitoring is approved.
- The app must guide the user to System Settings.
- The app must recheck permission on app activation.
- The app must show troubleshooting if permission is missing.
- The app must not crash if permission is denied.

---

## 19. Non-Functional Requirements

## 19.1 Performance

Targets:

- App launch to menu bar ready: under 2 seconds.
- First sound after app enabled: under 100 ms after engine warm-up.
- Playback scheduling after event received: target under 10 ms.
- Idle CPU: under 0.3%.
- Normal typing CPU: under 3%.
- Memory: under 150 MB with active pack loaded.
- No noticeable typing lag.

## 19.2 Reliability

The app must:

- Recover from audio engine failure.
- Recover from event tap disabled state.
- Handle permission changes.
- Handle output device changes.
- Handle sleep/wake.
- Handle fast user switching if possible.
- Handle app updates without losing settings.
- Handle corrupted imported sound pack gracefully.

## 19.3 Privacy

The app must:

- Work locally.
- Avoid account requirement.
- Avoid collecting typed content.
- Avoid sending keystroke data.
- Make privacy explanation visible.
- Allow deleting local stats.
- Avoid unnecessary permissions.

## 19.4 Accessibility

The app must:

- Support VoiceOver labels.
- Support keyboard navigation.
- Support reduce motion.
- Support high contrast.
- Support dynamic type where practical.
- Avoid relying only on color to show status.
- Provide textual status for mute/permission states.

## 19.5 Localization

MVP language:

- English.

Future languages:

- Spanish.
- French.
- German.
- Japanese.
- Korean.
- Chinese Simplified.
- Filipino.
- Portuguese.
- Indonesian.

The UI must be built with localization in mind from day one.

---

## 20. Edge Cases

The developer must handle these cases:

1. User denies Input Monitoring.
2. User grants permission but does not restart app.
3. App does not appear in Input Monitoring list.
4. Event tap is disabled by macOS.
5. Secure Input blocks keyboard events.
6. User types very fast.
7. User holds down one key.
8. User uses external keyboard.
9. User uses Bluetooth audio with noticeable delay.
10. User changes output device while typing.
11. User sleeps and wakes Mac.
12. User switches sound pack while typing.
13. User imports corrupted sound pack.
14. User deletes active sound pack.
15. User mutes for 30 minutes then quits app.
16. Temporary mute expiration occurs while app is closed.
17. User changes system volume.
18. User opens a meeting app.
19. User has multiple monitors.
20. User has Stage Manager / Spaces.
21. User uses non-US keyboard layout.
22. User uses IME input.
23. User uses a remote desktop app.
24. User uses screen recording or streaming apps.
25. User starts gaming and wants no sounds.
26. StoreKit purchase fails.
27. Purchase succeeds but entitlement cache is stale.
28. User reinstalls app.
29. App update changes sound pack schema.
30. User has reduced motion enabled.

---

## 21. Troubleshooting UX

The app should include a Troubleshooting screen.

### Common Issues

#### Issue: I do not hear any sound.

Checklist:

- Is Thock Studio enabled?
- Is master volume above 0?
- Is macOS output volume muted?
- Is a sound pack selected?
- Is the current app muted?
- Is Meeting Mode active?
- Is Quiet Hours active?
- Is Input Monitoring enabled?
- Is Secure Input active?
- Is output device connected?

#### Issue: Sound is delayed.

Show:

> Bluetooth audio can add delay. For the tightest response, use built-in speakers or wired headphones.

Actions:

- Switch output device.
- Lower audio buffer mode if supported.
- Restart audio engine.

#### Issue: Permission does not work.

Actions:

- Open Input Monitoring settings.
- Remove and re-add app if needed.
- Restart app.
- Restart Mac if macOS privacy state is stuck.
- Reset permission troubleshooting article.

#### Issue: Sounds are too loud.

Actions:

- Lower master volume.
- Use Office Quiet pack.
- Enable limiter.
- Lower spacebar volume.
- Disable release sounds.

---

## 22. App Store Listing Draft

### App Name

Thock Studio

### Subtitle

Mechanical keyboard sounds

### Short Description

Make every keystroke sound like a premium mechanical keyboard.

### Full App Description

Make your Mac keyboard feel more satisfying with realistic mechanical keyboard sounds, typewriter clicks, and cozy ASMR typing feedback.

Thock Studio is a lightweight menu bar app that plays high-quality keyboard sounds as you type. Choose from deep thocky switches, clicky mechanical keys, soft writing sounds, vintage typewriter tones, and relaxing focus presets. It is built for developers, writers, students, creators, and anyone who wants typing to feel better.

Features:

- Realistic mechanical keyboard sound packs.
- Low-latency typing feedback.
- Separate sounds for common key types.
- Press and release sound support.
- Volume and tone controls.
- Randomized pitch and sample variation.
- App-specific profiles.
- Quick mute and meeting mode.
- Focus sessions with privacy-safe stats.
- Custom sound pack import.
- Menu bar controls.
- Launch at login.
- Dark mode and light mode support.
- Private by design.

Privacy:

Thock Studio only uses keyboard events to play local sounds. It does not store what you type, does not record words, and does not send keystrokes anywhere.

Turn your quiet Mac keyboard into a premium typing experience.

### App Store Keywords

mechanical keyboard, keyboard sounds, typing sounds, typewriter, ASMR, productivity, focus, menu bar, sound effects, developer tools, writing

### Category

Primary: Utilities  
Secondary: Productivity or Lifestyle

### Age Rating

4+

### Screenshots

1. Hero screen: “Make your Mac keyboard sound premium.”
2. Sound pack browser with beautiful cards.
3. Mixer screen with tuning controls.
4. App profiles screen showing muted meeting apps.
5. Focus mode screen.
6. Privacy screen showing local-only promise.

---

## 23. Landing Page Specification

## 23.1 Landing Page Goal

Convert visitors into downloads within 30 seconds.

## 23.2 Page Sections

### Hero

Headline:

> Make your Mac keyboard sound premium.

Subheadline:

> Realistic mechanical keyboard, typewriter, and ASMR typing sounds for macOS.

CTA buttons:

- Download for Mac
- Listen to Sounds

Hero visual:

MacBook mockup with menu bar app open and animated key sounds.

### Sound Demo Section

Interactive sound cards:

- Deep Thock
- Clicky Blue
- Soft Brown
- Vintage Typewriter
- Cozy Desk

User can click each card to hear a short sample.

### Why Users Love It

Cards:

1. Makes typing satisfying.
2. Works across your Mac.
3. Built for focus.
4. Private by design.
5. No hardware needed.
6. Quick mute for meetings.

### Privacy Section

Headline:

> It reacts to keys. It does not record your typing.

Bullets:

- No typed text stored.
- No keystrokes uploaded.
- No account required.
- Local-first design.

### Pricing Section

Free:

- 3 sound packs.
- Basic controls.
- Menu bar app.

Pro:

- All sound packs.
- App profiles.
- Custom imports.
- Advanced mixer.
- Focus stats.
- Lifetime unlock.

### FAQ

Questions:

1. Does this record what I type?
2. Why does it need Input Monitoring?
3. Does it work with external keyboards?
4. Does it work with AirPods?
5. Can I mute it during meetings?
6. Can I import my own sounds?
7. Does it work offline?
8. Is it a subscription?

---

## 24. Marketing Strategy

## 24.1 Best Marketing Channels

1. TikTok short demos.
2. YouTube Shorts.
3. Desk setup videos.
4. Developer Twitter/X.
5. Reddit mechanical keyboard communities.
6. Mac app directories.
7. Product Hunt.
8. Indie hacker launch.
9. App Store search.
10. Blog SEO.

### 24.2 Viral Video Ideas

1. “I made my MacBook sound like a $400 keyboard.”
2. “This app makes typing weirdly satisfying.”
3. “Mechanical keyboard sounds without buying a keyboard.”
4. “Before: boring MacBook keyboard. After: deep thock.”
5. “Coding sounds better now.”
6. “The most satisfying Mac menu bar app.”
7. “I turned my keyboard into a typewriter.”
8. “ASMR typing setup for developers.”
9. “This made me want to write again.”
10. “Tiny Mac app, huge typing upgrade.”

### 24.3 Content Hooks

- “Your Mac keyboard is too quiet.”
- “You do not need a mechanical keyboard.”
- “Listen to this typing upgrade.”
- “This app makes work feel better.”
- “I installed this and typed for an hour.”

### 24.4 SEO Blog Topics

1. Best mechanical keyboard sound app for Mac.
2. How to make your Mac keyboard sound mechanical.
3. Best typing sound apps for focus.
4. Mechanical keyboard ASMR for Mac.
5. Typewriter sound app for macOS.
6. Why typing sounds can help focus.
7. Best Mac menu bar productivity apps.
8. How to use keyboard sounds without a mechanical keyboard.

---

## 25. Monetization Plan

## 25.1 Recommended Model

Freemium with lifetime Pro unlock.

### Free

Includes:

- 3 sound packs.
- Master volume.
- On/off toggle.
- Launch at login.
- Basic permission onboarding.
- Basic menu bar controls.

### Pro

Includes:

- All sound packs.
- Premium packs.
- App profiles.
- Custom imports.
- Advanced mixer.
- Focus mode history.
- Quiet hours.
- Per-output device settings when available.

### Price

Recommended:

- Launch: $4.99 lifetime.
- Normal: $7.99 or $9.99 lifetime.

### Why Not Subscription First

A keyboard sound app is a delightful utility. Many users will resist subscriptions for small utilities. A lifetime unlock creates impulse purchases and fewer negative reviews.

### Future Add-Ons

After the core app has traction:

- Creator sound packs: $1.99 to $4.99 each.
- Mega bundle: $14.99.
- Direct website bundle.
- Seasonal packs.

---

## 26. Product Roadmap

## 26.1 Version 1.0 — Premium MVP

- Menu bar app.
- Permission onboarding.
- 8 built-in sound packs.
- Real-time key sounds.
- Mixer basics.
- App mute list.
- Meeting mode.
- Launch at login.
- Free/Pro unlock.
- Privacy screen.
- Basic stats.
- Import `.thockpack`.

## 26.2 Version 1.1 — Power User Update

- Full app-specific profiles.
- Advanced mixer.
- Better custom pack editor.
- Output device awareness.
- More sound packs.
- Improved latency diagnostics.
- More keyboard layouts.

## 26.3 Version 1.2 — Focus Update

- Focus mode improvements.
- Ambient sound layers.
- Session history.
- Writing mode.
- Streaks.
- More ASMR packs.

## 26.4 Version 1.3 — Creator Update

- Sound Pack Studio.
- Record your own samples.
- Auto-trim and normalize.
- Export/share packs.
- Creator pack format documentation.

## 26.5 Version 2.0 — Marketplace / Community

- Optional account.
- Community sound packs.
- Ratings.
- Creator payouts.
- Cloud sync.
- Featured packs.

Only build version 2.0 if the product proves demand.

---

## 27. Engineering Build Plan

## Phase 1: Prototype

Goal: Prove low-latency key-to-sound loop.

Tasks:

1. Create native menu bar app.
2. Request/check Input Monitoring.
3. Implement listen-only keyboard event tap.
4. Classify key events.
5. Build simple AVAudioEngine playback.
6. Preload one sound pack.
7. Play sound on key down.
8. Add global on/off.
9. Add volume slider.
10. Test latency.

Exit criteria:

- Typing in any app plays sound.
- No keyboard input lag.
- No crash after 30 minutes of use.
- Sounds feel instant on built-in speakers.

## Phase 2: MVP UI

Tasks:

1. Build onboarding.
2. Build permission screen.
3. Build menu bar popover.
4. Build settings window.
5. Build sound pack browser.
6. Build mixer screen.
7. Build privacy screen.
8. Build troubleshooting screen.

Exit criteria:

- New user can set up app without developer help.
- UI explains permission clearly.
- User can switch packs and adjust volume.

## Phase 3: Sound Packs

Tasks:

1. Define pack manifest.
2. Add 8 built-in packs.
3. Add sample randomization.
4. Add pitch randomization.
5. Add press/release support.
6. Add category-specific samples.
7. Add preview mode.

Exit criteria:

- Sounds do not feel repetitive.
- Space/enter/backspace feel distinct.
- Preview mode works.

## Phase 4: Profiles and Mute

Tasks:

1. Detect active app.
2. Add app-specific mute.
3. Add app-specific pack.
4. Add meeting mode.
5. Add quiet hours.
6. Add temporary mute.

Exit criteria:

- Zoom/Teams can be muted.
- User can mute for 30 minutes.
- App resumes correctly.

## Phase 5: Pro and Release

Tasks:

1. Add StoreKit.
2. Add free/pro entitlements.
3. Add restore purchases.
4. Add App Store metadata.
5. Add crash-safe settings migration.
6. Add onboarding polish.
7. Add final QA.
8. Prepare website.

Exit criteria:

- Purchases work.
- Free tier works.
- Pro unlock works.
- App passes release checklist.

---

## 28. QA Test Plan

## 28.1 Permission Tests

Test cases:

1. Fresh install with no permission.
2. Grant permission and continue.
3. Deny permission.
4. Revoke permission while app is running.
5. Restart app after permission change.
6. App missing from Input Monitoring list.
7. Permission approved but event tap fails.
8. System Settings opened correctly.
9. App shows correct permission state.
10. App does not crash without permission.

## 28.2 Keyboard Tests

Test:

1. Letters.
2. Numbers.
3. Spacebar.
4. Enter.
5. Backspace.
6. Delete.
7. Tab.
8. Escape.
9. Arrows.
10. Function keys.
11. Modifiers.
12. Caps Lock.
13. Key repeat.
14. Fast typing.
15. External keyboard.
16. Non-US keyboard layout.
17. IME input.
18. Keyboard shortcuts.
19. Games.
20. Remote desktop.

## 28.3 Audio Tests

Test:

1. Built-in speakers.
2. Wired headphones.
3. Bluetooth headphones.
4. External monitor speakers.
5. Output device switch while app is running.
6. Mute system volume.
7. Low system volume.
8. Very fast typing.
9. Sound pack switching while typing.
10. Long session playback.

## 28.4 UI Tests

Test:

1. Dark mode.
2. Light mode.
3. Small screen.
4. Large screen.
5. VoiceOver labels.
6. Keyboard navigation.
7. Menu bar popover positioning.
8. Multiple monitors.
9. Reduce motion.
10. High contrast.

## 28.5 StoreKit Tests

Test:

1. Purchase success.
2. Purchase cancel.
3. Purchase failure.
4. Restore success.
5. Restore no purchase.
6. Offline launch after purchase.
7. Reinstall after purchase.
8. Family sharing if enabled.
9. Trial expiration if trial exists.
10. Locked pack preview.

---

## 29. Acceptance Criteria

The app is ready for v1 launch when all of these are true:

1. A new user can install, grant permission, choose a pack, and hear typing sounds in under 2 minutes.
2. The app works globally across common apps.
3. The sound feels instant on built-in Mac speakers.
4. No typed text is stored.
5. Privacy screen is clear and accurate.
6. App can run all day without obvious CPU drain.
7. App can mute instantly from menu bar.
8. App can mute meeting apps.
9. Sound packs can be switched without restart.
10. Free and Pro tiers behave correctly.
11. App handles permission denial gracefully.
12. App handles sleep/wake.
13. App handles output device changes.
14. App does not interfere with shortcuts.
15. App does not modify keyboard input.
16. App has no critical crashes in 24-hour internal dogfood test.
17. App Store screenshots and metadata are ready.
18. Website landing page is ready.
19. Support/troubleshooting page is ready.
20. App is signed, hardened, notarized or App Store packaged.

---

## 30. Risks and Mitigations

## Risk 1: Users fear keylogging

Mitigation:

- Strong privacy-first onboarding.
- No account required.
- No network required for core features.
- Privacy screen in app.
- App Store description clearly states no typed text is stored.
- Optional open technical privacy page.

## Risk 2: Audio delay

Mitigation:

- Native app.
- Preloaded buffers.
- Warm audio engine.
- Latency diagnostics.
- Bluetooth warning.
- Built-in/wired recommendation.
- Avoid Electron.

## Risk 3: App Store permission rejection

Mitigation:

- Use permissions transparently.
- Explain why Input Monitoring is needed.
- Use listen-only behavior.
- Do not collect sensitive data.
- Do not hide monitoring.
- Include privacy policy.
- Provide reviewer notes.

## Risk 4: Sounds become annoying

Mitigation:

- Good default volume.
- Soft default pack.
- Quick mute.
- Meeting mode.
- Quiet hours.
- App-specific profiles.
- Gentle packs.

## Risk 5: Competitive apps already exist

Mitigation:

- Better UI.
- Better sounds.
- Better privacy positioning.
- Better focus features.
- Better onboarding.
- Better app profiles.
- Better creator/import tools.
- Stronger marketing.

## Risk 6: Keyboard layouts vary

Mitigation:

- Use physical keycode categories.
- Do not rely on typed characters.
- Provide configurable key category mapping later.
- Test common layouts.

---

## 31. Developer Notes

### 31.1 Important Implementation Rules

1. Do not block keyboard events.
2. Do not modify keyboard events.
3. Do not log typed characters.
4. Do not do disk IO per keystroke.
5. Do not do network calls per keystroke.
6. Do not show too many notifications.
7. Do not auto-enable loud sounds.
8. Do not require sign-in.
9. Do not make onboarding too long.
10. Do not bury mute controls.

### 31.2 Recommended Defaults

- Default pack: Soft Brown.
- Default volume: 55%.
- Release sounds: on at 35%.
- Modifier sounds: on at 30%.
- Pitch variation: on at ±2%.
- Sample variation: on.
- Menu bar animation: on but subtle.
- Stats: on with clear local-only explanation.
- Launch at login: ask during onboarding, not forced.
- Dock icon: hidden after onboarding unless user chooses to show.
- Meeting apps: suggest mute rules but let user confirm.

### 31.3 First Sound Moment

The first sound moment is critical. The user must hear a beautiful, satisfying sound immediately after setup. Use the best default sound pack. The onboarding test field should be polished and emotionally rewarding.

---

## 32. Final Product Principle

Thock Studio should feel like buying a tiny premium keyboard upgrade for the Mac.

It should not feel complicated. It should not feel creepy. It should not feel like a novelty soundboard. It should feel like a polished, private, Mac-native utility that makes typing more satisfying every day.

Build the first version around one emotional reaction:

> “Wow, this makes typing feel good.”
