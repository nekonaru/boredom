import 'package:flutter/foundation.dart';
import '../models/mission.dart';
import '../models/user_progress.dart';
import '../models/achievement.dart';
import '../models/daily_challenge.dart';
import '../models/quest_chain.dart';
import '../models/custom_mission.dart';
import '../services/mission_service.dart';
import '../services/storage_service.dart';
import '../services/achievement_catalog.dart';
import '../services/daily_challenge_catalog.dart';
import '../services/quest_chain_catalog.dart';

const int kMaxRerollsPerDay = 3;

/// Undo window for restoring the last completed mission.
const Duration kUndoWindow = Duration(minutes: 5);

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
  List<CustomMission> customMissions = [];
  Set<String> favoriteIds = {};

  // Undo snapshot of the last completion (cleared after the window ends
  // or once undo is used).
  UserProgress? _undoProgress;
  CompletedMission? _undoEntry;
  DateTime? _undoAt;

  bool _loaded = false;
  bool get loaded => _loaded;

  bool onboardingDone = true;

  int? lastXpGained;
  List<Achievement> lastUnlockedAchievements = [];

  Future<void> init() async {
    final storage = StorageService.instance;
    // Independent reads run concurrently so first paint comes sooner.
    final results = await Future.wait([
      storage.loadProgress(),
      storage.loadHistory(),
      storage.loadAchievements(),
      storage.loadQuestChainProgress(),
      storage.loadCustomMissions(),
      storage.loadFavorites(),
      storage.loadDailyChallengeState(),
      storage.isOnboardingDone(),
    ]);
    progress = results[0] as UserProgress;
    history = results[1] as List<CompletedMission>;
    achievements = results[2] as List<UnlockedAchievement>;
    questChainProgress = results[3] as QuestChainProgress?;
    customMissions = results[4] as List<CustomMission>;
    favoriteIds = results[5] as Set<String>;
    final storedChallenge = results[6] as DailyChallengeState?;
    onboardingDone = results[7] as bool;
    _missionCounter = history.length;

    final now = DateTime.now();
    progress = _resetRerollsIfNewDay(progress, now);
    progress = _handleAppOpen(progress, now);

    if (storedChallenge == null || !_isSameDay(storedChallenge.date, now)) {
      final challenge = DailyChallengeCatalog.forDate(now);
      dailyChallengeState =
          DailyChallengeState(date: now, challengeId: challenge.id, completed: false);
      await storage.saveDailyChallengeState(dailyChallengeState!);
    } else {
      dailyChallengeState = storedChallenge;
    }

    await storage.saveProgress(progress);
    _loaded = true;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    onboardingDone = true;
    await StorageService.instance.setOnboardingDone(true);
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

  /// Grace day: a streak survives one missed day and only resets after two.
  bool _isTwoDaysAgo(DateTime last, DateTime now) {
    final twoAgo = now.subtract(const Duration(days: 2));
    return _isSameDay(last, twoAgo);
  }

  /// True when the user completed something yesterday or the day before
  /// but nothing today: the streak is alive yet at risk.
  bool get streakAtRisk {
    final last = progress.lastCompletedDate;
    if (last == null || progress.streakDays == 0) return false;
    final now = DateTime.now();
    if (_isSameDay(last, now)) return false;
    return _isYesterday(last, now) || _isTwoDaysAgo(last, now);
  }

  int get rerollsLeft =>
      (kMaxRerollsPerDay - progress.rerollsUsedToday).clamp(0, kMaxRerollsPerDay);

  bool get canUndo {
    if (_undoEntry == null || _undoAt == null) return false;
    return DateTime.now().difference(_undoAt!) <= kUndoWindow;
  }

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

  /// Ids completed in the last 7 days, excluded from rolls so missions
  /// feel fresh instead of repeating.
  Set<String> get recentMissionIds {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return history
        .where((e) => e.completedAt.isAfter(cutoff))
        .map((e) => e.missionId)
        .toSet();
  }

  void rollMission() {
    final filter = MissionFilter(
      mood: selectedMood,
      timeBudget: selectedTime,
      location: selectedLocation,
      energy: selectedEnergy,
    );
    final mission = MissionService.generate(
      filter,
      chaosMode: chaosMode,
      excludeIds: chaosMode ? const {} : recentMissionIds,
    );
    _missionCounter++;
    currentMission = MissionInstance(
      mission: mission,
      missionNumber: _missionCounter,
      isChaos: chaosMode,
    );
    notifyListeners();
  }

  /// True when the reroll went through, false when the daily budget is out.
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

    // Null out currentMission BEFORE any async work (not at the end).
    // This stops double taps: a second ACCEPT tap lands here while the
    // first call is still awaiting, sees null, and returns [] with no
    // double XP.
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
    } else if (_isYesterday(last, now) || _isTwoDaysAgo(last, now)) {
      newStreak = progress.streakDays + 1;
    } else {
      newStreak = 1;
    }

    final newCategoryCounts = Map<String, int>.from(progress.categoryCounts);
    final catKey = mission.category.name;
    newCategoryCounts[catKey] = (newCategoryCounts[catKey] ?? 0) + 1;

    _undoProgress = progress;
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
    _undoEntry = entry;
    _undoAt = now;
    history.insert(0, entry);

    await StorageService.instance.saveProgress(progress);
    await StorageService.instance.addHistoryEntry(entry);

    final newlyUnlocked = <Achievement>[];

    // Night owl is event-based, checked directly against the clock.
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

  /// Restores progress and history to just before the last completion.
  /// Returns false when there is nothing to undo or the window expired.
  Future<bool> undoLastComplete() async {
    if (!canUndo) return false;
    final snapshot = _undoProgress;
    if (snapshot == null) return false;
    progress = snapshot;
    if (history.isNotEmpty) history.removeAt(0);
    await StorageService.instance.saveProgress(progress);
    await StorageService.instance.removeLastHistoryEntry();
    _undoProgress = null;
    _undoEntry = null;
    _undoAt = null;
    lastXpGained = null;
    lastUnlockedAchievements = [];
    notifyListeners();
    return true;
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

  // ---------------- Favorites ----------------

  bool isFavorite(String missionId) => favoriteIds.contains(missionId);

  Future<void> toggleFavorite(String missionId) async {
    if (favoriteIds.contains(missionId)) {
      favoriteIds.remove(missionId);
    } else {
      favoriteIds.add(missionId);
    }
    await StorageService.instance.saveFavorites(favoriteIds);
    notifyListeners();
  }

  // ---------------- Custom missions ----------------

  Future<void> addCustomMission(String title, String description, int xp) async {
    final mission = CustomMission(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      description: description.trim(),
      baseXp: xp.clamp(5, 200),
      createdAt: DateTime.now(),
    );
    customMissions = [...customMissions, mission];
    await StorageService.instance.saveCustomMissions(customMissions);
    notifyListeners();
  }

  Future<void> deleteCustomMission(String id) async {
    customMissions = customMissions.where((m) => m.id != id).toList();
    await StorageService.instance.saveCustomMissions(customMissions);
    notifyListeners();
  }

  /// Completes a custom mission for XP, with the same streak and
  /// achievement handling as catalog missions.
  Future<List<Achievement>> completeCustomMission(CustomMission mission) async {
    final now = DateTime.now();
    int newStreak = progress.streakDays;
    final last = progress.lastCompletedDate;
    if (last == null) {
      newStreak = 1;
    } else if (_isSameDay(last, now)) {
      newStreak = progress.streakDays == 0 ? 1 : progress.streakDays;
    } else if (_isYesterday(last, now) || _isTwoDaysAgo(last, now)) {
      newStreak = progress.streakDays + 1;
    } else {
      newStreak = 1;
    }

    final newCategoryCounts = Map<String, int>.from(progress.categoryCounts);
    newCategoryCounts[mission.category.name] =
        (newCategoryCounts[mission.category.name] ?? 0) + 1;

    _undoProgress = progress;
    progress = progress.copyWith(
      totalXp: progress.totalXp + mission.baseXp,
      streakDays: newStreak,
      longestStreak: newStreak > progress.longestStreak ? newStreak : progress.longestStreak,
      lastCompletedDate: now,
      totalMissionsCompleted: progress.totalMissionsCompleted + 1,
      categoryCounts: newCategoryCounts,
    );
    lastXpGained = mission.baseXp;

    final entry = CompletedMission(
      missionId: mission.id,
      title: mission.title,
      emoji: '⭐',
      categoryLabel: mission.category.label,
      xpEarned: mission.baseXp,
      completedAt: now,
    );
    _undoEntry = entry;
    _undoAt = now;
    history.insert(0, entry);

    await StorageService.instance.saveProgress(progress);
    await StorageService.instance.addHistoryEntry(entry);

    final newlyUnlocked = _evaluateThresholdAchievements(now);
    if (newlyUnlocked.isNotEmpty) {
      await StorageService.instance.saveAchievements(achievements);
    }
    lastUnlockedAchievements = newlyUnlocked;
    notifyListeners();
    return newlyUnlocked;
  }

  // ---------------- Backup ----------------

  /// Serializes everything needed to restore this device state.
  Future<String> exportBackup() async {
    final data = {
      'app': 'boredom',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'progress': progress.toJson(),
      'history': history.map((e) => e.toJson()).toList(),
      'achievements': achievements
          .map((a) => {'achievementId': a.achievementId, 'unlockedAt': a.unlockedAt.toIso8601String()})
          .toList(),
      'dailyChallenge': dailyChallengeState == null
          ? null
          : {
              'date': dailyChallengeState!.date.toIso8601String(),
              'challengeId': dailyChallengeState!.challengeId,
              'completed': dailyChallengeState!.completed,
            },
      'questChain': questChainProgress == null
          ? null
          : {
              'chainId': questChainProgress!.chainId,
              'currentStepIndex': questChainProgress!.currentStepIndex,
            },
      'customMissions': customMissions.map((m) => m.toJson()).toList(),
      'favorites': favoriteIds.toList(),
    };
    return _encodeJson(data);
  }

  /// Restores state from [exportBackup] output. Returns false when the
  /// text is not a valid backup.
  Future<bool> importBackup(String text) async {
    try {
      final data = _decodeJson(text.trim());
      if (data['app'] != 'boredom' || data['progress'] == null) return false;
      final storage = StorageService.instance;

      progress = UserProgress.fromJson(
        Map<String, dynamic>.from(data['progress'] as Map),
      );
      history = ((data['history'] as List?) ?? [])
          .map((e) => CompletedMission.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      achievements = ((data['achievements'] as List?) ?? [])
          .map((e) => UnlockedAchievement.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final dc = data['dailyChallenge'] as Map?;
      dailyChallengeState = dc == null
          ? null
          : DailyChallengeState.fromJson(Map<String, dynamic>.from(dc));
      final qc = data['questChain'] as Map?;
      questChainProgress = qc == null
          ? null
          : QuestChainProgress.fromJson(Map<String, dynamic>.from(qc));
      customMissions = ((data['customMissions'] as List?) ?? [])
          .map((e) => CustomMission.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      favoriteIds = ((data['favorites'] as List?) ?? []).map((e) => '$e').toSet();

      await storage.saveProgress(progress);
      await storage.saveAchievements(achievements);
      if (dailyChallengeState != null) {
        await storage.saveDailyChallengeState(dailyChallengeState!);
      }
      await storage.saveQuestChainProgress(questChainProgress);
      await storage.saveCustomMissions(customMissions);
      await storage.saveFavorites(favoriteIds);
      _missionCounter = history.length;
      _undoProgress = null;
      _undoEntry = null;
      _undoAt = null;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
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

  /// Returns newly unlocked achievements when the chain just finished.
  Future<List<Achievement>> completeCurrentChainStep() async {
    final qp = questChainProgress;
    if (qp == null) return [];
    final chain = QuestChainCatalog.byId(qp.chainId);
    final nextIndex = qp.currentStepIndex + 1;

    if (nextIndex >= chain.steps.length) {
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
    final storage = StorageService.instance;
    await storage.resetAll();
    await storage.saveCustomMissions(const []);
    await storage.saveFavorites(const {});
    progress = const UserProgress();
    history = [];
    achievements = [];
    questChainProgress = null;
    customMissions = [];
    favoriteIds = {};
    _undoProgress = null;
    _undoEntry = null;
    _undoAt = null;
    _missionCounter = 0;
    currentMission = null;
    final now = DateTime.now();
    final challenge = DailyChallengeCatalog.forDate(now);
    dailyChallengeState = DailyChallengeState(date: now, challengeId: challenge.id, completed: false);
    await storage.saveDailyChallengeState(dailyChallengeState!);
    notifyListeners();
  }

  // ---------------- Weekly stats (v2.0) ----------------

  /// Completed-mission counts for the last 7 days, oldest first.
  /// Index 6 is today.
  List<int> get last7DaysCounts {
    final now = DateTime.now();
    final counts = List<int>.filled(7, 0);
    for (final e in history) {
      final diff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(e.completedAt.year, e.completedAt.month, e.completedAt.day))
          .inDays;
      if (diff >= 0 && diff < 7) counts[6 - diff]++;
    }
    return counts;
  }
}

String _encodeJson(Map<String, dynamic> data) {
  final buffer = StringBuffer('{');
  var first = true;
  void writePair(String key, String valueJson) {
    if (!first) buffer.write(',');
    first = false;
    buffer.write('"$key":$valueJson');
  }

  data.forEach((key, value) {
    writePair(key, _valueToJson(value));
  });
  buffer.write('}');
  return buffer.toString();
}

String _valueToJson(Object? value) {
  if (value == null) return 'null';
  if (value is String) return '"${value.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', '\\n')}"';
  if (value is num || value is bool) return '$value';
  if (value is Map) {
    final parts = <String>[];
    value.forEach((k, v) => parts.add('"${k.toString().replaceAll('"', '\\"')}":${_valueToJson(v)}'));
    return '{${parts.join(',')}}';
  }
  if (value is Iterable) return '[${value.map(_valueToJson).join(',')}]';
  return '"$value"';
}

Map<String, dynamic> _decodeJson(String text) {
  final result = _JsonReader(text).readValue();
  if (result is Map<String, dynamic>) return result;
  throw const FormatException('Not a JSON object');
}

/// Minimal JSON reader for backup import. Only handles the shape our own
/// exporter writes (objects, arrays, strings, numbers, booleans, null).
class _JsonReader {
  final String text;
  int pos = 0;
  _JsonReader(this.text);

  Object? readValue() {
    _skipWs();
    if (pos >= text.length) throw const FormatException('Unexpected end');
    final c = text[pos];
    if (c == '{') return _readObject();
    if (c == '[') return _readArray();
    if (c == '"') return _readString();
    if (c == 't') return _readLiteral('true', true);
    if (c == 'f') return _readLiteral('false', false);
    if (c == 'n') return _readLiteral('null', null);
    return _readNumber();
  }

  Map<String, dynamic> _readObject() {
    pos++; // {
    final map = <String, dynamic>{};
    _skipWs();
    if (_peek() == '}') {
      pos++;
      return map;
    }
    while (true) {
      _skipWs();
      final key = _readString();
      _skipWs();
      _expect(':');
      map[key] = readValue();
      _skipWs();
      final c = _peek();
      if (c == ',') {
        pos++;
        continue;
      }
      if (c == '}') {
        pos++;
        return map;
      }
      throw const FormatException('Bad object');
    }
  }

  List<dynamic> _readArray() {
    pos++; // [
    final list = <dynamic>[];
    _skipWs();
    if (_peek() == ']') {
      pos++;
      return list;
    }
    while (true) {
      list.add(readValue());
      _skipWs();
      final c = _peek();
      if (c == ',') {
        pos++;
        continue;
      }
      if (c == ']') {
        pos++;
        return list;
      }
      throw const FormatException('Bad array');
    }
  }

  String _readString() {
    _expect('"');
    final out = StringBuffer();
    while (pos < text.length) {
      final c = text[pos++];
      if (c == '"') return out.toString();
      if (c == '\\') {
        if (pos >= text.length) break;
        final e = text[pos++];
        switch (e) {
          case 'n':
            out.write('\n');
          case 't':
            out.write('\t');
          case 'r':
            out.write('\r');
          case '"':
            out.write('"');
          case '\\':
            out.write('\\');
          case '/':
            out.write('/');
          case 'u':
            final hex = text.substring(pos, pos + 4);
            out.write(String.fromCharCode(int.parse(hex, radix: 16)));
            pos += 4;
          default:
            out.write(e);
        }
      } else {
        out.write(c);
      }
    }
    throw const FormatException('Bad string');
  }

  Object? _readLiteral(String word, Object? value) {
    if (text.startsWith(word, pos)) {
      pos += word.length;
      return value;
    }
    throw const FormatException('Bad literal');
  }

  num _readNumber() {
    final start = pos;
    while (pos < text.length && '-+0123456789.eE'.contains(text[pos])) {
      pos++;
    }
    return num.parse(text.substring(start, pos));
  }

  void _skipWs() {
    while (pos < text.length && ' \t\n\r'.contains(text[pos])) {
      pos++;
    }
  }

  String _peek() => pos < text.length ? text[pos] : '';

  void _expect(String c) {
    if (_peek() != c) throw FormatException('Expected $c');
    pos++;
  }
}
