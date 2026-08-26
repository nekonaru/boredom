import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import '../models/achievement.dart';
import '../models/daily_challenge.dart';
import '../models/quest_chain.dart';

/// Semua baca/tulis data lokal lewat sini.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const _kProgress = 'boredom_progress';
  static const _kHistory = 'boredom_history';
  static const _kAchievements = 'boredom_achievements';
  static const _kDailyChallenge = 'boredom_daily_challenge';
  static const _kQuestChain = 'boredom_quest_chain';

  Future<UserProgress> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProgress);
    if (raw == null) return const UserProgress();
    try {
      return UserProgress.fromJson(jsonDecode(raw));
    } catch (_) {
      return const UserProgress();
    }
  }

  Future<void> saveProgress(UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProgress, jsonEncode(progress.toJson()));
  }

  Future<List<CompletedMission>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kHistory) ?? [];
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
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kHistory) ?? [];
    raw.add(jsonEncode(entry.toJson()));
    // Simpan maksimal 200 entri biar prefs nggak membengkak.
    final trimmed = raw.length > 200 ? raw.sublist(raw.length - 200) : raw;
    await prefs.setStringList(_kHistory, trimmed);
  }

  Future<List<UnlockedAchievement>> loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kAchievements) ?? [];
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kAchievements,
      unlocked.map((a) => jsonEncode(a.toJson())).toList(),
    );
  }

  Future<DailyChallengeState?> loadDailyChallengeState() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kDailyChallenge);
    if (raw == null) return null;
    try {
      return DailyChallengeState.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveDailyChallengeState(DailyChallengeState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDailyChallenge, jsonEncode(state.toJson()));
  }

  Future<QuestChainProgress?> loadQuestChainProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kQuestChain);
    if (raw == null) return null;
    try {
      return QuestChainProgress.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveQuestChainProgress(QuestChainProgress? progress) async {
    final prefs = await SharedPreferences.getInstance();
    if (progress == null) {
      await prefs.remove(_kQuestChain);
    } else {
      await prefs.setString(_kQuestChain, jsonEncode(progress.toJson()));
    }
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kProgress);
    await prefs.remove(_kHistory);
    await prefs.remove(_kAchievements);
    await prefs.remove(_kDailyChallenge);
    await prefs.remove(_kQuestChain);
  }
}
