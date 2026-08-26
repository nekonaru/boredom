import 'package:flutter/foundation.dart';
import '../models/mission.dart';
import '../models/user_progress.dart';
import '../services/mission_service.dart';
import '../services/storage_service.dart';

const int kMaxRerollsPerDay = 3;

class BoredomProvider extends ChangeNotifier {
  Mood selectedMood = Mood.normal;
  TimeBudget selectedTime = TimeBudget.thirtyMin;
  LocationType selectedLocation = LocationType.anywhere;
  EnergyLevel selectedEnergy = EnergyLevel.medium;
  bool chaosMode = false;

  MissionInstance? currentMission;
  int _missionCounter = 0;

  UserProgress progress = const UserProgress();
  List<CompletedMission> history = [];

  bool _loaded = false;
  bool get loaded => _loaded;

  int? lastXpGained;

  Future<void> init() async {
    progress = await StorageService.instance.loadProgress();
    history = await StorageService.instance.loadHistory();
    _missionCounter = history.length;
    progress = _resetRerollsIfNewDay(progress);
    await StorageService.instance.saveProgress(progress);
    _loaded = true;
    notifyListeners();
  }

  UserProgress _resetRerollsIfNewDay(UserProgress p) {
    final now = DateTime.now();
    final reset = p.rerollResetDate;
    if (reset == null || !_isSameDay(reset, now)) {
      return p.copyWith(rerollsUsedToday: 0, rerollResetDate: now);
    }
    return p;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int get rerollsLeft =>
      (kMaxRerollsPerDay - progress.rerollsUsedToday).clamp(0, kMaxRerollsPerDay);

  void setMood(Mood mood) {
    selectedMood = mood;
    notifyListeners();
  }

  void setTime(TimeBudget time) {
    selectedTime = time;
    notifyListeners();
  }

  void setLocation(LocationType location) {
    selectedLocation = location;
    notifyListeners();
  }

  void setEnergy(EnergyLevel energy) {
    selectedEnergy = energy;
    notifyListeners();
  }

  void setChaosMode(bool value) {
    chaosMode = value;
    notifyListeners();
  }

  /// Klik tombol "I'M BORED".
  void rollMission() {
    final filter = MissionFilter(
      mood: selectedMood,
      timeBudget: selectedTime,
      location: selectedLocation,
      energy: selectedEnergy,
    );
    final mission = MissionService.generate(filter, chaosMode: chaosMode);
    _missionCounter++;
    currentMission = MissionInstance(mission: mission, missionNumber: _missionCounter);
    notifyListeners();
  }

  /// true kalau reroll berhasil, false kalau reroll harian sudah habis.
  bool rerollMission() {
    if (rerollsLeft <= 0) return false;
    progress = progress.copyWith(rerollsUsedToday: progress.rerollsUsedToday + 1);
    StorageService.instance.saveProgress(progress);
    rollMission();
    return true;
  }

  void dismissMission() {
    currentMission = null;
    notifyListeners();
  }

  Future<void> completeMission() async {
    final instance = currentMission;
    if (instance == null) return;
    final mission = instance.mission;

    final now = DateTime.now();
    int newStreak = progress.streakDays;
    final last = progress.lastCompletedDate;
    if (last == null) {
      newStreak = 1;
    } else if (_isSameDay(last, now)) {
      newStreak = progress.streakDays == 0 ? 1 : progress.streakDays;
    } else if (_isYesterday(last, now)) {
      newStreak = progress.streakDays + 1;
    } else {
      newStreak = 1;
    }

    progress = progress.copyWith(
      totalXp: progress.totalXp + mission.baseXp,
      streakDays: newStreak,
      lastCompletedDate: now,
      totalMissionsCompleted: progress.totalMissionsCompleted + 1,
    );
    lastXpGained = mission.baseXp;

    final entry = CompletedMission(
      missionId: mission.id,
      title: mission.title,
      emoji: mission.emoji,
      categoryLabel: mission.category.label,
      xpEarned: mission.baseXp,
      completedAt: now,
    );
    history.insert(0, entry);

    await StorageService.instance.saveProgress(progress);
    await StorageService.instance.addHistoryEntry(entry);

    currentMission = null;
    notifyListeners();
  }

  bool _isYesterday(DateTime last, DateTime now) {
    final yesterday = now.subtract(const Duration(days: 1));
    return _isSameDay(last, yesterday);
  }

  Future<void> resetProgress() async {
    await StorageService.instance.resetAll();
    progress = const UserProgress();
    history = [];
    _missionCounter = 0;
    currentMission = null;
    notifyListeners();
  }
}
