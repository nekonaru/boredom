# Changelog

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
