import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import '../models/achievement.dart';
import '../models/daily_challenge.dart';
import '../models/quest_chain.dart';
import '../models/custom_mission.dart';
import '../models/saved_mission.dart';

/// All local reads/writes go through here.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const _kProgress = 'boredom_progress';
  static const _kHistory = 'boredom_history';
  static const _kAchievements = 'boredom_achievements';
  static const _kDailyChallenge = 'boredom_daily_challenge';
  static const _kQuestChain = 'boredom_quest_chain';
  static const _kCustomMissions = 'boredom_custom_missions';
  static const _kCustomCategories = 'boredom_custom_categories';
  static const _kFavorites = 'boredom_favorites';
  static const _kDisliked = 'boredom_disliked';
  static const _kHaptics = 'boredom_haptics';
  static const _kOnboarding = 'boredom_onboarding_done';
  static const _kSaved = 'boredom_saved';
  static const _kMuted = 'boredom_muted_categories';
  static const _kReminderEnabled = 'boredom_reminder_enabled';
  static const _kReminderHour = 'boredom_reminder_hour';
  static const _kReminderMinute = 'boredom_reminder_minute';

  SharedPreferences? _cache;

  /// Cached instance: SharedPreferences.getInstance() is async and does
  /// platform channel work, so calling it on every save is wasteful.
  Future<SharedPreferences> get prefs async =>
      _cache ??= await SharedPreferences.getInstance();

  /// Test-only: drops the cached instance so the next read picks up fresh
  /// mock values. Each test must call this after setMockInitialValues.
  void clearCache() {
    _cache = null;
  }

  Future<UserProgress> loadProgress() async {
    final p = await prefs;
    final raw = p.getString(_kProgress);
    if (raw == null) return const UserProgress();
    try {
      return UserProgress.fromJson(jsonDecode(raw));
    } catch (_) {
      return const UserProgress();
    }
  }

  Future<void> saveProgress(UserProgress progress) async {
    final p = await prefs;
    await p.setString(_kProgress, jsonEncode(progress.toJson()));
  }

  Future<List<CompletedMission>> loadHistory() async {
    final p = await prefs;
    final raw = p.getStringList(_kHistory) ?? [];
    return raw
        .map((e) {
          try {
            return CompletedMission.fromJson(jsonDecode(e));
          } catch (_) {
            return null;
          }
        })
        .whereType<CompletedMission>()
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  /// How many completion rows are kept on the device.
  ///
  /// Each row is roughly 200 bytes of JSON, so even 1000 stays well under
  /// a megabyte. The History screen states the cap and shows the lifetime
  /// total next to it, so a truncated list is never mistaken for the
  /// whole record.
  static const int kMaxHistoryEntries = 1000;

  Future<void> addHistoryEntry(CompletedMission entry) async {
    final p = await prefs;
    final raw = p.getStringList(_kHistory) ?? [];
    raw.add(jsonEncode(entry.toJson()));
    final trimmed = raw.length > kMaxHistoryEntries
        ? raw.sublist(raw.length - kMaxHistoryEntries)
        : raw;
    await p.setStringList(_kHistory, trimmed);
  }

  /// Replaces the whole history. Used by undo and backup import.
  ///
  /// Takes the in-memory list, which is newest-first. The prefs list is
  /// stored oldest-first (see [addHistoryEntry]), so this reverses and
  /// drops the *oldest* overflow entries. Keeping the order matters:
  /// `addHistoryEntry` appends and trims from the end, which is only
  /// correct while the list really is oldest-first.
  Future<void> saveHistory(List<CompletedMission> history) async {
    final p = await prefs;
    final oldestFirst = history.reversed.toList();
    final trimmed = oldestFirst.length > kMaxHistoryEntries
        ? oldestFirst.sublist(oldestFirst.length - kMaxHistoryEntries)
        : oldestFirst;
    await p.setStringList(
      _kHistory,
      trimmed.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  /// Removes the most recent history entry. Kept for callers that trim
  /// history by one without a full snapshot.
  Future<void> removeLastHistoryEntry() async {
    final p = await prefs;
    final raw = p.getStringList(_kHistory) ?? [];
    if (raw.isNotEmpty) {
      raw.removeLast();
      await p.setStringList(_kHistory, raw);
    }
  }

  Future<List<UnlockedAchievement>> loadAchievements() async {
    final p = await prefs;
    final raw = p.getStringList(_kAchievements) ?? [];
    return raw
        .map((e) {
          try {
            return UnlockedAchievement.fromJson(jsonDecode(e));
          } catch (_) {
            return null;
          }
        })
        .whereType<UnlockedAchievement>()
        .toList();
  }

  Future<void> saveAchievements(List<UnlockedAchievement> unlocked) async {
    final p = await prefs;
    await p.setStringList(
      _kAchievements,
      unlocked.map((a) => jsonEncode(a.toJson())).toList(),
    );
  }

  Future<DailyChallengeState?> loadDailyChallengeState() async {
    final p = await prefs;
    final raw = p.getString(_kDailyChallenge);
    if (raw == null) return null;
    try {
      return DailyChallengeState.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  /// Pass null to clear the stored challenge. Without this, an import that
  /// carries no daily challenge left yesterday's value on disk and it
  /// reappeared on the next launch.
  Future<void> saveDailyChallengeState(DailyChallengeState? state) async {
    final p = await prefs;
    if (state == null) {
      await p.remove(_kDailyChallenge);
    } else {
      await p.setString(_kDailyChallenge, jsonEncode(state.toJson()));
    }
  }

  Future<QuestChainProgress?> loadQuestChainProgress() async {
    final p = await prefs;
    final raw = p.getString(_kQuestChain);
    if (raw == null) return null;
    try {
      return QuestChainProgress.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveQuestChainProgress(QuestChainProgress? progress) async {
    final p = await prefs;
    if (progress == null) {
      await p.remove(_kQuestChain);
    } else {
      await p.setString(_kQuestChain, jsonEncode(progress.toJson()));
    }
  }

  Future<List<CustomMission>> loadCustomMissions() async {
    final p = await prefs;
    final raw = p.getStringList(_kCustomMissions) ?? [];
    return raw
        .map((e) {
          try {
            return CustomMission.fromJson(jsonDecode(e));
          } catch (_) {
            return null;
          }
        })
        .whereType<CustomMission>()
        .toList();
  }

  Future<void> saveCustomMissions(List<CustomMission> missions) async {
    final p = await prefs;
    await p.setStringList(
      _kCustomMissions,
      missions.map((m) => jsonEncode(m.toJson())).toList(),
    );
  }

  Future<List<CustomCategory>> loadCustomCategories() async {
    final p = await prefs;
    final raw = p.getStringList(_kCustomCategories) ?? [];
    return raw
        .map((e) {
          try {
            return CustomCategory.fromJson(jsonDecode(e));
          } catch (_) {
            return null;
          }
        })
        .whereType<CustomCategory>()
        .toList();
  }

  Future<void> saveCustomCategories(List<CustomCategory> categories) async {
    final p = await prefs;
    await p.setStringList(
      _kCustomCategories,
      categories.map((c) => jsonEncode(c.toJson())).toList(),
    );
  }

  Future<Set<String>> loadFavorites() async {
    final p = await prefs;
    return (p.getStringList(_kFavorites) ?? []).toSet();
  }

  Future<void> saveFavorites(Set<String> ids) async {
    final p = await prefs;
    await p.setStringList(_kFavorites, ids.toList());
  }

  Future<Set<String>> loadDisliked() async {
    final p = await prefs;
    return (p.getStringList(_kDisliked) ?? []).toSet();
  }

  Future<void> saveDisliked(Set<String> ids) async {
    final p = await prefs;
    await p.setStringList(_kDisliked, ids.toList());
  }

  Future<bool> loadHapticsEnabled() async {
    final p = await prefs;
    return p.getBool(_kHaptics) ?? true;
  }

  Future<void> saveHapticsEnabled(bool value) async {
    final p = await prefs;
    await p.setBool(_kHaptics, value);
  }

  Future<bool> isOnboardingDone() async {
    final p = await prefs;
    return p.getBool(_kOnboarding) ?? false;
  }

  Future<void> setOnboardingDone(bool done) async {
    final p = await prefs;
    await p.setBool(_kOnboarding, done);
  }

  // ---------------- Inbox, muted categories, reminders ----------------

  Future<List<SavedMission>> loadSavedMissions() async {
    final p = await prefs;
    final raw = p.getStringList(_kSaved) ?? [];
    return raw
        .map((e) {
          try {
            return SavedMission.fromJson(jsonDecode(e));
          } catch (_) {
            return null;
          }
        })
        .whereType<SavedMission>()
        .toList();
  }

  Future<void> saveSavedMissions(List<SavedMission> missions) async {
    final p = await prefs;
    await p.setStringList(
      _kSaved,
      missions.map((m) => jsonEncode(m.toJson())).toList(),
    );
  }

  Future<Set<String>> loadMutedCategories() async {
    final p = await prefs;
    return (p.getStringList(_kMuted) ?? []).toSet();
  }

  Future<void> saveMutedCategories(Set<String> names) async {
    final p = await prefs;
    await p.setStringList(_kMuted, names.toList());
  }

  Future<bool> loadReminderEnabled() async {
    final p = await prefs;
    return p.getBool(_kReminderEnabled) ?? false;
  }

  Future<int> loadReminderHour() async {
    final p = await prefs;
    return p.getInt(_kReminderHour) ?? 19;
  }

  Future<int> loadReminderMinute() async {
    final p = await prefs;
    return p.getInt(_kReminderMinute) ?? 0;
  }

  Future<void> saveReminder({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    final p = await prefs;
    await p.setBool(_kReminderEnabled, enabled);
    await p.setInt(_kReminderHour, hour);
    await p.setInt(_kReminderMinute, minute);
  }

  Future<void> resetAll() async {
    final p = await prefs;
    await p.remove(_kProgress);
    await p.remove(_kHistory);
    await p.remove(_kAchievements);
    await p.remove(_kDailyChallenge);
    await p.remove(_kQuestChain);
  }
}
