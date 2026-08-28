import 'package:flutter/foundation.dart';
import '../models/mission.dart';
import '../models/user_progress.dart';
import '../models/achievement.dart';
import '../models/daily_challenge.dart';
import '../models/quest_chain.dart';
import '../services/mission_service.dart';
import '../services/storage_service.dart';
import '../services/achievement_catalog.dart';
import '../services/daily_challenge_catalog.dart';
import '../services/quest_chain_catalog.dart';

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
  List<UnlockedAchievement> achievements = [];
  DailyChallengeState? dailyChallengeState;
  QuestChainProgress? questChainProgress;

  bool _loaded = false;
  bool get loaded => _loaded;

  int? lastXpGained;
  List<Achievement> lastUnlockedAchievements = [];

  Future<void> init() async {
    progress = await StorageService.instance.loadProgress();
    history = await StorageService.instance.loadHistory();
    achievements = await StorageService.instance.loadAchievements();
    questChainProgress = await StorageService.instance.loadQuestChainProgress();
    _missionCounter = history.length;

    final now = DateTime.now();
    progress = _resetRerollsIfNewDay(progress, now);
    progress = _handleAppOpen(progress, now);

    final storedChallenge = await StorageService.instance.loadDailyChallengeState();
    if (storedChallenge == null || !_isSameDay(storedChallenge.date, now)) {
      final challenge = DailyChallengeCatalog.forDate(now);
      dailyChallengeState =
          DailyChallengeState(date: now, challengeId: challenge.id, completed: false);
      await StorageService.instance.saveDailyChallengeState(dailyChallengeState!);
    } else {
      dailyChallengeState = storedChallenge;
    }

    await StorageService.instance.saveProgress(progress);
    _loaded = true;
    notifyListeners();
  }

  UserProgress _resetRerollsIfNewDay(UserProgress p, DateTime now) {
    final reset = p.rerollResetDate;
    if (reset == null || !_isSameDay(reset, now)) {
      return p.copyWith(rerollsUsedToday: 0, rerollResetDate: now);
    }
    return p;
  }

  UserProgress _handleAppOpen(UserProgress p, DateTime now) {
    final resetDate = p.appOpensResetDate;
    if (resetDate == null || !_isSameDay(resetDate, now)) {
      return p.copyWith(appOpensToday: 1, appOpensResetDate: now);
    }
    return p.copyWith(appOpensToday: p.appOpensToday + 1);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isYesterday(DateTime last, DateTime now) {
    final yesterday = now.subtract(const Duration(days: 1));
    return _isSameDay(last, yesterday);
  }

  int get rerollsLeft =>
      (kMaxRerollsPerDay - progress.rerollsUsedToday).clamp(0, kMaxRerollsPerDay);

  // ---------------- Selectors ----------------

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

  // ---------------- Mission flow ----------------

  void rollMission() {
    final filter = MissionFilter(
      mood: selectedMood,
      timeBudget: selectedTime,
      location: selectedLocation,
      energy: selectedEnergy,
    );
    final mission = MissionService.generate(filter, chaosMode: chaosMode);
    _missionCounter++;
    currentMission = MissionInstance(
      mission: mission,
      missionNumber: _missionCounter,
      isChaos: chaosMode,
    );
    notifyListeners();
  }

  /// true kalau reroll berhasil, false kalau reroll harian sudah habis.
  bool rerollMission() {
    if (rerollsLeft <= 0) return false;
    progress = progress.copyWith(
      rerollsUsedToday: progress.rerollsUsedToday + 1,
      totalRerollsAllTime: progress.totalRerollsAllTime + 1,
    );
    StorageService.instance.saveProgress(progress);
    rollMission();
    return true;
  }

  void dismissMission() {
    currentMission = null;
    notifyListeners();
  }

  Future<List<Achievement>> completeMission() async {
    final instance = currentMission;
    if (instance == null) return [];

    // Langsung null-in currentMission SEBELUM proses async apapun (bukan di
    // akhir function). Ini mencegah tap ganda/spam: kalau ACCEPT ke-tap 2x
    // cepat sebelum await pertama selesai, tap kedua bakal lolos ke sini
    // juga - tapi karena currentMission udah null duluan, panggilan
    // completeMission() yang KEDUA (dari tap kedua) akan langsung kena guard
    // di atas dan return [] tanpa dobel XP.
    currentMission = null;
    notifyListeners();

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

    final newCategoryCounts = Map<String, int>.from(progress.categoryCounts);
    final catKey = mission.category.name;
    newCategoryCounts[catKey] = (newCategoryCounts[catKey] ?? 0) + 1;

    progress = progress.copyWith(
      totalXp: progress.totalXp + mission.baseXp,
      streakDays: newStreak,
      longestStreak: newStreak > progress.longestStreak ? newStreak : progress.longestStreak,
      lastCompletedDate: now,
      totalMissionsCompleted: progress.totalMissionsCompleted + 1,
      chaosMissionsCompleted:
          progress.chaosMissionsCompleted + (instance.isChaos ? 1 : 0),
      categoryCounts: newCategoryCounts,
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

    final newlyUnlocked = <Achievement>[];

    // Night owl - event-based, dicek langsung dari jam sekarang.
    if ((now.hour >= 23 || now.hour < 4) &&
        !achievements.any((a) => a.achievementId == 'night_owl')) {
      achievements.add(UnlockedAchievement(achievementId: 'night_owl', unlockedAt: now));
      newlyUnlocked.add(AchievementCatalog.byId('night_owl'));
    }

    newlyUnlocked.addAll(_evaluateThresholdAchievements(now));
    if (newlyUnlocked.isNotEmpty) {
      await StorageService.instance.saveAchievements(achievements);
    }
    lastUnlockedAchievements = newlyUnlocked;

    notifyListeners();
    return newlyUnlocked;
  }

  List<Achievement> _evaluateThresholdAchievements(DateTime now) {
    final unlockedIds = achievements.map((a) => a.achievementId).toSet();
    final newly = <Achievement>[];
    for (final ach in AchievementCatalog.all) {
      if (ach.metric == AchievementMetric.special) continue;
      if (unlockedIds.contains(ach.id)) continue;
      if (_metricValue(ach) >= ach.target) {
        achievements.add(UnlockedAchievement(achievementId: ach.id, unlockedAt: now));
        newly.add(ach);
      }
    }
    return newly;
  }

  int _metricValue(Achievement ach) {
    switch (ach.metric) {
      case AchievementMetric.totalMissions:
        return progress.totalMissionsCompleted;
      case AchievementMetric.streak:
        return progress.longestStreak;
      case AchievementMetric.level:
        return progress.level;
      case AchievementMetric.chaosMissions:
        return progress.chaosMissionsCompleted;
      case AchievementMetric.rerollsAllTime:
        return progress.totalRerollsAllTime;
      case AchievementMetric.appOpensSingleDay:
        return progress.appOpensToday;
      case AchievementMetric.questChainsCompleted:
        return progress.questChainsCompleted;
      case AchievementMetric.categoryCount:
        return progress.categoryCounts[ach.category?.name] ?? 0;
      case AchievementMetric.special:
        return 0;
    }
  }

  void clearLastXpGained() {
    lastXpGained = null;
  }

  void clearLastUnlockedAchievements() {
    lastUnlockedAchievements = [];
  }

  // ---------------- Daily challenge ----------------

  bool get hasDailyChallenge => dailyChallengeState != null;

  DailyChallenge? get currentDailyChallenge =>
      dailyChallengeState == null ? null : DailyChallengeCatalog.byId(dailyChallengeState!.challengeId);

  bool get dailyChallengeCompleted => dailyChallengeState?.completed ?? false;

  Future<void> completeDailyChallenge() async {
    if (dailyChallengeState == null || dailyChallengeState!.completed) return;
    final challenge = currentDailyChallenge!;
    dailyChallengeState = dailyChallengeState!.copyWith(completed: true);
    await StorageService.instance.saveDailyChallengeState(dailyChallengeState!);

    progress = progress.copyWith(totalXp: progress.totalXp + challenge.rewardXp);
    await StorageService.instance.saveProgress(progress);
    lastXpGained = challenge.rewardXp;

    notifyListeners();
  }

  // ---------------- Quest chains ----------------

  List<QuestChain> get availableChains => QuestChainCatalog.all;

  QuestChain? get currentChain =>
      questChainProgress == null ? null : QuestChainCatalog.byId(questChainProgress!.chainId);

  int get currentChainStepIndex => questChainProgress?.currentStepIndex ?? 0;

  Future<void> startChain(String chainId) async {
    questChainProgress = QuestChainProgress(chainId: chainId, currentStepIndex: 0);
    await StorageService.instance.saveQuestChainProgress(questChainProgress);
    notifyListeners();
  }

  Future<void> abandonChain() async {
    questChainProgress = null;
    await StorageService.instance.saveQuestChainProgress(null);
    notifyListeners();
  }

  /// Return achievement baru (misalnya Quest Master) kalau chain barusan tuntas.
  Future<List<Achievement>> completeCurrentChainStep() async {
    final qp = questChainProgress;
    if (qp == null) return [];
    final chain = QuestChainCatalog.byId(qp.chainId);
    final nextIndex = qp.currentStepIndex + 1;

    if (nextIndex >= chain.steps.length) {
      // Chain tuntas.
      progress = progress.copyWith(
        totalXp: progress.totalXp + chain.rewardXp,
        questChainsCompleted: progress.questChainsCompleted + 1,
      );
      lastXpGained = chain.rewardXp;
      await StorageService.instance.saveProgress(progress);

      questChainProgress = null;
      await StorageService.instance.saveQuestChainProgress(null);

      final newlyUnlocked = _evaluateThresholdAchievements(DateTime.now());
      if (newlyUnlocked.isNotEmpty) {
        await StorageService.instance.saveAchievements(achievements);
      }
      lastUnlockedAchievements = newlyUnlocked;
      notifyListeners();
      return newlyUnlocked;
    } else {
      questChainProgress = qp.copyWith(currentStepIndex: nextIndex);
      await StorageService.instance.saveQuestChainProgress(questChainProgress);
      notifyListeners();
      return [];
    }
  }

  // ---------------- Reset ----------------

  Future<void> resetProgress() async {
    await StorageService.instance.resetAll();
    progress = const UserProgress();
    history = [];
    achievements = [];
    questChainProgress = null;
    _missionCounter = 0;
    currentMission = null;
    final now = DateTime.now();
    final challenge = DailyChallengeCatalog.forDate(now);
    dailyChallengeState = DailyChallengeState(date: now, challengeId: challenge.id, completed: false);
    await StorageService.instance.saveDailyChallengeState(dailyChallengeState!);
    notifyListeners();
  }
}
