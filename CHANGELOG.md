# Changelog

## v2.7.0

Mission outcome tracking. Until now every completion looked identical:
the app could not tell whether you actually did the thing or just
tapped a button, so a streak measured button presses rather than
activity. Storage format is additive, so existing history still loads.

### New features
- **Say whether you actually did it.** The mission sheet now offers
  "Done", "Partly done", and "Didn't do it" alongside the existing
  accept button. One extra row, no extra tap, and no follow-up dialog
  that could be dismissed and lose the completion.
- **A skipped mission costs you the streak.** It is still written to
  history so the attempt is visible, but it pays no XP and never
  advances the streak. Pretending you showed up no longer keeps a
  streak alive.
- **Partial credit.** A partly done mission pays 60 percent of its XP
  and still counts as an active day.
- **Follow-through stat** in Stats, showing the share of tracked
  completions you actually carried out. It shows a dash rather than
  0 percent until you have tracked something, so no data does not look
  like a failure.
- **Outcome badges in History**, so you can scan what you actually
  finished versus what you walked away from.
- **Four new achievements**, including one for honestly reporting the
  missions you skipped.
- **Custom missions ask the same question** before paying out.

### Optimizations
- **Skipped attempts are excluded from "missions completed".** The
  weekly and 30-day charts, the active-day average, the busiest
  weekday, and the Home recap all count real activity only, so they
  stay consistent with the total above them.
- **Rows saved before this feature count as activity**, exactly as they
  did before, and are left out of the follow-through figure rather than
  being quietly counted as successes.

## v2.6.0

Full-app audit pass: 20 findings, most of them making numbers on screen
wrong rather than merely ugly. Storage format unchanged, so every
existing save and backup still loads.

### New features
- **Indonesian is now complete.** Mood, location, and energy chips, the
  main "I'm bored" and "Chaos me" buttons, the Mood and Chaos section
  headings, all 10 category labels, the level titles, and the daily
  reminder notification text are all translated. The reminder was the
  worst case: it was the one surface that reached the user after they
  closed the app, and it had no way to be switched to Indonesian.
- **Framework dialogs follow the app language.** The time picker, date
  picker, and text selection toolbar were hardwired to English, so an
  Indonesian app showed Indonesian buttons around an English picker.

### Optimizations
- **Every completion now counts as a day.** Finishing a daily challenge
  or a quest chain paid out XP but wrote no history entry, moved no
  streak, and updated no statistics. A day you actually spent on
  something showed up blank in the weekly chart, the average XP figure,
  the busiest-weekday stat, and the streak.
- **Achievement progress bars update live.** The screen tracked only two
  of the eight metrics it displays, so a reroll or an inbox save changed
  the underlying numbers without ever changing the selected value: the
  comparison came back equal, no rebuild happened, and the bars stayed
  frozen until you happened to complete a mission.
- **The 30-day chart is readable.** A fixed 8px gap between bars ate most
  of the canvas at 30 bars, leaving them under 2px wide, and went
  negative on narrow screens. The gap now scales with the bar count.
- **The level title lookup no longer depends on map insertion order.**

### Bug fixes
- **The statistics breakdown now adds up.** Chaos missions were dropped
  from the category chart even though Chaos Mode can roll them and they
  were being counted, so the bars disagreed with the "missions
  completed" total above them.
- **Restoring a backup no longer leaves yesterday's daily challenge
  behind** on disk when the payload did not carry one.
- **Opening the import dialog twice can no longer close the app.** The
  dialog was dismissed through the screen's own navigator, so a second
  pop could take out the app's only route.
- **Invalid custom mission input now shows its error.** The dialog stayed
  open behind the message, so tapping Save looked like nothing happened.
- **Rerolls are saved before the new mission is rolled**, so a kill
  right after a reroll no longer hands back a free one.
- **Dislikes publish a new collection** like favorites already did,
  which keeps the two toggles from diverging.
- **Starting the app no longer races your language or theme choice**;
  they were being re-read from disk on every rebuild.

## v2.5.0

Closes the four long-standing issues left open by the earlier audits.
No storage format change, so every existing save and backup still loads.

### New features
- **History now speaks your language.** Entries used to show the English
  title and category frozen at the moment of completion, so an
  Indonesian user got an English list. Titles and categories are now
  resolved from the catalog in the active language.
- **History search matches what you see.** It searched the stored
  English text, so searching for the Indonesian word matched nothing on
  screen.

### Optimizations
- **Custom missions now appear in the stats breakdown.** They were
  always counted in the totals and recorded per category, but their row
  was filtered out, so the category bars added up to less than the
  "missions completed" number above them.
- **The activity chart repaints on theme and accent changes.** It
  compared only the bar counts, so switching light/dark or accent kept
  the old bar colors on screen. It also compared lists by identity,
  which meant identical data still counted as a change.

### Bug fixes
- **The share card understated weekend XP.** The mission sheet opens
  before a mission is accepted, so the card showed the base value: half
  of what the mission is actually worth on a weekend.

## v2.4.3

Third audit pass, aimed at the undo system and the inbox counter.

### Fixed
- **Undoing could permanently desync the saved-mission counter.** The
  progress snapshot carries `missionsSaved`, but the inbox list was not
  part of it. Save missions after completing one, then undo, and the
  counter rolled back while the list kept its entries. Every later removal
  made the drift worse, and the save-count achievements could stop
  firing. Both now travel together.
- **Save-count achievements unlocked silently.** They were persisted but
  never surfaced to the user, unlike every other unlock.
- **Retrying a failed startup could count one app open more than once**,
  enough to unlock the 7-day streak achievement on its own. The open is
  now counted at most once per day.
- **Undo could leave a quest chain on disk** that the app had already
  dropped from memory. The cleared value is now written through.

## v2.4.2

Second audit pass, focused on the v2.4.1 fixes themselves. Additive
storage format, so every existing save and backup still loads.

### Fixed
- **The daily reminder only fired once.** `zonedSchedule` was used
  without `matchDateTimeComponents`, which makes it a one-shot. Now
  scheduled with `DateTimeComponents.time`, so it really repeats every
  day as the setting promises.
- **Milestone bonus never applied to daily challenges and quest
  chains.** Those call sites passed a base value of 0, which made the
  before/after level comparison always equal.
- **Inbox "Roll it" could overwrite a mission already waiting to be
  accepted.** The restore now refuses and keeps the inbox entry instead
  of losing either one.
- **Startup could hang on an endless spinner** if local data could not
  be read. There is now an error screen with a retry button.
- **Backup export produced invalid JSON** when a custom mission
  contained a tab or carriage return, because only backslash, quote,
  and newline were escaped.
- **Backup import could be crashed by pasted input.** Payloads are now
  capped in size and nesting depth, and malformed unicode escapes and
  numbers are rejected instead of throwing out of the parser.

## v2.4.1

Bug-fix release found by a full code audit of v2.4.0. No format changes,
so every existing save and backup still loads.

### Fixed
- **Completed missions could be missing from the Missions tab.** History
  was mutated in place, and `context.select` compares with
  `DeepCollectionEquality`, which treats an in-place mutation as
  unchanged, so the screen never rebuilt. History now publishes a new
  list. Same root cause fixed for Favorites and Muted categories, whose
  buttons previously looked dead.
- **History could lose its newest entry.** `saveHistory` wrote the
  in-memory (newest-first) list in the wrong order and trimmed the wrong
  end, so after an undo at the 200-entry cap every later completion
  silently dropped the previous one. It now reverses to the stored
  oldest-first order and trims the oldest.
- **Backup import never persisted history**, so restored XP disagreed
  with the history list after the next launch. Import is also now
  atomic: a malformed entry leaves your data untouched instead of
  half-applied.
- **Inbox "Roll it" lost the mission.** The restored mission was stored in
  the same slot the next roll always overwrote, so it vanished. The
  sheet now opens directly on the restored mission.
- **Undo after finishing a Quest Chain destroyed the chain.** Undo rolled
  back the XP but not the chain itself. Undo now restores the chain and
  the daily challenge state too.
- **Milestone XP repeated on every completion** while the level was a
  multiple of ten, which handed out hundreds of free XP at level 20. The
  bonus now pays only when a boundary is actually crossed.
- **Level achievements showed total XP** ("4500/10") instead of the
  level on the progress bars.
- **Weekend double XP was reported at its base value** on the daily
  challenge and custom mission toasts.
- **Muting every category silently disabled muting.** Muting is now
  refused for the last remaining category, with an explanation.
- **Chaos Mode ignored muted categories**, contradicting the setting.
- **Reset Progress left the daily reminder enabled**, so the
  notification came back on the next launch.
- Reset and backup import now clear leftover "+XP" toast state and clamp
  quest chain step counts against the current catalog.
- Streak-at-risk warning now also covers the 3-day freeze case, and the
  daily challenge rolls over when the app is resumed past midnight
  instead of serving yesterday's challenge.
- Share failures fall back to sharing plain text instead of doing
  nothing.
- Mission sheet is now scrollable with a height cap, so long content
  and large text scales no longer overflow.
- Removed dead code: `inboxRestored`, `sharedCopied`, `weekdaysShort`,
  `shareBtn`.

## v2.4.0

Additive feature release. Old saves and backups keep loading, and this
is the first version that asks for the notification permission (opt-in,
off by default, requested only when you turn reminders on).

### Added
- Daily reminder notifications at a time you choose, with a switch and a
  time picker in Profile. Permission is requested only on enable.
- Share card: any mission renders into a 1080x1080 PNG (emoji, title,
  description, XP, level) built with dart:ui and handed to the system
  share sheet.
- Inbox: save a mission for later with the bookmark button, then roll it
  when you are ready. Capped at 50 entries and included in backups.
- Quick wins toggle: narrows rolls to missions of 15 minutes or less.
- Not interested: mute a whole category from the mission sheet, or
  manage muted categories in Profile.
- Weekly recap strip on Home: missions, XP, and current streak.
- Milestone bonus XP when a completion crosses every 10th level.
- Undo now covers daily challenges, quest chain steps, and custom
  missions, not just rolled missions.
- 4 new achievements tracking freeze tokens earned and saved missions,
  with progress bars for every tracked achievement.
- Achievement progress bars under the grid.

### Improved
- CI upgraded to Flutter 3.47.7 so current notification and share
  plugins can be used.

## v2.3.0

Game-depth release without breaking changes: old saves and backups
keep loading, since every addition is additive.

### Added
- Streak freeze tokens: a token covers a 2-day gap, and every 7-day
  streak earns one (max 3 held). Tokens show in Profile.
- Weekend double XP on every XP gain, with a 2x tag on the mission
  sheet.
- 4 seasonal missions that only roll in their months, plus 12 regular
  missions and a new Deep Work Arc quest chain.
- Generator v2: picks are weighted toward least-played categories, so
  variety grows the more you play.

## v2.2.0

Personalization and insight release. Pure Dart, no new plugins or
permissions.

### Added
- Light theme plus 5 accent colors, switched in Profile under
  Appearance. Every screen now reads a semantic palette instead of
  hardcoded dark colors.
- Haptic feedback on taps and completions, with a toggle in Profile.
- Monthly stats: last-30-days chart, average XP per active day, and
  busiest weekday.
- Dislike button on the mission sheet: disliked missions stop coming
  out of the generator, and dislikes are included in backups.

### Improved
- Info pills, chips, and chart bars now adapt to the active theme
  instead of assuming a dark background.

## v2.1.0

Build and first-impression release. Smaller APKs, custom branding, and
a proper welcome for new users.

### Added
- 3-page onboarding shown once on first launch (skippable), in English
  and Bahasa Indonesia.
- Custom launcher icon (dice mark) and dark launch background,
  replacing the default Flutter branding. Vector-only, no new
  dependencies.

### Improved
- Release builds are now obfuscated with split debug info, and the
  unused x86_64 slice is dropped, so downloads are smaller.
- Startup reads run concurrently instead of one by one.

## v2.0.2

Fixes a pre-existing CI bug where the APK finder step copied
`app-release.apk` onto itself and failed the build even though
`flutter analyze`, `flutter test`, and the APK build itself all passed.
No app changes.

## v2.0.1

Hotfix for issues caught by CI (`flutter analyze`): a wrong import path
in `lib/l10n/app_strings.dart`, a non-constant `FormatException` throw,
an unused local in `exportBackup`, and two missing `const` in tests.
No behavior changes.

## v2.0.0

Polish release: progress visibility and streak safety, still with zero
native plugins and zero new permissions.

### Added
- Weekly activity chart on the Stats tab, drawn with a dependency-free
  CustomPainter (no chart package, no extra APK weight).
- Streak grace day: a streak now survives one missed day and only resets
  after two. A warning banner on Home appears while the streak is at
  risk.
- Share: copy any mission as text from the mission sheet and paste it
  anywhere.
- Per-tag GitHub Releases with split-per-ABI APKs
  (`.github/workflows/release.yml`), so each version ships installable
  artifacts automatically.

### Improved
- README rewritten in the Swara template, in English (`README.md`) and
  Bahasa Indonesia (`README.id.md`).

## v1.3.0

Feature release, built on the v1.2.0 foundation. No native plugins were
added, so the APK stays light and no new permissions are needed.

### Added
- Custom missions: create your own missions with title, description, and
  XP reward (5 to 200), complete them for XP like catalog missions, delete
  them anytime. Stored locally, included in backups.
- Favorites: tap the heart on any mission sheet to pin catalog missions
  to a Favorites section on the Missions tab.
- History search: filter completed missions by title or category.
- Undo: completing a mission now offers a 5-minute Undo action that
  restores XP, streak, and history.
- Backup: export all local data as text (copied to clipboard) and import
  it back to restore, useful before switching phones. Still fully local,
  no account or server.

### Improved
- Mission rolls skip missions completed in the last 7 days when
  alternatives exist, so repeats feel fresh. Falls back gracefully when
  everything was recently completed.

## v1.2.0

Foundation release: English by default with an Indonesian option, plus
weight and rebuild optimizations. No changes to the stored data format,
so existing progress on the phone keeps working after the update.

### Added
- English UI by default with a Bahasa Indonesia switch in Profile
  (`lib/l10n/app_strings.dart`, `lib/providers/language_provider.dart`).
  Same pattern as Swara: English source of truth, persisted choice,
  hand-written tables instead of codegen so the APK stays small.
- Every catalog (missions, achievements, daily challenges, quest chains)
  now carries English text plus an Indonesian translation with English
  fallback, so nothing ever renders blank.
- Unit tests: level curve (`test/user_progress_test.dart`), mission
  generator fallback and filters (`test/mission_service_test.dart`),
  string coverage and catalog sanity (`test/localization_test.dart`).

### Improved
- Removed the `intl` dependency (used exactly once). Date labels now use
  `lib/utils/date_format.dart`, a 30-line locale-aware formatter.
- Removed the unused `cupertino_icons` dependency.
- `StorageService` caches the SharedPreferences instance instead of
  requesting it on every read and write.
- Screens now rebuild selectively (`context.select` for reads,
  `context.read` for actions) so tapping one chip no longer rebuilds the
  whole page.
- History list uses a lazy sliver builder, cheap even with 200 entries.
- All code comments are now English to match the other repos.

### Fixed
- Time budget labels that were still Indonesian in English mode
  ("1 jam", "2 jam+").

## v1.1.0

Full audit of the codebase (models, providers, services, screens,
widgets). Result: the architecture was already solid, with one real
functional bug plus a few polish items.

### Fixed
- **Bug: XP bar showed negative numbers for new users.** The level curve
  (`UserProgress.xpNeededForLevel`) had an off-by-one: level 1 was treated
  as needing 50 XP to "reach", even though new users start at level 1 with
  0 XP. Before total XP passed 50 (that is, before finishing the first
  mission, since the smallest catalog mission is only 15 XP), the XP bar
  rendered values like "-50/100 XP". Visible on the first screen every new
  user opens. Fixed by shifting the curve base so level 1 starts at 0 XP.
- The **REROLL** button is now truly disabled (not just a snackbar) once
  the daily reroll budget runs out.
- `flutter_lints` was already in `pubspec.yaml` but never active because
  `analysis_options.yaml` was missing. Added.

### Improved
- Unlocked achievements now sort first in the Achievements grid (newest
  unlock first).
- Mission history on the Missions tab uses `ListView.builder` (lazy),
  not a plain `ListView`, lighter once history reaches hundreds of rows.
- Light haptic feedback on ACCEPT, on mission COMPLETE, and on reroll.
- App version footer plus repo link on the Profile tab.

### Added
- `LICENSE` (MIT).
- `analysis_options.yaml`.
- Follow-up roadmap in README.

No changes to the stored data format, so progress already on the phone
keeps loading normally after the update.
