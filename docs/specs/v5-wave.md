# Spec: Boredom v5 wave

Goal: expand Boredom from a single-roll game into a deeper offline game with journal, decks, ranks, richer motion, and a cleaner design system, without breaking existing saves or backups.

## Inputs
- Existing local state in `SharedPreferences` under the current keys.
- Existing catalogs, providers, screens, and tests in `lib/` and `test/`.

## Outputs
- One tagged release, `v5.0.0`, covering the foundation and progression work delivered in this wave.
- Bilingual release notes and changelog for the tag.
- Both APKs attached to the GitHub Release.
- Deferred to later waves, tracked here so they are not lost: mission packs and new categories, time of day rolls, mission decks, journal entries, smart notifications, quick find, and monthly report card.

## Constraints
- Fully offline. No accounts, no HTTP, no new runtime packages.
- English is the source for code, comments, and docs. Indonesian is a translation.
- No em dash, no en dash, no emoji in docs, README, changelogs, or release notes.
- Old backup format `version: 1` must still import after the format moves to `version: 2`.
- `flutter analyze` reports zero issues and all tests pass before every push.
- Tag only after CI is green on the merged branch commit.
- Pipeline mode is `pr`: branch, commit, push, PR, CI, squash auto-merge.

## Done criteria a machine can check
- `flutter analyze` exits 0 with no issues.
- `flutter test` exits 0 with all tests passing.
- New state fields round trip through `exportBackup` and `importBackup`; a v1 backup still imports with defaults.
- `pubspec.yaml` version and `kAppVersion` match each tag.
- Release body contains `# English`, `# Bahasa Indonesia`, one summary sentence per language, and `## Install / Update`.
- Release title is exactly `Boredom vX.Y.Z`.
- `gh release view <tag> --json assets` lists both APK files.
- Every changed file is free of U+2014 and U+2013.
