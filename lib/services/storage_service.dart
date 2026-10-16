import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import '../models/achievement.dart';
import '../models/daily_challenge.dart';
import '../models/quest_chain.dart';
import '../models/custom_mission.dart';

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
  static const _kFavorites = 'boredom_favorites';

  SharedPreferences? _cache;

  /// Cached instance: SharedPreferences.getInstance() is async and does
  /// platform channel work, so calling it on every save is wasteful.
  Future<SharedPreferences> get prefs async =>
      _cache ??= await SharedPreferences.getInstance();

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

  Future<void> addHistoryEntry(CompletedMission entry) async {
    final p = await prefs;
    final raw = p.getStringList(_kHistory) ?? [];
    raw.add(jsonEncode(entry.toJson()));
    // Keep at most 200 entries so prefs never bloat.
    final trimmed = raw.length > 200 ? raw.sublist(raw.length - 200) : raw;
    await p.setStringList(_kHistory, trimmed);
  }

  /// Removes the most recent history entry. Used by undo.
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

  Future<void> saveDailyChallengeState(DailyChallengeState state) async {
    final p = await prefs;
    await p.setString(_kDailyChallenge, jsonEncode(state.toJson()));
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

  Future<Set<String>> loadFavorites() async {
    final p = await prefs;
    return (p.getStringList(_kFavorites) ?? []).toSet();
  }

  Future<void> saveFavorites(Set<String> ids) async {
    final p = await prefs;
    await p.setStringList(_kFavorites, ids.toList());
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
