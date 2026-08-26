import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';

/// Semua baca/tulis data lokal (progress & riwayat misi) lewat sini.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const _kProgress = 'boredom_progress';
  static const _kHistory = 'boredom_history';

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

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kProgress);
    await prefs.remove(_kHistory);
  }
}
