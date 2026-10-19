<div align="center">

# 🎲 Boredom: Turn Boredom Into Missions

**Tap one button, get one real-world mission, earn XP, level up. A tiny game for everyday life, fully offline.**

![Flutter](https://img.shields.io/badge/Flutter-3.35-02569B?style=flat-square&logo=flutter&logoColor=white)
![Release](https://img.shields.io/github/v/release/nekonaru/boredom?style=flat-square&color=blue)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white)
![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)
![CI](https://github.com/nekonaru/boredom/actions/workflows/build-apk.yml/badge.svg)

</div>

**English** | [Bahasa Indonesia](README.id.md)

## ✨ About

**Boredom** is a tiny Flutter game for everyday life, not a productivity app. Pick your **mood**, **free time**, **location**, and **energy**, tap **I'M BORED**, and get one concrete mission you can do right now (never generic advice). **Accept** it for XP, or **reroll** (3x per day) when it does not fit. XP levels you up through absurd titles, from "Bored" to "The Final Boss of Boredom".

There is also **Chaos Mode**, which ignores every filter so anything can come out.

> _"You are bored. So... what now?"_

## 🎯 Features

| Feature | Description |
|---------|-------------|
| 🎲 **Mission generator** | Random mission from a 55-mission catalog, matched to mood, time, location, and energy, weighted toward least-played categories, with seasonal missions and smart fallback so you always get one |
| ☢️ **Chaos Mode** | Ignores all filters, unlocks chaos-only missions |
| ✅ **Accept / reroll** | Accept missions for XP, reroll up to 3x per day |
| 🎚️ **Outcome tracking** | Say whether you actually did it: done, partly, or skipped. Partial pays 60 percent, skipped pays nothing and never advances your streak |
| 📊 **Follow-through stat** | The share of tracked missions you really carried out, with a dash until you have data |
| ⭐ **XP and levels** | Progressive curve with absurd level titles, double XP every weekend |
| 🔥 **Streaks** | Daily streak plus longest streak, with a 1-day grace period, freeze tokens, and an at-risk warning |
| 📜 **Quest chains** | 4 multi-step arcs ("Touch Grass Arc", "Creator Arc", "Reset Arc", "Deep Work Arc") with a big final reward |
| 🏆 **Achievements** | 29 achievements, progress-based and event-based (like "Night Owl") |
| 📅 **Daily challenge** | One special challenge per day, same for everyone on the same date, big XP reward |
| ⭐ **Custom missions** | Create your own missions with your own XP rewards |
| ❤️ **Favorites** | Pin catalog missions to find them again fast |
| 🔍 **History search** | Filter completed missions by title or category, then narrow by date (today, 7 days, 30 days, all) and by outcome |
| 🧹 **Data transparency** | History states how many entries are stored and how many you are viewing, dates show the year when it differs, and orphaned favorites can be cleaned up |
| ↩️ **Undo** | 5-minute window to restore the last completion |
| 💾 **Backup and restore** | Export all local data as text, import it back (phone-switch friendly, no account needed) |
| 📊 **Statistics** | Last-7-days and last-30-days charts drawn dependency-free, average XP per active day, busiest weekday, per-category distribution, reroll and chaos totals |
| 👎 **Dislikes** | Downvote missions so the generator stops rolling them |
| 🔔 **Daily reminder** | One notification a day at the time you choose, off by default |
| 🌍 **English and Indonesian UI** | English by default, switch to Bahasa Indonesia in Profile |
| 🎨 **Light and dark themes** | Dark by default, light mode plus 5 accent colors in Profile |
| 📳 **Haptic feedback** | Tiny vibration on taps and completions, toggleable |
| 📤 **Share card** | Render any mission into a 1080x1080 PNG card, or copy it as text |
| 📥 **Inbox** | Save missions for later and roll them when you are ready |
| ⚡ **Quick wins** | Narrow rolls to missions of 15 minutes or less |
| 🙈 **Mute categories** | Silence a whole category when you are not interested |
| 📊 **Weekly recap** | Missions, XP, and streak visible straight on Home |
| 🎁 **Milestone bonus** | Extra XP every time you cross a 10-level boundary |
| ↩️ **Full undo** | 5-minute undo for missions, daily challenges, chain steps, and custom missions |

## 📦 Requirements

- **Flutter** 3.47 or newer (stable channel)
- **JDK** 17
- **Android SDK** (API 34+)
- An Android phone or emulator (minimum Android 8.0 / API 26)

### Never used a terminal? Start here

<details>
<summary><b>How to open a terminal on Windows</b></summary>

1. Press the **Windows** key, type `PowerShell`, then press **Enter**
2. A blue window opens. That is where you type commands
3. Every `flutter ...` or `git ...` command in this guide is typed in that window, followed by **Enter**

</details>

## 🚀 Installation

### Option A: Download the APK (easiest)

1. Open the [Releases](https://github.com/nekonaru/boredom/releases) page
2. Download the APK matching your device (`app-arm64-v8a-release.apk` for most modern phones, `app-armeabi-v7a-release.apk` for older 32-bit ones)
3. Open it on your phone, allow installs from unknown sources if asked

### Option B: Build from source (for development / to read or change the code)

**1. Get the project code**

<details>
<summary><b>I have Git installed</b></summary>

```bash
git clone https://github.com/nekonaru/boredom.git
cd boredom
```

</details>

<details>
<summary><b>I don't have Git</b></summary>

1. Open the repository page on GitHub
2. Click the green **`Code`** button, choose **`Download ZIP`**
3. Extract the ZIP to a folder of your choice
4. In the terminal, go into the extracted folder, for example:

```bash
cd Downloads/boredom-main
```

</details>

**2. Install dependencies and verify**

```bash
flutter pub get
flutter analyze
flutter test
```

`flutter analyze` must report **No issues found** and all tests must pass.

**3. Build the APK**

```bash
flutter build apk --release --split-per-abi
```

The results are at `build/app/outputs/flutter-apk/` (`app-arm64-v8a-release.apk` and friends).

## 🖥️ Usage

**First launch:**
1. Pick your mood, free time, location, and energy
2. Tap **I'M BORED**
3. Accept the mission and do it, or reroll (3x per day)

**Everyday use:**
- Open **Missions** for quest chains, your custom missions, favorites, and searchable history
- Check the **Daily Challenge** on Home for bonus XP
- Watch your **Stats** for the weekly chart and category breakdown
- Switch language or back up your data from **Profile**

## 🌍 Display Language

The app UI (menus, buttons, messages, and settings) is available in **English** (default) and **Bahasa Indonesia**.

1. Open **Profile**
2. Under **Language**, pick **English** or **Bahasa Indonesia**
3. The choice is remembered between sessions

## 🗂️ Project Structure

```
boredom/
├── lib/
│   ├── main.dart                 # entry point, providers, MaterialApp + locale
│   ├── l10n/
│   │   └── app_strings.dart      # English (source of truth) + Indonesian tables
│   ├── models/                   # Mission, UserProgress, Achievement, DailyChallenge,
│   │                             # QuestChain, CustomMission
│   ├── providers/                # BoredomProvider (game state), LanguageProvider
│   │                             # ThemeProvider (dark/light, accent)
│   ├── screens/                  # Home, Missions, Stats, Achievements, Profile, shell
│   │                             # onboarding (first-run walkthrough)
│   ├── services/                 # catalogs, generator, local storage,
│   │                             # reminders, share card
│   ├── utils/                    # theme, lightweight date formatting
│   └── widgets/                  # selector chips, mission sheet, XP bar, charts,
│                                 # weekly summary, inbox, ...
├── test/
│   ├── widget_test.dart          # app boots, onboarding on fresh installs
│   ├── user_progress_test.dart   # level curve
│   ├── mission_service_test.dart # generator fallback, filters, exclusions
│   ├── localization_test.dart    # string coverage, catalog sanity
│   ├── onboarding_test.dart      # onboarding flag persists
│   ├── stats_theme_test.dart     # monthly stats, palettes, weekday names
│   ├── events_test.dart          # weekend XP, seasonal rolls, weighting
│   └── v24_test.dart             # muted categories, milestone XP, recap
├── android_res_extra/            # launcher icon + splash drawn into the APK by CI
├── .github/
│   └── workflows/
│       ├── build-apk.yml         # CI: analyze + build APK on push to main/master
│       └── release.yml           # release: test + split APKs attached to each v* tag
├── pubspec.yaml
├── CHANGELOG.md                  # changelog (English)
├── CHANGELOG.id.md               # changelog (Bahasa Indonesia)
├── LICENSE
├── README.md                     # main documentation (English)
└── README.id.md                  # documentation (Bahasa Indonesia)
```

**Adding a new user-facing string:**
1. Add the EN/ID pair to `lib/l10n/app_strings.dart` (English first)
2. If it is catalog content (mission, achievement, challenge, chain step), add the `titleId`/`descriptionId` fields next to the English ones
3. Use it via `context.str.yourKey` or `localizedTitle(en: ..., id: ..., code: ...)`
4. No codegen step needed (`flutter gen-l10n` is intentionally not used, to keep the build light)

## 🧪 Testing

Unit and widget tests cover the level curve, the mission generator, and localization:

```bash
flutter test
```

Static verification before every push:

```bash
flutter analyze
```

It must report **No issues found** (zero errors, zero warnings).

## ❓ FAQ

<details>
<summary><b>Is my data sent anywhere?</b></summary>

No. Everything (XP, level, streak, history, achievements, custom missions, favorites) is stored locally with SharedPreferences. Backup works by copying text, never by uploading.

</details>

<details>
<summary><b>I switched phones. How do I move my progress?</b></summary>

Open **Profile**, tap **Export data**, save the copied text somewhere safe. On the new phone, open **Profile**, tap **Import data**, paste the text.

</details>

<details>
<summary><b>The same missions keep coming out?</b></summary>

Rolls skip missions completed in the last 7 days when alternatives exist. If everything was recently completed, the generator falls back gracefully instead of showing nothing.

</details>

<details>
<summary><b>How do I change the language?</b></summary>

Profile, section **Language**, pick English or Bahasa Indonesia. English is the default.

</details>

## 👤 Author

<div align="center">

| [![Nicolas Dwi Dharma](https://github.com/github.png?size=100)](https://github.com/nekonaru) |
|:---:|
| **Nicolas Dwi Dharma** |
| [github.com/nekonaru](https://github.com/nekonaru) |

</div>

## 📄 License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for more information.

<div align="center">

Made by **Nicolas Dwi Dharma**

*Star this repo if this project helps you!*

</div>
