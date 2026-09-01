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

- 🎛 **Mood check-in** — a four-state switch (bad · normal · good · full f0kus) with a different vibration pattern for each: one weak pulse at the bottom, a rising burst at the top. The state is something you feel, not just read
- 🧠 **Recommendations that learn** — a contextual bandit picks between Sprint 15, Pomodoro 25/5, Pomodoro 50/10 and Deep work 90 based on what has actually worked *for you* in this mood, on this kind of task, at this hour. Not a lookup table someone guessed on your behalf
- 🔍 **Recommendations that show their work** — the "why this" card names the level of context the advice rests on (this exact situation · similar work · this mood in general), how many of your own sessions are behind it and how often it worked out — not a bare confidence percentage
- 📝 **What the session was actually like** — an optional reason when you stop early (distracted · wrong task · too tired · rather not say) and a short note or pixel sticker afterwards. Choosing a technique against the recommendation is recorded separately and taught at a third of the weight: it says you disagreed with the advice, not that the technique is bad
- 🛑 **Brakes against burnout** — a nudge when a new session starts within minutes of the last, a night soft cap that stops suggesting anything longer than 25/5 past your chosen hour, and a pause after three interrupted sessions in a row. Every one of them can be overruled on the spot
- 🌱 **Honest cold start** — for the first ten sessions the app says so plainly and falls back to sensible defaults, instead of dressing up noise as insight
- ⏱ **A dial you can turn mid-session** — drag the ring to add or shave minutes without leaving the timer; it clicks once per minute under your thumb. Full-screen minimal mode on a double tap
- ✅ **Habits with a price** — every habit requires you to write down what you owe yourself if you skip it. The app stores it, shows it on the card, and reads it back in the reminder. Nothing is automated — that is the point
- 🎁 **A reward next to the price** — an optional "if you keep it up for N days" you write yourself, shown the moment the streak reaches it
- 📅 **Habits that don't need fixed days** — either chosen weekdays or simply N times a week, where the streak counts closed weeks instead of days
- ❄️ **One way out** — a streak freeze, once a week by default: a skipped day that holds the streak without extending it, with the remaining quota visible on the card
- 🔥 **Streaks that don't lie** — an unfinished day doesn't break the streak until the day is actually over
- 🗒 **Plan for the day** — two or three tasks in rough order, offered first at the next check-in, each with an optional checklist of up to five steps you tick off while the timer runs
- 🔁 **One more like this** — restart a finished session with the same settings, without going through the check-in again
- 📊 **Statistics** — a pixel-art contribution heatmap, focus minutes per day, a breakdown by task category, habit completion rates, how often each penalty actually bit, why sessions broke off, and the most useful chart of all: which mood you actually finish sessions in
- 🔔 **Local reminders** — per-habit reminders plus an end-of-day summary: what's still open, and on a productive day the sessions, focus time and dominant mood behind it
- 💾 **Export and import JSON** — everything you've logged, in one file, and back again on a new device — merging with what's there or replacing it, after a warning that says plainly which one wipes your history
- 🌍 **Languages** — English, Русский, Polski, Українська, following the system by default
- 🎨 **Two themes, five accents** — pixel-art in the dark (black, grey, `#4a7dfb`) and a warm orange-and-beige light theme, with a preset accent tone you can swap without the palette losing its footing
- 🎮 **An optional game on top** — switch the tracker into game mode and the same sessions become a fight. Drifters (creatures that pull your attention away) stand on a map of worlds with a boss at the end of each; a session's minutes are damage, finished habits and sessions are XP, and your character levels up through four visual stages. Bosses only take real damage from sessions started in **full f0kus** — and if you abandon enough of those, the boss heals and says so plainly instead of quietly rolling your progress back. Turning game mode off hides all of it and keeps every point of it
- 🔕 **A timer end you can't miss** — the completion notification is handed to the system when the session starts, not fired by a live timer, so it survives the app being closed or the screen locked; it waits in the tray instead of auto-dismissing, and the vibration goes straight to the motor so silent mode can't swallow it
- 📴 **Fully offline** — no account, no cloud, no telemetry. The data never leaves the device

Part of the **TexFi** ecosystem, alongside [TexFi m0ney](https://github.com/mistqkw/texfi-money), [TexFi Files](https://github.com/mistqkw/texfi_files) and [TeFBlock](https://github.com/mistqkw/tefblock).

## Design

Pixel-art, deliberately — retro-game furniture rather than the flat black minimalism every
second app defaults to. Accent elements (headings, timer digits, counters) are set in
**Press Start 2P**; everything you actually read for meaning is **Inter**, because a pixel
font in a paragraph is a design statement at the reader's expense. Numbers use tabular
figures so the timer doesn't twitch on every tick.

The dark theme is black and grey with the TexFi blue `#4a7dfb`; the light theme is warm
orange, cream and beige — the same pixel language, sunlit. Both palettes are declared as
tokens in [`app_palettes.dart`](lib/core/theme/app_palettes.dart) and reach widgets through
a `ThemeExtension` (`context.colors`), never as literal colors in a screen.

Cards carry moderate radii (8–12px) so the interface still reads as modern; buttons,
switches, checkboxes and heatmap cells stay square, with a 2px border and a solid offset
shadow instead of a blur — a key that visibly depresses when you press it. That shadow is
one widget ([`pixel_shadow.dart`](lib/presentation/shared/pixel_shadow.dart)), reused by
cards, buttons and the range switches alike, so the sense of depth cannot drift a pixel
between screens. Every distance comes from one 4pt scale in
[`app_spacing.dart`](lib/core/theme/app_spacing.dart) rather than being eyeballed per
screen.

Every icon in the app is a sprite drawn from a text grid — `'.'` for empty, `'x'` for a
filled pixel — rendered by [`pixel_sprite.dart`](lib/presentation/shared/pixel_sprite.dart)
and catalogued in `PixelSprites`. The bottom tab bar, the mood faces, the onboarding
illustrations and the button glyphs all come from that one grid, so nothing has to be
imported from a Material icon set that belongs to a different design language. Radio
buttons, checkboxes and switches are square-framed pixel indicators
([`pixel_radio.dart`](lib/presentation/shared/pixel_radio.dart)) rather than Material's
circles, down to a square slider thumb.

Screen transitions use a short pixel-dissolve with a scanline pass
([`app_page_transitions.dart`](lib/core/theme/app_page_transitions.dart)) — ~260ms, present
enough to notice once, quiet enough to stop noticing. The background carries a faint
deterministic pixel speckle so the dark theme reads as a surface rather than a void.

## Stack

- **Flutter** — one codebase across Android, Windows, Linux and macOS, and the only toolkit where a hand-painted pixel dial behaves identically on all four
- **Riverpod** — plain hand-written providers, no code generation. The dependency graph stays something you can read top to bottom in [`data_providers.dart`](lib/data/providers/data_providers.dart)
- **Drift (SQLite)** — typed queries and reactive `.watch()` streams, so the UI follows the database instead of being told to refresh
- **Clean architecture** — `data/` → `domain/` → `presentation/`, with repositories behind interfaces in `domain/repositories`. Sync can be added later by writing new implementations, without touching a screen
- **fl_chart** — bar and pie charts, restyled square to match the pixel language
- **flutter_local_notifications + timezone** — scheduled habit reminders
- **vibration** — custom haptic patterns, with the built-in `HapticFeedback` as the fallback wherever there's no motor
- **Bundled fonts** — Press Start 2P and Inter ship in `assets/fonts` rather than being fetched at runtime. The app is offline-only; when the download quietly failed, Flutter fell back to the system font and every heading and counter stopped being pixel-art at once

## Project structure

```
lib/
  core/
    constants/      app identity constants
    haptics/        vibration vocabulary (per-mood patterns, dial ticks)
    notifications/  local notification scheduling
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
    onboarding/     first run: concept, theme, first habit, notifications
    home/           streak, today's habits, focus summary
    mood_checkin/   the four-state mood switch and task pick
    planner/        day plan and the per-task checklist editor
    timer/          recommendation, manual setup, the dial screen,
                    session wrap-up (rating, interruption reason, note)
    habits/         habit list and editor (punishment, reward, frequency)
    statistics/     heatmap, charts, mood-vs-outcome, penalties, interruptions
    game/           the optional RPG layer: map, character, encounter UI,
                    drifter and boss sprites, game providers
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
