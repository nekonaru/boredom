# Project Guide (General Prompt)

This file is the single source of truth for how a project is written, described,
documented, and released. It is written as a prompt: attach it at the start of
any session and follow it strictly. Keep it short, keep it consistent, and never
break the hard rules.

It is the long version of `rules.md`. It works together with `docs.md`, which defines the exact
README layout. See section 1 for how the two files connect.

## 0. Project variables

Fill these in once per project. Every rule below refers to these names.

| Variable | Meaning | Example |
|----------|---------|---------|
| `PROJECT_NAME` | Display name used in titles | `Boredom` |
| `REPO` | GitHub `owner/name` | `nekonaru/boredom` |
| `AUTHOR_NAME` | Full name for the Author section | `Nicolas Dwi Dharma` |
| `AUTHOR_GITHUB` | GitHub username (used for avatar and profile URLs) | `nekonaru` |
| `PROJECT_KIND` | `web` (website, web app, web API), `app` (installed mobile or desktop app, APK, binary) or `general` (CLI, library, SDK, script, bot, service). Decides the security toolkit and the release rules | `app` |
| `STACK` | Language and framework | `Flutter (Dart)` |
| `PLATFORMS` | Target platforms | `Android` |
| `MIN_OS` | Minimum OS version, or `n/a` | `Android 8.0 (API 26)` |
| `DEFAULT_BRANCH` | Main branch | `main` |
| `LICENSE` | License name | `MIT` |
| `UI_LANGUAGES` | Languages shipped in the product UI | `English, Bahasa Indonesia` |
| `VERIFICATION` | `ci-only` or `local-and-ci` | `ci-only` |

If a variable is unknown, ask. Do not guess.

## 1. Related files and precedence

| File | Role | Local or committed |
|------|------|--------------------|
| `rules.md` | Short hard rules that are always followed (read first) | Local only, never committed |
| `guide.md` | Full project guide with the reasons and details (this file) | Local only, never committed |
| `docs.md` | Defines README.md and README.id.md layout and generation steps | Local only, never committed |
| `reference.md` | Finished example README (the Swara README) that `docs.md` copies the layout from | Local only, never committed |
| `security-web.md` | Security toolkit when `PROJECT_KIND` is `web` | Local only, never committed |
| `security-app.md` | Security toolkit when `PROJECT_KIND` is `app` | Local only, never committed |
| `security-general.md` | Security toolkit when `PROJECT_KIND` is `general` (the default for anything else) | Local only, never committed |
| `SECURITY.md` | Public vulnerability reporting policy (libraries, tools, public repos) | Committed |
| `README.md`, `README.id.md` | Public documentation | Committed |
| `CHANGELOG.md`, `CHANGELOG.id.md` | Version history | Committed |

Precedence when two files disagree:

0. `rules.md` wins over everything, including this guide.
1. The hard rules in this file win: punctuation (section 2), language policy
   (section 3), push rules (section 9.1), local-only files (section 14),
   security gate (section 13.1).
2. For README layout (section order, tables, callouts, header, Author block),
   `docs.md` wins.
3. If neither covers it, follow the existing project files and ask before
   inventing a new convention.

### How rules feed the README generator

When generating or updating a README, take these facts from this file instead of
guessing:

| README part | Source in this file |
|-------------|---------------------|
| Title, Author section, avatar and profile URLs | Section 0 (`PROJECT_NAME`, `AUTHOR_NAME`, `AUTHOR_GITHUB`) |
| Tagline | Section 4 (repository description) |
| Badges: language/framework, platform, license | Section 0 (`STACK`, `PLATFORMS`, `LICENSE`) |
| Requirements table | Section 0 (`MIN_OS`) plus the real package and CI files |
| Installation, Option A (prebuilt download) | Section 7 (Install / Update text) and section 12 (artifacts) |
| Installation, Option B (build from source) | Section 11 (app vs web and general) and the stack profile |
| Display Language | Section 3 (`UI_LANGUAGES`) |
| Development | Section 16 (stack profile) |
| Security (optional README section) | Section 13.1 and the real `SECURITY_REPORT.md` |
| Testing | Section 13 (commands and what "clean" means) |
| Continuous Integration | Section 14 (CI rules) and the real workflow files |
| Release badge and version text | Section 10 (versioning) |

Never mention `guide.md`, `docs.md`, `reference.md` or the `security-*.md` toolkits in any committed file.

## 2. Punctuation (hard rule)

- **No em dash (U+2014) and no en dash (U+2013) anywhere.** Not in code,
  comments, docs, README, changelog, release notes, commit messages, or UI
  strings.
- Use a plain hyphen `-` for ranges, compound words, and release titles, or
  rewrite with a comma, colon, parentheses, or a period.
- Examples:
  - Bad: a long dash between "XP / Active Day" and "last 7 days"
  - Good: `XP / Active Day, last 7 days`
  - Good: `v3.2.0 - Freeze tokens`
- Existing plain spaced hyphens in old text are allowed. Do not add new ones
  where a comma or colon reads better.
- Before finishing any task, search all changed files for U+2014 and U+2013 and
  remove them.

## 3. Language policy

- English is the default for all code, comments, identifiers, commit messages,
  and the source version of every document.
- Indonesian (Bahasa Indonesia) is a translation, never the source. Add it for
  the README, the changelog, release notes, and the product UI when
  `UI_LANGUAGES` includes it.
- Code identifiers, commands, file paths, package names, and version numbers
  stay in English and identical in both languages.
- Use neutral "kamu" wording or impersonal phrasing in Indonesian, not slang.
- No emoji in documentation, README, changelog, or release notes.

## 4. Repository description

One sentence, English, action-oriented. Mention the stack in parentheses when
relevant and end with the concrete benefit or key trait (for example offline,
lightweight, no account).

Template:

> `<Verb>` `<what it does>` (`<STACK>`) with `<2 to 4 key capabilities>`. `<Key trait>`.

Example:

> Turn boredom into real-world missions (Flutter) with XP, levels, streaks,
> quest chains, and achievements. Fully offline.

Rules:
- Start with a verb ("Turn", "Build", "Ship").
- Keep it to one sentence plus an optional short trait sentence.
- No em or en dash.
- Reuse the same wording for the README tagline (shortened to two lines at most).

## 5. Repository topics

- Lowercase, hyphenated, sorted alphabetically.
- Add a topic only when the project genuinely covers it. Remove stale ones on
  major pivots.
- App projects include platform tags (`android`, `ios`, `desktop`).
- Non-app projects use language and ecosystem tags only (`dart`, `cli`,
  `library`), no platform tags unless the tool is platform-specific.

## 6. Bilingual README

Two files, always kept in sync:

- `README.md`: English, source of truth, default language.
- `README.id.md`: Bahasa Indonesia (dot before "id", not underscore).

Layout, section order, tables, callouts, header block, language switcher, and the
Author block are defined by `docs.md`. Do not duplicate that
layout here. Mandatory points that this file adds:

- Both files have the same sections in the same order, the same number of table
  rows, callouts, and `<details>` blocks.
- Translate prose only. Keep badges, code fences, commands, paths, and versions
  identical.
- When a feature, version, command, or CI workflow changes, update
  `README.md` first, then `README.id.md`, in the same commit.
- The README never claims a feature that is not in the code. Never invent
  features, versions, commands, URLs, badges, or policies.
- Table of Contents anchors in the Indonesian file match the Indonesian
  headings.

To create or restructure a README, run `docs.md` with this file and
`reference.md` attached. `reference.md` supplies the layout shapes only, never
the facts.

## 7. Release notes

Every GitHub Release uses this exact shape.

Title: `<PROJECT_NAME> vX.Y.Z - Short description`

Body (bilingual, English first, then Indonesian):

```markdown
# English

**<PROJECT_NAME> vX.Y.Z - Short description (EN)**

## New features

- **Bold lead-in.** One sentence explaining the feature.

## Optimizations

- **Bold lead-in.** One sentence.

## Bug fixes

- **Bold lead-in.** One sentence.

## Install / Update

Download the APK matching your device below (`app-arm64-v8a-release.apk` for
most modern phones, `app-armeabi-v7a-release.apk` for older 32-bit ones).
Open it on your phone and allow installs from unknown sources if asked.
Minimum <MIN_OS>.

<br>

---

<br>

# Bahasa Indonesia

**<PROJECT_NAME> vX.Y.Z - Short description (ID)**

## Fitur baru

- **Bold lead-in.** Satu kalimat.

## Optimisasi

- **Bold lead-in.** Satu kalimat.

## Perbaikan bug

- **Bold lead-in.** Satu kalimat.

## Instalasi / Update

Download APK sesuai HP di bawah (`app-arm64-v8a-release.apk` untuk kebanyakan
HP modern, `app-armeabi-v7a-release.apk` untuk yang 32-bit lama). Buka di HP
dan izinkan instalasi dari sumber tidak dikenal bila diminta. Minimum
<MIN_OS>.
```

Rules:
- Sections are per-point bullet lists, never paragraphs.
- Omit a section entirely if it has no items.
- App projects always include `## Install / Update` (or `## Instalasi / Update`).
  Non-app projects follow section 11.
- Separator between languages is exactly `<br>`, blank line, `---`, blank line,
  `<br>`.
- No em or en dash. Use `-` in the title.
- The install text must match the README Installation, Option A.

## 8. Changelog files

- `CHANGELOG.md` (English) and `CHANGELOG.id.md` (Bahasa Indonesia).
- Each version starts with `## vX.Y.Z` followed by the same sections as the
  release notes.
- Newest version on top.
- Keep in sync with release notes and with both README files.

## 9. Commit messages

- Format: `type: short description` (for example `feat: v4.1.0 preferred defaults`).
- Types:
  - `feat`: new feature or capability
  - `fix`: bug fix
  - `docs`: documentation only
  - `chore`: tooling, config, dependencies
  - `refactor`: code change that neither fixes a bug nor adds a feature
  - `test`: adding or fixing tests
  - `perf`: performance improvement
  - `style`: formatting only, no logic change
  - `revert`: revert a previous commit
- Scope is optional: `feat(profile): add defaults section`.
- English only. No em or en dash.
- One logical change per commit. Keep the subject under 72 characters.
- Body (optional) explains the "why", wrapped at 72 columns.

### 9.1 Push rules (mandatory)

- **Every change must be committed AND pushed to the remote repo.** No
  local-only work is considered done.
- Push after every commit, not at the end of the day. Each commit triggers CI.
- Never leave uncommitted changes in the working tree when a task is finished.
- Push both the branch and any new tags: `git push origin <branch>` and
  `git push origin <tag>`.
- If a push fails, fix the cause (rebase, resolve conflicts) and push again.
  Do not start the next task with a failed push.
- Verify the remote received the commit with
  `git log origin/<branch> --oneline -1`.
- Never commit the local-only files listed in section 14.

## 10. Versioning

- App projects: `MAJOR.MINOR.PATCH+BUILD` in the package manifest (for example
  `pubspec.yaml`).
- Non-app projects: `MAJOR.MINOR.PATCH` only, no build number.
- Any in-code version constant mirrors `MAJOR.MINOR.PATCH` (app only).
- Tag: `vX.Y.Z`. Release title: `<PROJECT_NAME> vX.Y.Z - Description`.
- Follow SemVer strictly: a breaking change is a major bump.
- The README release badge and any version text must match the latest release.

## 11. App projects vs web and general projects

### App projects (`PROJECT_KIND` is `app`: UI, APK, binary artifact)

- Release notes include the `## Install / Update` section with download
  instructions and the minimum OS.
- Attach built artifacts (APK, IPA, exe) to the GitHub Release.
- Mention platform requirements (`MIN_OS`).
- README Installation has Option A "Download the APK" (or equivalent) and
  Option B "Build from source".
- Topics include platform tags.

### Web and general projects (`PROJECT_KIND` is `web` or `general`: websites, CLI tools, libraries, SDKs, pure code)

- No `Install / Update` section. Replace it with `## Usage` or `## API`
  showing how to run or call it.
- No binary attachments unless a binary is published. Prefer package registry
  links (pub.dev, npm, PyPI, crates.io) or `go install` / `pip install`.
- README Installation uses a package manager or `git clone` plus build, with no
  "Download the APK".
- Release notes sections are `New features`, `Optimizations`, `Bug fixes`, then
  `Usage` or `Breaking changes` (if any) instead of Install.
- Add a `## Breaking changes` section when a release removes or renames a
  public API. List the old name, the new name, and a migration snippet.

## 12. Release artifacts

- App projects attach the built files to the GitHub Release. Name them
  predictably. For Android split builds: `app-arm64-v8a-release.apk` and
  `app-armeabi-v7a-release.apk`.
- Parse changelog sections by header in the release workflow so the Release body
  is generated from `CHANGELOG.md` and `CHANGELOG.id.md`.
- Tag a release only after CI is green on the branch commit.

## 13. Testing conventions

- Tests live in the stack's standard test folder (for example `test/`).
- The analyzer or linter must report zero issues, and the full test suite must
  pass before every push.
- Tests that touch storage reset it first (see the stack profile in section 16).
- If `VERIFICATION` is `ci-only`, CI is the only verification and no local SDK is
  assumed. Do not claim something works unless CI confirms it.
- The README Testing section lists the exact commands and what "clean" means.

### 13.1 Security gate (if web, if app, else general)

Pick the toolkit from `PROJECT_KIND`. Use exactly one as the primary toolkit.

| If `PROJECT_KIND` is | Use | Check IDs | Final files |
|----------------------|-----|-----------|-------------|
| `web` | `security-web.md` | 01 to 27, bonus B1 to B7 | `SECURITY_MAP.md`, `SECURITY_REVIEW.md`, `SECURITY_REPORT.md` |
| `app` | `security-app.md` | A01 to A18, bonus AB1 to AB4 | same three files |
| anything else | `security-general.md` | G01 to G16, bonus GB1 to GB4 | same three files |

Mixed projects (for example a service with a web dashboard, or an app with its
own backend): use the toolkit for each part and keep one combined
`SECURITY_REPORT.md`.

Rules:
- Run Prompt 00 first to create `SECURITY_MAP.md`, then the checks one per
  session, then the review check, then the test-and-report check.
- Fill in the toolkit's Project Context block from section 0 (`PROJECT_NAME`,
  `STACK`, `PLATFORMS`, `PROJECT_KIND`, hosting or distribution).
- Never paste real secret values into a chat. Use variable names.
- `SECURITY_MAP.md`, `SECURITY_REVIEW.md` and `SECURITY_REPORT.md` are local
  working files. Add them to `.gitignore` (section 14). Only `SECURITY.md` (the
  public reporting policy) is committed.
- Before every release run the "before every release" checks listed in the
  toolkit and make sure the security tests pass in CI (section 13).
- A Critical or High finding that is still open blocks a release unless I
  accept the risk in writing in the report.
- If a toolkit check does not apply (for example no backend), mark it N/A in the
  report with a reason. Never delete a check.
- Security fixes follow the same commit and push rules (section 9.1), with the
  `fix:` type and no secret values in messages.

## 14. Workflow / CI and local-only files

CI:
- CI runs on push to `DEFAULT_BRANCH` and on `v*` tags.
- Keep one workflow for build on every push and one for build plus draft release,
  or document what each does in the README CI table.

Local-only files (never commit):
- `guide.md`, `docs.md`, `reference.md`, `security-web.md`, `security-app.md`,
  `security-general.md`, `SECURITY_MAP.md`, `SECURITY_REVIEW.md`,
  `SECURITY_REPORT.md` and `rancangan.md` are local notes.
  They must NOT be pushed. List them in `.gitignore`.
- Do not reference them from code, README, changelog, or release notes.

## 15. General writing rules

- Short sentences. Active voice. No jargon where a plain word works.
- Bold the lead-in of each bullet so the list scans fast.
- Prefer concrete numbers over vague words ("55-mission catalog", not "many
  missions").
- Keep the project lightweight: avoid new dependencies or permissions when
  possible.
- Verify third-party APIs before use.
- No marketing fluff, no filler, no footer such as "Made by" when an Author
  section exists.

## 16. Stack profile: Flutter / Dart

Use this section when `STACK` is Flutter. For another stack, replace it with an
equivalent profile (naming, lints, strings, storage reset) and keep the rest of
the file unchanged.

Code style:
- Lints: `package:flutter_lints/flutter.yaml` plus project overrides.
- `prefer_single_quotes: true`: always single quotes for strings.
- `sort_child_properties_last: true`: `child` and `children` last in widget calls.
- File names `snake_case.dart`. Classes `PascalCase`. Variables and functions
  `camelCase`. Private members prefixed with `_`.
- One public class per file when practical; the file name matches the class.
- No unused imports or dead code (`flutter analyze` must report zero issues).

Localization (pick the project's approach and keep it consistent):
- ARB approach: add keys to `lib/l10n/app_en.arb` and `lib/l10n/app_id.arb`, run
  `flutter gen-l10n`, never edit generated files by hand.
- Manual approach: add EN and ID pairs to `lib/l10n/app_strings.dart` (English
  first) for every new user-facing string. No codegen. Catalog content uses
  `titleId` and `descriptionId` fields next to the English ones.
- Indonesian appears only in the UI strings. Comments and identifiers stay in
  English.

Testing:
- Every test that touches storage calls
  `SharedPreferences.setMockInitialValues({})` and clears the storage cache.
- Run `flutter analyze` and `flutter test` before pushing.

## 17. Definition of done

A task is finished only when all of these are true:

- Code compiles, analyzer reports zero issues, tests pass (section 13).
- No em dash or en dash in any changed file (section 2).
- New user-facing strings exist in every UI language (section 16).
- `README.md` and `README.id.md` updated together if features, versions,
  commands, or CI changed (section 6).
- `CHANGELOG.md` and `CHANGELOG.id.md` updated for any release (section 8).
- Version bumped consistently (section 10).
- Changes committed with a valid message and pushed, and the push verified
  (sections 9 and 9.1).
- The security gate in section 13.1 is done for the release: the toolkit that
  matches `PROJECT_KIND` was run, Critical and High findings are fixed, and
  security tests pass (section 13.1).
- No local-only file staged or referenced (section 14).
