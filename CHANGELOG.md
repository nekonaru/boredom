# Changelog

## v3.2.0

### Added
- **Freeze token display on Home.** Your saved freeze tokens now show at the
  top of Home so you always know how many streak-savers you have left.
- **History sort options.** History can now be sorted newest-first,
  oldest-first, or by XP earned (highest first) — tap the sort chip above
  the list.

### Fixed
- **Undo after saving to inbox no longer desyncs the counter.** Saving a
  mission to the inbox now captures an undo snapshot, so undoing restores
  both the inbox list and the `missionsSaved` counter together.

### Improved
- **History sort UI.** The sort chips above the history list make it easy
  to find old entries or high-XP completions quickly.




## v3.1.0

## ✨ New features

- **Daily challenge outcome selection.** The daily challenge now offers
  "Done", "Partly done", and "Didn't do it" alongside the accept button,
  matching the mission sheet. A skipped challenge no longer advances your
  streak or counts as XP. Honesty is rewarded instead of punished.
- **Four new achievements.** Reach level 100 (Beyond Boredom), keep a
  60-day streak (Iron Streak), roll 10 chaos missions (Chaos Connoisseur),
  and reroll 50 times total (Serial Reroller).

## ⚙️ Optimizations

- **Milestone XP judged on actual award.** Daily challenge and quest chain
  completions now calculate milestone bonus against the XP you really
  receive (weekend double + partial scaling), so you no longer receive a
  phantom level bonus on a partial weekend mission.

## 🐛 Bug fixes

- **Daily challenge milestone paid on full value.** The milestone bonus
  was computed against the full weekend-doubled XP even when a partial
  outcome paid only 60%, so you could collect a level bonus without
  actually reaching that level in total XP.
- **Quest chain milestone paid on full value.** Same fix as the daily
  challenge: milestone bonus is now judged on the actual awarded XP.

## 📦 Install / Update

Download the APK matching your device below (`app-arm64-v8a-release.apk` for most modern phones, `app-armeabi-v7a-release.apk` for older 32-bit ones). Open it on your phone and allow installs from unknown sources if asked. Minimum Android 8.0 (API 26).

<br>

---

<br>

# Bahasa Indonesia

## Boredom v3.1.0

## ✨ Fitur baru

- **Pilihan hasil tantangan harian.** Tantangan harian kini menawarkan
  "Selesai", "Dikerjakan sebagian", dan "Tidak dikerjakan" di samping
  tombol terima, sama seperti sheet misi. Tantangan harian yang
  dilewati tidak lagi memajukan streak atau memberi XP — kejujuran
  diberi reward, bukan dihukum.
- **Empat achievement baru.** Capai level 100 (Beyond Boredom), jaga
  streak 60 hari (Iron Streak), roll 10 misi Chaos Mode (Chaos
  Connoisseur), dan reroll 50 kali secara total (Serial Reroller).

## ⚙️ Optimisasi

- **Milestone XP dihitung pada XP yang benar-benar diterima.**
  Tantangan harian dan langkah quest chain kini menghitung bonus
  milestone berdasarkan XP yang benar-benar Anda terima (double akhir
  pekan + penskalaan sebagian), sehingga Anda tidak lagi menerima bonus
  level hampa saat misi parsial di akhir pekan tidak benar-benar
  mencapai level tersebut.

## 🐛 Perbaikan bug

- **Milestone XP tantangan harian dibayar pada nilai penuh.** Bonus
  milestone dihitung terhadap nilai XP penuh yang difold di akhir pekan
  meski hasil parsial hanya membayar 60%, jadi Anda bisa mengumpulkan
  bonus level tanpa sebenarnya mencapai level tersebut dalam total XP.
- **Milestone XP langkah quest chain dibayar pada nilai penuh.** Perbaiki
  yang sama seperti tantangan harian: bonus milestone kini dihitung
  terhadap XP yang benar-benar diterima.

## 📦 Instalasi / Update

Download APK sesuai HP di bawah (`app-arm64-v8a-release.apk` untuk kebanyakan HP modern, `app-armeabi-v7a-release.apk` untuk yang 32-bit lama). Buka di HP dan izinkan instalasi dari sumber tidak dikenal bila diminta. Minimum Android 8.0 (API 26).


UI/UX dan optimasi setelah review v3.0.0–v3.0.1. Tidak ada perubahan
format penyimpanan, jadi semua cadangan tetap kompatibel.

### Ditingkatkan
- **Design system bersama.** `AppKit` di `lib/widgets/kit.dart` mengkonsolidasikan
  spacing, radius, card, tombol, dan metrik card yang sebelumnya
  dicopy-paste antara layar. Tidak ada lagi angka ajaib berserak.
- **Home lebih rapi.** CTA "Misi Bosan" dan "Acak Sebebasnya" sekarang
  lebar penuh dengan warna yang membedakan; toggle Quick Wins dan Mode
  Chaos berbentuk bar konsisten.
- **Mission Sheet lebih bersih.** Header tombol 4x, judul/deskripsi
  tengah, dan grid outcomes yang terbaca di layar kecil & teks besar.
- **Stats & Achievements pakai metrik card yang sama**, dan Achievements
  sekarang pakai `SliverGrid` alih-alih `GridView(shrinkWrap: true)` yang
  lebih efisien.
- **History lookup O(1).** Resolusi judul/kategori riwayat sebelumnya
  memindai katalog (55 entri) per baris per build — sekarang pakai `Map`
  langsung.
- **Weekly Insights refresh saat hari berganti** melalui `context.watch`
  provider, bukan hanya saat ada penyelesaian baru.
- **Tidak ada spasi kosong mati** di bawah Home untuk pemain baru (gap
  pindah ke dalam WeeklyInsights).

### Diperbaiki
- **Toast "+0 XP" untuk misi yang dilewati** — sekarang bilang dengan
  jujur bahwa tidak ada XP dan streak tidak berubah.
- **Ketuk-ganda pada quest chain membayar dua kali** — langkah sekarang
  diklaim sebelum proses async, dengan guard in-flight.
- **Timer tengah malam tidak lagi menumpuk** setiap kali aplikasi
  dibuka kembali (tidak ada lagi N timer hidup setelah N resume).
- **ID tantangan harian dari cadangan divalidasi** — ID yang tidak ada
  dalam katalog build ini dibuang alih-alih diam-diam menimpa arc lain.
- **Riwayat di memori sekarang ikut mematuhi batas 1000 entri** seperti
  penyimpanan, jadi laporan "menampilkan N dari M" tidak lagi melanggar.
- **Filter riwayat dipindah ke modul murni** (`history_filter.dart`)
  dengan 16 test — sebelumnya method privat di widget yang mustahil
  diuji.

### Optimasi
- **Analyze bersih, 0 warning/error.** Semua perbaikan type dan tipe
  parameter dari review ulang v3.0.0 diterapkan.
- **174 test hijau** (termasuk 16 test baru history filter).

## v3.0.1

Self-review of everything shipped between v2.5.0 and v3.0.0, looking
only for defects introduced along the way.

### Bug fixes
- **Reporting a mission as "didn't do it" punished you twice.** It paid
  no XP and moved no streak, and then the roller treated it as a recent
  completion and hid that mission from you for seven days. Answering
  honestly now costs nothing but the XP.
- **A skipped mission popped a green "+0 XP" celebration** with an undo
  button, directly contradicting the outcome you had just chosen. It
  now says plainly that nothing was awarded and why.
- **Skipping a custom mission reported its full base XP as gained**, the
  exact opposite of what was recorded.
- **A partial completion could pay a phantom level-up bonus.** The
  boundary was judged against the full mission value even though only 60
  percent was paid out, so on a weekend a high-value mission could
  collect a level 20 bonus and still finish below level 20. The boundary
  is now judged against the amount actually awarded.
- **Double-tapping "complete step" on a quest chain paid twice.** The
  step was only marked done several awaits in, so a second tap slipped
  through and wrote a duplicate history row. The step is now claimed
  before any await, the way accepting a mission always has been.
- **Resuming the app leaked a midnight timer every time.** Each resume
  armed a fresh chain without cancelling the last, so N background and
  resume cycles meant N live timers and N redundant midnight writes.

### Optimizations
- **In-memory history now respects the same cap as storage.** The two
  used to drift: disk trimmed at the limit while memory grew forever, so
  the History screen reported a total the device did not hold and
  outcome numbers dropped after a restart.
- **Insights refresh when the day rolls over** instead of leaving
  yesterday's comparison on screen until the next completion.
- **Your "best hour" now ignores skipped attempts**, matching every
  other number on that screen. Previously a user whose only clustered
  activity was bailing out was told when they finish things.
- **History filter labels are type-checked.** They were resolved by
  matching `toString()` output against a `default:` branch, so renaming
  an enum member would have silently relabelled every chip with no build
  error.
- **The custom mission outcome sheet no longer clips** its third option
  on short screens or at large text scales.
- **New players no longer get a blank band** on Home. The insights hide
  themselves below five completions, but the spacing around them did
  not, leaving ~56pt of dead space on the first screen.
- **History filtering moved into a testable pure module.** It lived as
  private methods on a widget, which made it impossible to test at all.

## v3.0.0

Retention and honesty. The app now tells you what your own history
says about you, and stops showing stale numbers when the day turns over
while you are still holding the phone.

### New features
- **Weekly insights on Home.** Observations derived from your history:
  whether you are doing more or less than last week, the hour you
  actually finish things, the category you walk away from most, and your
  average XP per mission this week.
- **The insights refuse to guess.** No cards at all below five
  completions, no "best hour" unless the peak holds a quarter of your
  data, no week-over-week percentage when there is no previous week to
  compare against, and no "escape hatch" for a single isolated skip.
  Every one of those cases previously would have produced a confident
  number built on nothing.
- **Replay the intro from Profile.** Existing players can rewatch the
  walkthrough without it being marked unseen, so closing the app
  mid-replay cannot bring the startup gate back.
- **Named accents for screen readers.** The five colour swatches were
  five anonymous buttons with no label and no selected state.

### Optimizations
- **Home now rolls the day over by itself.** Leaving the app open past
  midnight kept yesterday's streak warning, reroll allowance, and daily
  challenge on screen until you backgrounded and resumed the app.
- **Insight calculations are pure functions** over the history list with
  an injected clock, so they are unit-testable without a provider, a
  widget tree, or a fake timer.

### Bug fixes
- **A quest chain this build no longer ships is no longer silently
  swapped for a different one.** An unknown chain id used to fall back
  to the first arc, quietly turning your mid-progress "Creator Arc"
  into "Touch Grass Arc". Unknown ids now return null, and a stored one
  is dropped on import.
- **A chain step belonging to a vanished arc completes safely** instead
  of paying out the wrong arc's reward.

## v2.8.0

Data you can trust. Every number the app shows now says what it
actually measures, and a backup restore no longer throws part of your
setup away.

### New features
- **Filter your history by date.** Today, 7 days, 30 days, or all time.
- **Filter your history by outcome.** Done, partly, skipped, or entries
  from before outcome tracking existed, which are labelled "No rating"
  rather than quietly counted as successes.
- **The history list states its own numbers**, showing how many entries
  are stored and how many you are looking at, and saying so out loud
  once the cap is reached.
- **Clean up favorites that point at missing missions.** They used to
  vanish from the list while still sitting in your saved data, with no
  way to see or remove them.

### Optimizations
- **A backup now carries your reminder settings.** Restoring on a new
  phone used to come back with reminders switched off and the time you
  had chosen thrown away. Backups written before this version have no
  reminder block and still clear the schedule, so a legacy restore never
  leaves a notification you cannot see.
- **Reminder times coming out of a backup are clamped** to a real hour
  and minute instead of being trusted blindly.
- **History keeps 1000 entries instead of 200.** The cap is now a named
  constant rather than a number buried in two places.

### Bug fixes
- **History dates now show the year** when it is not the current one, so
  a completion from last year cannot be read as today's.
- **"Avg XP / Day" is now "XP / Active Day".** The denominator was
  always days you were active, never calendar days, so the old label
  described a number the app never computed.

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
