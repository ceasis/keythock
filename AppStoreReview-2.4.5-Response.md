# App Store Review — Guideline 2.4.5 Response (KeyThock)

Bundle ID: `com.keythock.app`

## Before resubmitting — verify only Input Monitoring is requested

Reset the permissions and launch the new build. You should see **only** the
Input Monitoring prompt, never an Accessibility prompt.

```sh
tccutil reset Accessibility com.keythock.app
tccutil reset ListenEvent  com.keythock.app
```

If no "control this computer using accessibility features" prompt appears, the
literal basis for the 2.4.5 rejection is gone.

---

## Reply to the reviewer (Resolution Center)

Hello, and thank you for the review.

We have removed the API that triggered the Accessibility requirement and would
like to clarify how KeyThock accesses key events, as we believe this build fully
complies with Guideline 2.4.5.

**What the app does.** KeyThock plays mechanical-keyboard sound effects in
response to the user's typing. To do this it must observe key-press *timing*
system-wide, because the user types in their editor, browser, or chat app — not
inside KeyThock.

**What changed in this build.** The previous build used
`NSEvent.addGlobalMonitorForEvents`, which macOS gates behind the
**Accessibility** privilege. We have removed it entirely. The app now observes
key events solely through a **listen-only `CGEventTap`**
(`CGEventTapCreate` with `kCGEventTapOptionListenOnly`), which is gated by the
**Input Monitoring** privilege and requested via `CGRequestListenEventAccess()`.
KeyThock no longer requests, links, or uses Accessibility in any form, and the
binary contains no Accessibility APIs.

This matches Apple Developer Technical Support's guidance that a listen-only
`CGEventTap` is the supported, sandbox-compatible mechanism for monitoring key
events and is gated by Input Monitoring — not Accessibility — whereas `NSEvent`
global monitors require Accessibility for historical reasons.

**On the suggestion to use `NSEvent.addLocalMonitorForEvents`.** A local monitor
only receives events delivered to KeyThock's own windows. Because the entire
purpose of the app is to provide audio feedback while the user types in *other*
applications, a local monitor cannot deliver the feature. Input Monitoring is
the minimum and correct privilege for this purpose.

**Privacy.** KeyThock uses a *listen-only* tap; it never modifies, blocks, or
injects events. It does not record, store, or transmit keystrokes or typed text
— each event is used only to select and play a sound, then discarded. The app
captures only a hardware key code and a broad category (letter, number, space,
etc.) to choose a sample; it never reconstructs typed content. KeyThock has no
network access (no network entitlement) and contains no analytics.

We would be grateful for a re-review on this basis, and we're happy to provide a
demonstration build if helpful.

Thank you,
The KeyThock team

---

## Short version — "Notes for Review" field (App Store Connect → this version)

KeyThock plays keyboard sound effects in response to typing, so it observes
key-event timing system-wide. It uses a **listen-only CGEventTap** gated by the
**Input Monitoring** privilege (`CGRequestListenEventAccess`). It does **not**
use Accessibility, does not modify or inject events, and does not log, store, or
transmit keystrokes or typed text. The app has no network access. A local-only
`NSEvent` monitor cannot provide the feature because the user types in other
apps, not in KeyThock.
