<p align="center">
  <img src="assets/banner.png" alt="TexFi f0kus" width="100%">
</p>

<h1 align="center">TexFi f0kus</h1>

<p align="center">
  <b>A focus timer that learns how you actually work — and a habit tracker that holds you to your word.</b><br>
  Check in with your mood, get a session length that fits it, and let the app get sharper with every session.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-Android%20%7C%20Windows%20%7C%20Linux%20%7C%20macOS-4a7dfb" alt="Platform">
  <img src="https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/state-Riverpod-4a7dfb" alt="Riverpod">
  <img src="https://img.shields.io/badge/license-open%20source-green" alt="License">
</p>

<p align="center">
  <a href="#features">Features</a> ·
  <a href="#design">Design</a> ·
  <a href="#stack">Stack</a> ·
  <a href="#project-structure">Project structure</a>
</p>

---

## Features

- **Mood check-in.** A four-state switch (bad · normal · good · full f0kus), each with its own
  vibration pattern, from one weak pulse at the bottom to a rising burst at the top.
- **Recommendations that learn.** A contextual bandit picks between Sprint 15, Pomodoro 25/5,
  Pomodoro 50/10, Deep work 90, and any preset you write yourself, based on what's actually worked
  for you in this mood, on this kind of task, at this hour. It's not a lookup table someone filled
  in on your behalf.
- **Your own rhythm.** If you work in 35/7 or 20/3, add it in Settings and it becomes a real option
  the engine can propose, with its own statistics rather than borrowing another technique's record.
- **Recommendations that show their work.** The "why this" card names the level of context behind
  the advice (this exact situation, similar work, or this mood in general), how many of your own
  sessions back it up, and how often it worked out — not just a bare confidence number.
- After a session you can log what it was actually like: an optional reason for stopping early
  (distracted, wrong task, too tired, rather not say), plus a short note or pixel sticker. Going
  against the recommendation gets recorded separately and weighted a third as much — it means you
  disagreed with the advice, not that the technique itself is bad.
- **Brakes against burnout.** A nudge if you start a new session minutes after the last one, a
  night cap that stops suggesting anything longer than 25/5 past your chosen hour, and a pause
  after a run of interrupted sessions (two to five, your call). Every one of these can be overruled
  on the spot.
- **Honest cold start.** For the first ten sessions the app just says so and falls back to sensible
  defaults, instead of dressing up noise as insight.
- A dial you can drag mid-session to add or shave minutes without leaving the timer — it clicks
  once per minute under your thumb. Double-tap for a full-screen minimal mode.
- **Habits with a price.** Every habit needs you to write down what you owe yourself if you skip
  it. The app stores that, shows it on the card, and reads it back in the reminder. Nothing about
  this is automated — that's the point.
- An optional reward next to the price: something like "if you keep it up for N days," written by
  you, shown the moment the streak reaches it.
- Habits don't need fixed days — pick weekdays, or just N times a week, and the streak counts
  closed weeks instead of days.
- A streak freeze, once a week by default, lets you skip a day without breaking the streak (it
  just doesn't extend it either). Remaining quota is visible on the card.
- Streaks that don't lie: an unfinished day doesn't break the streak until the day is actually
  over.
- **Plan for the day.** Two or three tasks in rough order, offered at the next check-in, each with
  an optional checklist of up to five steps to tick off while the timer runs.
- Restart a finished session with the same settings without going through check-in again.
- **A character that visibly grows.** Eight rank titles from *a spark* to *a small sun*, and six
  drawn stages along the way. The whole ladder is visible from level one, dimmed but there, so what
  you'll look like at level 21 isn't a surprise, it's a reason to come back.
- Optionally attach a photo of what you actually worked on — the notebook, the screen, the desk.
  It stays on the device, shows as a small preview in history, opens full-size on tap, and gets
  deleted with the session. Skip it and nothing else changes.
- **Statistics.** A pixel-art contribution heatmap, focus minutes per day, a breakdown by task
  category, habit completion rates, how often each penalty actually bit, why sessions broke off, a
  plain list of the sessions themselves, and probably the most useful chart of the bunch: which
  mood you actually finish sessions in. Weeks start Monday or Sunday, whichever is yours.
- Local reminders per habit, plus an end-of-day summary of what's still open and, on a good day,
  the sessions, focus time and dominant mood behind it.
- **Export and import JSON.** Everything you've logged, in one file, restorable on a new device —
  merging with what's there or replacing it, with a clear warning about which one wipes your
  history. An optional weekly backup writes the same file to a `backups/` folder and keeps the
  last four, so an offline app still has something to fall back on.
- Languages: English, Русский, Polski, Українська, following the system by default.
- Two themes, five accents: pixel-art in the dark (black, grey, `#4a7dfb`) or a warm
  orange-and-beige light theme, with a preset accent you can swap without the palette losing its
  footing.
- **An optional game on top**, offered as a plain choice on first run and switchable later in
  Settings. In game mode your sessions become a fight: nine drifters, three to a world, each with
  its own name, silhouette and one-line description, stand on a map of three named worlds with a
  boss at the end of each. Starting a session against one opens a battle screen where the creature
  fills the screen and its HP bar drains with your focus time, so the damage is something you
  watch happen rather than read about later. Bosses only take real damage from sessions started in
  full f0kus, and running out of stamina heals the boss back to full — the game says so up front
  rather than quietly rolling your progress back. Stop early and the drifter just holds its ground:
  no scolding, and any XP you earned stays yours. Turn game mode off and all of it hides, without
  losing anything.
- The completion notification is handed to the system the moment a session starts, not fired by a
  live timer, so it survives the app closing or the screen locking. It waits in the tray instead of
  auto-dismissing, and the vibration goes straight to the motor so silent mode can't swallow it.
  The countdown itself reads off the wall clock, so locking the phone mid-session and coming back
  shows the real time left, not the time the screen went dark.
- A completion sound that plays on silent, screen off included — pick one of five bundled
  chiptune cues in Settings and preview it with a tap. The sound belongs to the notification
  channel itself rather than a player inside the app: the cues ship as Android raw resources and
  the scheduled notification names the one you picked, so the system plays it whether the app is
  in front of you, backgrounded, or killed outright. The channel runs on the alarm stream (Android
  `USAGE_ALARM`), which the mute switch doesn't touch.
- **Quiet mode on the timer.** The screen stays awake during a session or a fight, and tapping the
  moon strips the timer down to black background, grey digits, no sprite, no HP bar, no accent
  color, dimmed. Tap anywhere to come back; brightness is restored on every way out. It's not an
  Always-On Display and doesn't pretend to be one — it just lives inside the app, on a screen
  that's on.
- The app checks GitHub Releases itself and tells you when there's a newer build, since it's
  handed out as an `.apk` rather than through a store. A new version shows up in Settings with the
  first few lines of its release notes and a button that downloads it and hands it to the system
  installer. Checks are cached for hours, failures included, so a phone with no signal doesn't
  hammer the API — and a failed check just doesn't show a card, silently. Android only, since
  nowhere else can install an `.apk` anyway.
- **Fully offline.** No account, no cloud, no telemetry. Nothing you log ever leaves the device;
  the only network call the app makes is that update check, and it asks GitHub about releases
  without sending anything about you.

Part of the **TexFi** ecosystem, alongside [TexFi m0ney](https://github.com/mistqkw/texfi-money), [TexFi Files](https://github.com/mistqkw/texfi_files) and [TeFBlock](https://github.com/mistqkw/tefblock).

## Design

Pixel-art, deliberately — retro-game furniture rather than the flat black minimalism most
apps default to these days. Accent elements (headings, timer digits, counters) are set in
**Press Start 2P**; anything you actually read for meaning is **Inter**, because a pixel
font in a paragraph is a design statement at the reader's expense. Numbers use tabular
figures so the timer doesn't twitch on every tick.

The dark theme is black and grey with the TexFi blue `#4a7dfb`; the light theme is warm
orange, cream and beige — same pixel language, just sunlit. Both palettes live as
tokens in [`app_palettes.dart`](lib/core/theme/app_palettes.dart) and reach widgets through
a `ThemeExtension` (`context.colors`), never as literal colors in a screen.

Cards carry moderate radii (8–12px) so the interface still reads as modern; buttons,
switches, checkboxes and heatmap cells stay square, with a 2px border and a solid offset
shadow instead of a blur — a key that visibly depresses when pressed. That shadow is one
widget ([`pixel_shadow.dart`](lib/presentation/shared/pixel_shadow.dart)), reused by
cards, buttons and the range switches alike, so the sense of depth doesn't drift between
screens. Every distance comes from one 4pt scale in
[`app_spacing.dart`](lib/core/theme/app_spacing.dart) instead of being eyeballed per
screen.

Every icon in the app is a sprite drawn from a text grid — `'.'` for empty, `'x'` for a
filled pixel — rendered by [`pixel_sprite.dart`](lib/presentation/shared/pixel_sprite.dart)
and catalogued in `PixelSprites`. The bottom tab bar, the mood faces, the onboarding
illustrations and the button glyphs all come from that same grid, so nothing gets pulled
in from a Material icon set built for a different design language. Radio buttons,
checkboxes and switches are square-framed pixel indicators
([`pixel_radio.dart`](lib/presentation/shared/pixel_radio.dart)) rather than Material's
circles, down to a square slider thumb.

Screen transitions use a short pixel-dissolve with a scanline pass
([`app_page_transitions.dart`](lib/core/theme/app_page_transitions.dart)), around 260ms —
long enough to notice once, short enough to stop noticing after. The background carries a
faint deterministic pixel speckle so the dark theme reads as a surface, not a void.

## Stack

- **Flutter** — one codebase across Android, Windows, Linux and macOS, and about the only
  toolkit where a hand-painted pixel dial behaves the same on all four.
- **Riverpod** — plain hand-written providers, no code generation. The dependency graph
  stays something you can read top to bottom in
  [`data_providers.dart`](lib/data/providers/data_providers.dart).
- **Drift (SQLite)** — typed queries and reactive `.watch()` streams, so the UI follows the
  database instead of being told to refresh.
- **Clean architecture** — `data/` → `domain/` → `presentation/`, with repositories behind
  interfaces in `domain/repositories`. Sync could be added later with new implementations,
  without touching a screen.
- **fl_chart** — bar and pie charts, restyled square to match the pixel language.
- **flutter_local_notifications + timezone** — scheduled habit reminders.
- **audioplayers** — the completion sound, on the alarm stream so mute doesn't kill it.
- **vibration** — custom haptic patterns, falling back to the built-in `HapticFeedback`
  wherever there's no motor.
- **image_picker** — camera and gallery access behind the optional session photo. The
  picked file gets copied into the app's own documents directory and never leaves the
  device; on platforms without an implementation the button just isn't shown.
- **Bundled fonts** — Press Start 2P and Inter ship in `assets/fonts` instead of being
  fetched at runtime. This is an offline-only app; a silently failed download used to fall
  back to the system font and quietly turn every heading and counter non-pixel.

## Project structure

```
lib/
  core/
    constants/      app identity constants
    haptics/        vibration vocabulary (per-mood patterns, dial ticks)
    notifications/  local notification scheduling
    photos/         session photo storage and picking (copy in, delete out)
    theme/          palettes, typography, spacing, radii, motion, transitions
    utils/          duration formatting
  data/
    local/          Drift database, tables, JSON export and import
    providers/      all Riverpod DI wiring, in one file
    recommendation/ BanditRecommendationEngine (Thompson sampling)
    repositories/   Drift-backed repository implementations
  domain/
    entities/       Habit, Task, Session, Mood, Recommendation, day plan,
                    session guards (short break, night cap, burnout streak),
                    timer alarm planning, game rules and entities,
                    engine interface
    repositories/   abstract repository interfaces
  presentation/
    onboarding/     first run: concept, theme, first habit, notifications,
                    tracker-or-game choice (new installs only)
    home/           streak, today's habits, focus summary
    mood_checkin/   the four-state mood switch and task pick
    planner/        day plan and the per-task checklist editor
    timer/          recommendation, manual setup, the dial screen,
                    session wrap-up (rating, interruption reason, note),
                    the shared session-finish flow and alarm sync
    habits/         habit list and editor (punishment, reward, frequency)
    statistics/     heatmap, charts, mood-vs-outcome, penalties,
                    interruptions, session history with photo previews
    game/           the optional RPG layer: map, character and its stage
                    ladder, the battle screen, encounter UI, nine drifter
                    and three boss sprites, game providers
    settings/       theme, accent, haptics, language, notifications,
                    pace guards, game mode, export and import
    shared/         pixel widget kit, app shell, notification sync
                    pixel_sprite    sprite grids + the PixelSprites catalogue
                    pixel_shadow    the solid offset shadow, used by everything
                    pixel_nav_bar   bottom navigation on sprites
                    pixel_radio     square radio / checkbox / switch indicators
                    pixel_card      bordered card, pixel_button, pixel_heatmap
  l10n/             ARB files: en, ru, pl, uk
assets/
  fonts/            Press Start 2P, Inter — bundled, not fetched
tool/
  generate_icon.py  draws the pixel hourglass icon for every platform
```

## Building

Builds run on GitHub Actions, not locally — push a `v*.*.*` tag and all four platforms
build and attach themselves to a release:

```sh
git tag v1.0.0 && git push origin v1.0.0
```

Until Android signing secrets (`ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`,
`ANDROID_KEY_PASSWORD`) are set in the repository, the APK is signed with a debug key —
installable, but not for distribution. See the comment in
[`.github/workflows/build.yml`](.github/workflows/build.yml).

To regenerate the app icons after editing the pixel grid:

```sh
python3 tool/generate_icon.py && dart run flutter_launcher_icons
```
