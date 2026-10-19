import 'package:flutter/foundation.dart';
import '../models/mission.dart';
import '../models/user_progress.dart';
import '../models/achievement.dart';
import '../models/daily_challenge.dart';
import '../models/quest_chain.dart';
import '../models/custom_mission.dart';
import '../models/saved_mission.dart';
import '../services/mission_service.dart';
import '../services/mission_catalog.dart';
import '../services/storage_service.dart';
import '../services/achievement_catalog.dart';
import '../services/daily_challenge_catalog.dart';
import '../services/quest_chain_catalog.dart';
import '../services/reminder_service.dart';
import 'language_provider.dart';

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
  Set<String> dislikedIds = {};
  Set<String> mutedCategories = {};
  List<SavedMission> savedMissions = [];
  bool quickWinsOnly = false;
  bool reminderEnabled = false;
  int reminderHour = 19;
  int reminderMinute = 0;

  // Undo snapshot of the last completion (cleared after the window ends
  // or once undo is used).
  UserProgress? _undoProgress;
  DateTime? _undoAt;
  int _undoHistoryLength = 0;
  List<UnlockedAchievement> _undoAchievements = const [];
  QuestChainProgress? _undoChainProgress;
  DailyChallengeState? _undoDailyChallenge;
  List<SavedMission> _undoSavedMissions = const [];

  /// Day of the app open already counted by the startup load.
  /// `retryLoad()` re-runs that load, so without this guard one real app
  /// open could be counted twice and inflate the streak achievement.
  DateTime? _countedAppOpenOn;

  bool _loaded = false;
  bool get loaded => _loaded;

  /// Set when startup could not read local data. The gate shows a retry
  /// instead of spinning forever.
  String? loadError;

  bool get failedToLoad => loadError != null;

  bool onboardingDone = true;
  bool hapticsEnabled = true;

  int? lastXpGained;
  List<Achievement> lastUnlockedAchievements = [];
  bool lastFreezeUsed = false;

  Future<void> init() async {
    try {
      await _load();
    } catch (e) {
      // Without this the gate would spin forever on unreadable storage.
      loadError = '$e';
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _load() async {
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
      storage.loadHapticsEnabled(),
      storage.loadDisliked(),
      storage.loadSavedMissions(),
      storage.loadMutedCategories(),
      storage.loadReminderEnabled(),
      storage.loadReminderHour(),
      storage.loadReminderMinute(),
    ]);
    progress = results[0] as UserProgress;
    history = results[1] as List<CompletedMission>;
    achievements = results[2] as List<UnlockedAchievement>;
    questChainProgress = results[3] as QuestChainProgress?;
    customMissions = results[4] as List<CustomMission>;
    favoriteIds = results[5] as Set<String>;
    final storedChallenge = results[6] as DailyChallengeState?;
    onboardingDone = results[7] as bool;
    hapticsEnabled = results[8] as bool;
    dislikedIds = results[9] as Set<String>;
    savedMissions = results[10] as List<SavedMission>;
    mutedCategories = results[11] as Set<String>;
    reminderEnabled = results[12] as bool;
    reminderHour = results[13] as int;
    reminderMinute = results[14] as int;
    _missionCounter = history.length;

    final now = DateTime.now();
    progress = _resetRerollsIfNewDay(progress, now);
    if (_countedAppOpenOn == null || !_isSameDay(_countedAppOpenOn!, now)) {
      progress = _handleAppOpen(progress, now);
      _countedAppOpenOn = now;
    }

    if (storedChallenge == null || !_isSameDay(storedChallenge.date, now)) {
      final challenge = DailyChallengeCatalog.forDate(now);
      dailyChallengeState =
          DailyChallengeState(date: now, challengeId: challenge.id, completed: false);
      await storage.saveDailyChallengeState(dailyChallengeState!);
    } else {
      dailyChallengeState = storedChallenge;
    }

    await storage.saveProgress(progress);
    loadError = null;

    // Notifications are opt-in: only (re)schedule when already enabled.
    if (reminderEnabled) {
      await ReminderService.instance.scheduleDaily(
        reminderHour,
        reminderMinute,
        code: LanguageProvider.instance.code,
      );
    }
  }

  /// Retries a failed startup load.
  Future<void> retryLoad() async {
    loadError = null;
    await init();
  }

  /// Takes the full pre-action snapshot used by undo across every action
  /// that grants XP or advances state (missions, daily challenge, chains).
  void _captureUndo() {
    _undoProgress = progress;
    _undoHistoryLength = history.length;
    _undoAchievements = List<UnlockedAchievement>.from(achievements);
    _undoChainProgress = questChainProgress;
    _undoDailyChallenge = dailyChallengeState;
    // The inbox list must travel with the progress snapshot: it carries the
    // `missionsSaved` counter inside `progress`, so restoring one without the
    // other leaves the counter permanently out of step with the list.
    _undoSavedMissions = List<SavedMission>.from(savedMissions);
    _undoAt = DateTime.now();
  }

  void _clearUndo() {
    _undoProgress = null;
    _undoAt = null;
    _undoChainProgress = null;
    _undoDailyChallenge = null;
    _undoSavedMissions = const [];
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

  bool _isThreeDaysAgo(DateTime last, DateTime now) {
    final threeAgo = now.subtract(const Duration(days: 3));
    return _isSameDay(last, threeAgo);
  }

  /// Shared streak math for every completion path. A freeze token covers a
  /// 3-day gap; every 7th streak day earns one token (max 3 held).
  _StreakResolution _resolveStreak({
    required DateTime? last,
    required DateTime now,
    required int streakDays,
    required int tokens,
  }) {
    var streak = streakDays;
    var remaining = tokens;
    var usedFreeze = false;
    if (last == null) {
      streak = 1;
    } else if (_isSameDay(last, now)) {
      streak = streakDays == 0 ? 1 : streakDays;
    } else if (_isYesterday(last, now) || _isTwoDaysAgo(last, now)) {
      streak = streakDays + 1;
    } else if (_isThreeDaysAgo(last, now) && tokens > 0) {
      streak = streakDays + 1;
      remaining = tokens - 1;
      usedFreeze = true;
    } else {
      streak = 1;
    }
    // Only count tokens that were actually granted. The 3-token cap means a
    // player holding the cap earns nothing here, so counting it would let
    // the freeze achievements unlock for tokens never received.
    final granted = streak > streakDays && streak % 7 == 0 && remaining < 3;
    if (granted) remaining += 1;
    final earned = progress.freezeTokensEarned + (granted ? 1 : 0);
    return _StreakResolution(
      streak: streak,
      tokens: remaining,
      usedFreeze: usedFreeze,
      tokensEarned: earned,
    );
  }

  /// Weekend double XP. Pure and unit-testable.
  static bool isWeekend(DateTime date) =>
      date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

  static int xpForDate(int baseXp, DateTime date) =>
      isWeekend(date) ? baseXp * 2 : baseXp;

  /// Bonus XP when a completion crosses a multiple of [every] levels.
  /// Crossing level 20, for example, adds 60 XP on top of the mission XP.
  static int milestoneBonus(int level, {int every = 10}) {
    if (level < every || level % every != 0) return 0;
    return level * 3;
  }

  /// Level reached after adding [baseXp] to [totalXp], weekend double
  /// included, without needing a UserProgress instance.
  static int milestoneLevel(int totalXp, int baseXp, DateTime now) {
    final after = totalXp + xpForDate(baseXp, now);
    var level = 1;
    while (UserProgress.xpNeededForLevel(level + 1) <= after) {
      level++;
    }
    return level;
  }

  /// Milestone XP for adding [baseXp] to [totalXp], or 0 when no 10-level
  /// boundary is crossed. Passing the level before and after the gain
  /// matters: paying whenever the resulting level is a multiple of ten
  /// would repeat the bonus on every completion spent sitting there.
  static int milestoneXpFor(int totalXp, int baseXp, DateTime now) {
    if (baseXp <= 0) return 0;
    final before = milestoneLevel(totalXp, 0, now);
    final after = milestoneLevel(totalXp, baseXp, now);
    if (after == before) return 0;
    var total = 0;
    for (var level = before + 1; level <= after; level++) {
      total += milestoneBonus(level);
    }
    return total;
  }

  /// True when the user completed something yesterday or the day before
  /// but nothing today: the streak is alive yet at risk.
  /// A 3-day gap also counts, because a freeze token would silently absorb
  /// it on the next completion.
  bool get streakAtRisk {
    final last = progress.lastCompletedDate;
    if (last == null || progress.streakDays == 0) return false;
    final now = DateTime.now();
    if (_isSameDay(last, now)) return false;
    return _isYesterday(last, now) ||
        _isTwoDaysAgo(last, now) ||
        _isThreeDaysAgo(last, now);
  }

  /// Rolls the date over to a new day without restarting the app. Without
  /// this, a process left open (or backgrounded while warm) past midnight
  /// keeps yesterday's daily challenge, reroll allowance, and streak state.
  void refreshIfDayChanged() {
    final now = DateTime.now();
    final changed = progress.rerollResetDate == null ||
        !_isSameDay(progress.rerollResetDate!, now) ||
        progress.appOpensResetDate == null ||
        !_isSameDay(progress.appOpensResetDate!, now) ||
        dailyChallengeState == null ||
        !_isSameDay(dailyChallengeState!.date, now);
    if (!changed) return;

    progress = _resetRerollsIfNewDay(progress, now);
    progress = _handleAppOpen(progress, now);

    if (dailyChallengeState == null ||
        !_isSameDay(dailyChallengeState!.date, now)) {
      final challenge = DailyChallengeCatalog.forDate(now);
      dailyChallengeState =
          DailyChallengeState(date: now, challengeId: challenge.id, completed: false);
      StorageService.instance.saveDailyChallengeState(dailyChallengeState!);
    }
    StorageService.instance.saveProgress(progress);
    notifyListeners();
  }

  int get rerollsLeft =>
      (kMaxRerollsPerDay - progress.rerollsUsedToday).clamp(0, kMaxRerollsPerDay);

  bool get canUndo {
    if (_undoAt == null) return false;
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
    // Quick wins narrows the time budget to at most 15 minutes, which is
    // what "I only have a little energy" usually means.
    final mission = MissionService.generate(
      MissionFilter(
        mood: filter.mood,
        timeBudget: quickWinsOnly && filter.timeBudget.minutes > 15
            ? TimeBudget.fifteenMin
            : filter.timeBudget,
        location: filter.location,
        energy: filter.energy,
      ),
      chaosMode: chaosMode,
      // Disliked missions are excluded alongside recent ones, so the
      // generator learns what the user does not want to see again.
      excludeIds: chaosMode ? const {} : {...recentMissionIds, ...dislikedIds},
      categoryCounts: progress.categoryCounts,
      excludeCategories: mutedCategories,
    );
    _missionCounter++;
    currentMission = MissionInstance(
      mission: mission,
      missionNumber: _missionCounter,
      isChaos: chaosMode,
    );
    notifyListeners();
  }

  void setQuickWins(bool value) {
    quickWinsOnly = value;
    notifyListeners();
  }

  bool isCategoryMuted(String categoryName) => mutedCategories.contains(categoryName);

  /// Mutes or unmutes a whole category. Always publishes a new Set
  /// instance so `context.select` in Profile sees a change (it compares
  /// with DeepCollectionEquality, which treats an in-place mutated set as
  /// unchanged).
  ///
  /// Muting the last remaining category is refused: the generator would
  /// otherwise fall back to the full catalog and the mute would silently
  /// stop meaning anything.
  Future<bool> toggleCategoryMuted(MissionCategory category) async {
    final name = category.name;
    if (mutedCategories.contains(name)) {
      mutedCategories = {...mutedCategories}..remove(name);
    } else {
      final playable = MissionCategory.values
          .where((c) => c != MissionCategory.chaos)
          .length;
      if (mutedCategories.length + 1 >= playable) return false;
      mutedCategories = {...mutedCategories, name};
    }
    await StorageService.instance.saveMutedCategories(mutedCategories);
    notifyListeners();
    return true;
  }

  // ---------------- Inbox ----------------

  List<SavedMission> get inbox => savedMissions;

  bool isSavedForLater(String missionId) =>
      savedMissions.any((m) => m.missionId == missionId);

  Future<void> saveForLater(String missionId) async {
    if (isSavedForLater(missionId)) return;
    savedMissions = [
      SavedMission(missionId: missionId, savedAt: DateTime.now()),
      ...savedMissions,
    ].take(50).toList();
    progress = progress.copyWith(
      missionsSaved: progress.missionsSaved + 1,
    );
    await StorageService.instance.saveSavedMissions(savedMissions);
    await StorageService.instance.saveProgress(progress);
    final unlocked = _evaluateThresholdAchievements(DateTime.now());
    if (unlocked.isNotEmpty) {
      await StorageService.instance.saveAchievements(achievements);
    }
    // Without this the save-count achievements unlock into thin air: they
    // are persisted, but the user is never told.
    lastUnlockedAchievements = unlocked;
    notifyListeners();
  }

  Future<void> removeSavedMission(String missionId) async {
    savedMissions = savedMissions.where((m) => m.missionId != missionId).toList();
    progress = progress.copyWith(
      missionsSaved:
          progress.missionsSaved > 0 ? progress.missionsSaved - 1 : 0,
    );
    await StorageService.instance.saveSavedMissions(savedMissions);
    await StorageService.instance.saveProgress(progress);
    notifyListeners();
  }

  /// Moves a saved mission back out of the inbox and returns it so the
  /// caller can present it. Returns null when the id is not in the inbox
  /// or the catalog no longer has it (the stale entry is dropped).
  ///
  /// This deliberately does not set `currentMission`: that slot belongs to
  /// `rollMission()`, which overwrites whatever is there, so a restored
  /// mission parked in it would silently disappear.
  Future<MissionInstance?> restoreSavedMission(String missionId) async {
    final index = savedMissions.indexWhere((m) => m.missionId == missionId);
    if (index < 0) return null;
    // Never clobber a mission that is already waiting to be accepted, and
    // never drop the inbox entry either: the user would lose both.
    if (currentMission != null) return null;
    final mission = missionById(missionId);
    if (mission == null) {
      // Stale entry (catalog changed): drop it instead of showing nothing.
      await removeSavedMission(missionId);
      return null;
    }
    await removeSavedMission(missionId);
    _missionCounter++;
    final instance = MissionInstance(
      mission: mission,
      missionNumber: _missionCounter,
      isChaos: false,
    );
    currentMission = instance;
    notifyListeners();
    return instance;
  }

  /// Catalog lookup by id, or null when the id no longer exists.
  Mission? missionById(String id) {
    for (final m in MissionCatalog.all) {
      if (m.id == id) return m;
    }
    return null;
  }

  // ---------------- Reminders ----------------

  /// Requests permission (if needed) and enables or disables the daily
  /// reminder. Returns true when reminders are now on.
  Future<bool> setReminder(bool enabled, {int? hour, int? minute}) async {
    final h = hour ?? reminderHour;
    final m = minute ?? reminderMinute;
    if (enabled) {
      final granted = await ReminderService.instance.requestPermission();
      if (!granted) {
        reminderEnabled = false;
        await StorageService.instance.saveReminder(
          enabled: false,
          hour: h,
          minute: m,
        );
        notifyListeners();
        return false;
      }
      await ReminderService.instance.scheduleDaily(
        h,
        m,
        code: LanguageProvider.instance.code,
      );
    } else {
      await ReminderService.instance.cancelDaily();
    }
    reminderEnabled = enabled;
    reminderHour = h;
    reminderMinute = m;
    await StorageService.instance.saveReminder(
      enabled: enabled,
      hour: h,
      minute: m,
    );
    notifyListeners();
    return enabled;
  }

  Future<bool> setReminderTime(int hour, int minute) async {
    return setReminder(reminderEnabled, hour: hour, minute: minute);
  }

  /// True when the reroll went through, false when the daily budget is out.
  Future<bool> rerollMission() async {
    if (rerollsLeft <= 0) return false;
    progress = progress.copyWith(
      rerollsUsedToday: progress.rerollsUsedToday + 1,
      totalRerollsAllTime: progress.totalRerollsAllTime + 1,
    );
    // Awaited: the old fire-and-forget write lost the reroll if the app
    // was killed right after, handing the user a free reroll.
    await StorageService.instance.saveProgress(progress);
    rollMission();
    return true;
  }

  void dismissMission() {
    currentMission = null;
    notifyListeners();
  }

  /// Records a completion. [outcome] is how the player says whether they
  /// actually did the thing, which is what makes the streak and the XP
  /// mean something.
  ///
  /// A [MissionOutcome.skipped] completion is still written to history so
  /// the attempt is visible, but it pays no XP and never touches the
  /// streak: pretending you showed up should not keep a streak alive.
  Future<List<Achievement>> completeMission([
    MissionOutcome outcome = MissionOutcome.done,
  ]) async {
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

    final fullXp = xpForDate(mission.baseXp, now);
    final gainedXp = outcome.countsAsActivity
        ? (fullXp * outcome.xpShare).round() +
            milestoneXpFor(progress.totalXp, mission.baseXp, now)
        : 0;

    // A skipped mission is not an active day, so neither the streak nor
    // the completion counters move.
    var streakDays = progress.streakDays;
    var longestStreak = progress.longestStreak;
    var lastCompletedDate = progress.lastCompletedDate;
    var freezeTokens = progress.freezeTokens;
    var freezeTokensEarned = progress.freezeTokensEarned;
    lastFreezeUsed = false;
    if (outcome.countsAsActivity) {
      final resolved = _resolveStreak(
        last: progress.lastCompletedDate,
        now: now,
        streakDays: progress.streakDays,
        tokens: progress.freezeTokens,
      );
      streakDays = resolved.streak;
      lastFreezeUsed = resolved.usedFreeze;
      lastCompletedDate = now;
      longestStreak =
          resolved.streak > progress.longestStreak ? resolved.streak : progress.longestStreak;
      freezeTokens = resolved.tokens;
      freezeTokensEarned = resolved.tokensEarned;
    }

    final newCategoryCounts = Map<String, int>.from(progress.categoryCounts);
    final catKey = mission.category.name;
    if (outcome.countsAsActivity) {
      newCategoryCounts[catKey] = (newCategoryCounts[catKey] ?? 0) + 1;
    }

    _captureUndo();
    progress = progress.copyWith(
      totalXp: progress.totalXp + gainedXp,
      streakDays: streakDays,
      longestStreak: longestStreak,
      lastCompletedDate: lastCompletedDate,
      totalMissionsCompleted: outcome.countsAsActivity
          ? progress.totalMissionsCompleted + 1
          : progress.totalMissionsCompleted,
      chaosMissionsCompleted:
          progress.chaosMissionsCompleted + (instance.isChaos && outcome.countsAsActivity ? 1 : 0),
      categoryCounts: newCategoryCounts,
      freezeTokens: freezeTokens,
      freezeTokensEarned: freezeTokensEarned,
    );
    lastXpGained = gainedXp;

    final entry = CompletedMission(
      missionId: mission.id,
      title: mission.title,
      emoji: mission.emoji,
      categoryLabel: mission.category.label,
      xpEarned: gainedXp,
      completedAt: now,
      outcome: outcome,
    );
    // New list instance: `context.select((p) => p.history)` in HistoryScreen
    // compares with DeepCollectionEquality, which treats an in-place
    // mutation as unchanged and would skip the rebuild.
    history = [entry, ...history];
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

  /// Restores everything to the moment before the last XP-granting action
  /// (mission, custom mission, daily challenge, or quest chain step).
  /// Returns false when there is nothing to undo or the window expired.
  Future<bool> undoLastAction() async {
    if (!canUndo) return false;
    final snapshot = _undoProgress;
    if (snapshot == null) return false;
    progress = snapshot;
    achievements = List<UnlockedAchievement>.from(_undoAchievements);
    // Undoing a finished quest chain must bring the chain back, otherwise
    // the steps completed for it are lost while its XP is rolled back.
    questChainProgress = _undoChainProgress;
    // Always written, even when null, so storage cannot keep a chain the
    // in-memory state just dropped.
    await StorageService.instance.saveQuestChainProgress(questChainProgress);
    if (_undoDailyChallenge != null) {
      dailyChallengeState = _undoDailyChallenge;
      await StorageService.instance.saveDailyChallengeState(dailyChallengeState!);
    }
    savedMissions = List<SavedMission>.from(_undoSavedMissions);
    await StorageService.instance.saveSavedMissions(savedMissions);

    // Restore the history list to its pre-action length.
    if (history.length > _undoHistoryLength) {
      history = history.sublist(0, _undoHistoryLength);
    }

    final storage = StorageService.instance;
    await storage.saveProgress(progress);
    await storage.saveHistory(history);
    await storage.saveAchievements(achievements);

    _clearUndo();
    lastXpGained = null;
    lastFreezeUsed = false;
    lastUnlockedAchievements = [];
    notifyListeners();
    return true;
  }

  /// Kept for callers that only ever undo a rolled mission.
  Future<bool> undoLastComplete() => undoLastAction();

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

  /// Current value of an achievement metric, exposed so the UI can show
  /// progress bars without duplicating the metric switch.
  int achievementProgress(Achievement ach, {int? missions, int? level}) =>
      _metricValue(ach, missions: missions, level: level);

  int _metricValue(Achievement ach, {int? missions, int? level}) {
    switch (ach.metric) {
      case AchievementMetric.totalMissions:
        return missions ?? progress.totalMissionsCompleted;
      case AchievementMetric.level:
        return level ?? progress.level;
      case AchievementMetric.streak:
        return progress.longestStreak;
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
      case AchievementMetric.freezeTokensEarned:
        return progress.freezeTokensEarned;
      case AchievementMetric.savedMissions:
        return progress.missionsSaved;
      case AchievementMetric.missionsDone:
        return history
            .where((e) => e.outcome == MissionOutcome.done)
            .length;
      case AchievementMetric.missionsPartial:
        return partialCount;
      case AchievementMetric.missionsSkipped:
        return skippedCount;
      case AchievementMetric.special:
        return 0;
    }
  }

  void clearLastXpGained() {
    lastXpGained = null;
    lastFreezeUsed = false;
  }

  void clearLastUnlockedAchievements() {
    lastUnlockedAchievements = [];
  }

  // ---------------- Favorites and dislikes ----------------

  bool isFavorite(String missionId) => favoriteIds.contains(missionId);

  /// Drops favorites whose mission is no longer in the catalog.
  ///
  /// They are unreachable from the UI, so keeping them silently only
  /// inflates the stored set. Left for the user to trigger rather than
  /// pruned on load, because a later catalog update could bring the
  /// mission back.
  Future<int> pruneOrphanFavorites() async {
    final orphans =
        favoriteIds.where((id) => missionById(id) == null).toSet();
    if (orphans.isEmpty) return 0;
    favoriteIds = {...favoriteIds}..removeAll(orphans);
    await StorageService.instance.saveFavorites(favoriteIds);
    notifyListeners();
    return orphans.length;
  }

  /// Always publishes a new Set instance so `context.select` on
  /// favoriteIds rebuilds the Favorites list (an in-place mutation is
  /// invisible to DeepCollectionEquality).
  Future<void> toggleFavorite(String missionId) async {
    if (favoriteIds.contains(missionId)) {
      favoriteIds = {...favoriteIds}..remove(missionId);
    } else {
      favoriteIds = {...favoriteIds, missionId};
    }
    await StorageService.instance.saveFavorites(favoriteIds);
    notifyListeners();
  }

  bool isDisliked(String missionId) => dislikedIds.contains(missionId);

  /// Always publishes a new Set instance for the same reason as
  /// [toggleFavorite]: an in-place mutation is invisible to the
  /// DeepCollectionEquality that `context.select` uses, so anything
  /// selecting the collection itself would freeze.
  Future<void> toggleDislike(String missionId) async {
    if (dislikedIds.contains(missionId)) {
      dislikedIds = {...dislikedIds}..remove(missionId);
    } else {
      dislikedIds = {...dislikedIds, missionId};
    }
    await StorageService.instance.saveDisliked(dislikedIds);
    notifyListeners();
  }

  // ---------------- Haptics ----------------

  Future<void> setHapticsEnabled(bool value) async {
    hapticsEnabled = value;
    await StorageService.instance.saveHapticsEnabled(value);
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
  Future<List<Achievement>> completeCustomMission(
    CustomMission mission, [
    MissionOutcome outcome = MissionOutcome.done,
  ]) async {
    final now = DateTime.now();
    final fullXp = xpForDate(mission.baseXp, now);
    final gainedXp = outcome.countsAsActivity
        ? (fullXp * outcome.xpShare).round() +
            milestoneXpFor(progress.totalXp, mission.baseXp, now)
        : 0;
    final resolved = outcome.countsAsActivity
        ? _resolveStreak(
            last: progress.lastCompletedDate,
            now: now,
            streakDays: progress.streakDays,
            tokens: progress.freezeTokens,
          )
        : const _StreakResolution(
            streak: 0,
            tokens: 0,
            usedFreeze: false,
            tokensEarned: 0,
          );
    final newStreak = outcome.countsAsActivity ? resolved.streak : progress.streakDays;
    lastFreezeUsed = resolved.usedFreeze;

    final newCategoryCounts = Map<String, int>.from(progress.categoryCounts);
    if (outcome.countsAsActivity) {
      newCategoryCounts[mission.category.name] =
          (newCategoryCounts[mission.category.name] ?? 0) + 1;
    }

    _captureUndo();
    progress = progress.copyWith(
      totalXp: progress.totalXp + gainedXp,
      streakDays: newStreak,
      longestStreak: newStreak > progress.longestStreak ? newStreak : progress.longestStreak,
      lastCompletedDate: outcome.countsAsActivity ? now : progress.lastCompletedDate,
      totalMissionsCompleted: outcome.countsAsActivity
          ? progress.totalMissionsCompleted + 1
          : progress.totalMissionsCompleted,
      categoryCounts: newCategoryCounts,
      freezeTokens: outcome.countsAsActivity ? resolved.tokens : progress.freezeTokens,
      freezeTokensEarned:
          outcome.countsAsActivity ? resolved.tokensEarned : progress.freezeTokensEarned,
    );
    lastXpGained = gainedXp;

    final entry = CompletedMission(
      missionId: mission.id,
      title: mission.title,
      emoji: '⭐',
      categoryLabel: mission.category.label,
      xpEarned: gainedXp,
      completedAt: now,
      outcome: outcome,
    );
    // New list instance: `context.select((p) => p.history)` in HistoryScreen
    // compares with DeepCollectionEquality, which treats an in-place
    // mutation as unchanged and would skip the rebuild.
    history = [entry, ...history];

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
      'disliked': dislikedIds.toList(),
      'saved': savedMissions.map((m) => m.toJson()).toList(),
      'mutedCategories': mutedCategories.toList(),
      // Reminder settings were missing, so a restore on a new phone
      // silently came back with reminders switched off and the old time
      // thrown away.
      'reminder': {
        'enabled': reminderEnabled,
        'hour': reminderHour,
        'minute': reminderMinute,
      },
    };
    return _encodeJson(data);
  }

  /// Restores state from [exportBackup] output. Returns false when the
  /// text is not a valid backup.
  ///
  /// Everything is parsed into locals first and only assigned to the
  /// provider once the whole payload has been read, so a malformed entry
  /// halfway through leaves the current state untouched instead of
  /// half-applied.
  Future<bool> importBackup(String text) async {
    try {
      final data = _decodeJson(text.trim());
      if (data['app'] != 'boredom' || data['progress'] == null) return false;
      final storage = StorageService.instance;

      final importedProgress = UserProgress.fromJson(
        Map<String, dynamic>.from(data['progress'] as Map),
      );
      final importedHistory = ((data['history'] as List?) ?? [])
          .map((e) => CompletedMission.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final importedAchievements = ((data['achievements'] as List?) ?? [])
          .map((e) => UnlockedAchievement.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final dc = data['dailyChallenge'] as Map?;
      final importedChallenge = dc == null
          ? null
          : DailyChallengeState.fromJson(Map<String, dynamic>.from(dc));
      final qc = data['questChain'] as Map?;
      final importedChain = qc == null
          ? null
          : QuestChainProgress.fromJson(Map<String, dynamic>.from(qc));
      final importedCustom = ((data['customMissions'] as List?) ?? [])
          .map((e) => CustomMission.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final importedFavorites =
          ((data['favorites'] as List?) ?? []).map((e) => '$e').toSet();
      final importedDisliked =
          ((data['disliked'] as List?) ?? []).map((e) => '$e').toSet();
      final importedSaved = ((data['saved'] as List?) ?? [])
          .map((e) => SavedMission.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final importedMuted =
          ((data['mutedCategories'] as List?) ?? []).map((e) => '$e').toSet();

      // Clamp against the current catalog so a backup taken when a chain
      // was longer cannot index past the end of today's step list.
      var importedChainSafe = importedChain;
      if (importedChain != null) {
        final catalogChain = QuestChainCatalog.byId(importedChain.chainId);
        // A chain id this build does not ship cannot be clamped against a
        // step list that does not exist, so it is dropped rather than
        // silently swapped for a different arc.
        if (catalogChain == null) {
          importedChainSafe = null;
        }
        final steps = catalogChain?.steps.length ?? 0;
        final maxIndex = steps < 1 ? 0 : steps - 1;
        if (catalogChain != null &&
            (importedChain.currentStepIndex > maxIndex ||
                importedChain.currentStepIndex < 0)) {
          importedChainSafe = QuestChainProgress(
            chainId: importedChain.chainId,
            currentStepIndex: maxIndex,
          );
        }
      }

      progress = importedProgress;
      history = importedHistory;
      achievements = importedAchievements;
      dailyChallengeState = importedChallenge;
      questChainProgress = importedChainSafe;
      customMissions = importedCustom;
      favoriteIds = importedFavorites;
      dislikedIds = importedDisliked;
      savedMissions = importedSaved;
      mutedCategories = importedMuted;

      await storage.saveProgress(progress);
      await storage.saveHistory(history);
      await storage.saveAchievements(achievements);
      // Written unconditionally. Guarding this on non-null left storage
      // holding the previous day's challenge while memory had dropped it,
      // so the stale value came back on the next launch.
      await storage.saveDailyChallengeState(dailyChallengeState);
      await storage.saveQuestChainProgress(questChainProgress);
      await storage.saveCustomMissions(customMissions);
      await storage.saveFavorites(favoriteIds);
      await storage.saveDisliked(dislikedIds);
      await storage.saveSavedMissions(savedMissions);
      await storage.saveMutedCategories(mutedCategories);
      // Backups written before v2.8.0 carry no reminder block. Those keep
      // the old "clear it" behaviour so a legacy restore never leaves a
      // schedule the user cannot see.
      final rm = data['reminder'] as Map?;
      if (rm == null) {
        await storage.saveReminder(enabled: false, hour: 19, minute: 0);
        await ReminderService.instance.cancelDaily();
        reminderEnabled = false;
        reminderHour = 19;
        reminderMinute = 0;
      } else {
        final h = (rm['hour'] as num?)?.toInt() ?? 19;
        final mi = (rm['minute'] as num?)?.toInt() ?? 0;
        final safeHour = h.clamp(0, 23);
        final safeMinute = mi.clamp(0, 59);
        final wantEnabled = rm['enabled'] == true;
        await storage.saveReminder(
          enabled: wantEnabled,
          hour: safeHour,
          minute: safeMinute,
        );
        if (wantEnabled) {
          await ReminderService.instance.scheduleDaily(
            safeHour,
            safeMinute,
            code: LanguageProvider.instance.code,
          );
        } else {
          await ReminderService.instance.cancelDaily();
        }
        reminderEnabled = wantEnabled;
        reminderHour = safeHour;
        reminderMinute = safeMinute;
      }
      _missionCounter = history.length;
      _clearUndo();
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

  Future<List<Achievement>> completeDailyChallenge() async {
    if (dailyChallengeState == null || dailyChallengeState!.completed) {
      return const [];
    }
    final challenge = currentDailyChallenge!;
    final now = DateTime.now();
    _captureUndo();
    dailyChallengeState = dailyChallengeState!.copyWith(completed: true);

    final gainedXp = xpForDate(challenge.rewardXp, now) +
        milestoneXpFor(progress.totalXp, challenge.rewardXp, now);

    // The challenge used to grant XP and nothing else. That meant a player
    // who levelled up here did not unlock the level achievements until
    // they happened to complete a regular mission, and the day counted as
    // blank in every stat: weekly chart, active-day average, busiest
    // weekday, and the streak. It now goes through the same streak,
    // history, and achievement handling as a catalog mission.
    final resolved = _resolveStreak(
      last: progress.lastCompletedDate,
      now: now,
      streakDays: progress.streakDays,
      tokens: progress.freezeTokens,
    );
    final newStreak = resolved.streak;
    lastFreezeUsed = resolved.usedFreeze;

    final newCategoryCounts = Map<String, int>.from(progress.categoryCounts);
    newCategoryCounts[challenge.category.name] =
        (newCategoryCounts[challenge.category.name] ?? 0) + 1;

    progress = progress.copyWith(
      totalXp: progress.totalXp + gainedXp,
      streakDays: newStreak,
      longestStreak:
          newStreak > progress.longestStreak ? newStreak : progress.longestStreak,
      lastCompletedDate: now,
      totalMissionsCompleted: progress.totalMissionsCompleted + 1,
      categoryCounts: newCategoryCounts,
      freezeTokens: resolved.tokens,
      freezeTokensEarned: resolved.tokensEarned,
    );
    lastXpGained = gainedXp;

    final entry = CompletedMission(
      missionId: challenge.id,
      title: challenge.title,
      emoji: challenge.emoji,
      categoryLabel: challenge.category.label,
      xpEarned: gainedXp,
      completedAt: now,
    );
    history = [entry, ...history];

    await StorageService.instance.saveDailyChallengeState(dailyChallengeState!);
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

  /// Puts the daily challenge back to unfinished.
  Future<void> reopenDailyChallenge() async {
    if (dailyChallengeState == null || !dailyChallengeState!.completed) return;
    dailyChallengeState = dailyChallengeState!.copyWith(completed: false);
    await StorageService.instance.saveDailyChallengeState(dailyChallengeState!);
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
    if (chain == null) {
      // The arc no longer exists in this build. Drop it rather than
      // silently swapping the player onto a different chain mid-progress.
      await abandonChain();
      return [];
    }
    final nextIndex = qp.currentStepIndex + 1;
    _captureUndo();

    if (nextIndex >= chain.steps.length) {
      final now = DateTime.now();
      final gainedXp = xpForDate(chain.rewardXp, now) +
          milestoneXpFor(progress.totalXp, chain.rewardXp, now);

      // Same reasoning as the daily challenge: finishing a chain paid out
      // XP, but the day went unrecorded, so the weekly chart, the
      // active-day average and the streak all ignored a day the user had
      // actually spent on something.
      final resolved = _resolveStreak(
        last: progress.lastCompletedDate,
        now: now,
        streakDays: progress.streakDays,
        tokens: progress.freezeTokens,
      );
      final newStreak = resolved.streak;
      lastFreezeUsed = resolved.usedFreeze;

      final newCategoryCounts = Map<String, int>.from(progress.categoryCounts);
      newCategoryCounts[chain.category.name] =
          (newCategoryCounts[chain.category.name] ?? 0) + 1;

      progress = progress.copyWith(
        totalXp: progress.totalXp + gainedXp,
        streakDays: newStreak,
        longestStreak:
            newStreak > progress.longestStreak ? newStreak : progress.longestStreak,
        lastCompletedDate: now,
        totalMissionsCompleted: progress.totalMissionsCompleted + 1,
        questChainsCompleted: progress.questChainsCompleted + 1,
        categoryCounts: newCategoryCounts,
        freezeTokens: resolved.tokens,
        freezeTokensEarned: resolved.tokensEarned,
      );
      lastXpGained = gainedXp;

      final entry = CompletedMission(
        missionId: 'chain_${chain.id}',
        title: chain.title,
        emoji: chain.emoji,
        categoryLabel: chain.category.label,
        xpEarned: gainedXp,
        completedAt: now,
      );
      history = [entry, ...history];

      await StorageService.instance.saveProgress(progress);
      await StorageService.instance.addHistoryEntry(entry);

      questChainProgress = null;
      await StorageService.instance.saveQuestChainProgress(null);

      final newlyUnlocked = _evaluateThresholdAchievements(now);
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
    await storage.saveDisliked(const {});
    await storage.saveSavedMissions(const []);
    await storage.saveMutedCategories(const {});
    await storage.saveReminder(enabled: false, hour: 19, minute: 0);
    await ReminderService.instance.cancelDaily();
    progress = const UserProgress();
    history = [];
    achievements = [];
    questChainProgress = null;
    customMissions = [];
    favoriteIds = {};
    dislikedIds = {};
    mutedCategories = {};
    savedMissions = [];
    // Clear transient completion state too, otherwise a "+XP" toast can
    // still fire (with a dead Undo) on the next Home interaction.
    lastXpGained = null;
    lastFreezeUsed = false;
    lastUnlockedAchievements = [];
    _clearUndo();
    _missionCounter = 0;
    currentMission = null;
    final now = DateTime.now();
    progress = _resetRerollsIfNewDay(progress, now);
    progress = _handleAppOpen(progress, now);
    final challenge = DailyChallengeCatalog.forDate(now);
    dailyChallengeState = DailyChallengeState(date: now, challengeId: challenge.id, completed: false);
    await storage.saveDailyChallengeState(dailyChallengeState!);
    notifyListeners();
  }

  // ---------------- Weekly stats (v2.0) ----------------

  /// Rows that represent real activity. A skipped mission is an attempt
  /// that never happened, so it must not inflate any "missions completed"
  /// figure. Rows with no recorded outcome predate the feature and count
  /// as activity, which is what they always did.
  Iterable<CompletedMission> get _activeHistory => history.where(
        (e) => e.outcome == null || e.outcome!.countsAsActivity,
      );

  /// Completed-mission counts for the last 7 days, oldest first.
  /// Index 6 is today.
  List<int> get last7DaysCounts {
    final now = DateTime.now();
    final counts = List<int>.filled(7, 0);
    for (final e in _activeHistory) {
      final diff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(e.completedAt.year, e.completedAt.month, e.completedAt.day))
          .inDays;
      if (diff >= 0 && diff < 7) counts[6 - diff]++;
    }
    return counts;
  }

  // ---------------- Monthly stats (v2.2) ----------------

  /// Completed-mission counts for the last 30 days, oldest first.
  /// Index 29 is today.
  List<int> get last30DaysCounts {
    final now = DateTime.now();
    final counts = List<int>.filled(30, 0);
    for (final e in _activeHistory) {
      final diff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(e.completedAt.year, e.completedAt.month, e.completedAt.day))
          .inDays;
      if (diff >= 0 && diff < 30) counts[29 - diff]++;
    }
    return counts;
  }

  /// Completions that recorded an outcome, newest data included.
  /// Rows saved before outcome tracking are excluded rather than counted
  /// as successes.
  int get trackedCompletions =>
      history.where((e) => e.outcome != null).length;

  /// Share of tracked completions actually carried out, 0 to 1.
  /// Null when nothing has been tracked yet, which is different from a
  /// genuine 0 percent.
  double? get followThroughRate {
    final tracked = trackedCompletions;
    if (tracked == 0) return null;
    final done = history
        .where((e) => e.outcome == MissionOutcome.done)
        .length;
    return done / tracked;
  }

  int get partialCount =>
      history.where((e) => e.outcome == MissionOutcome.partial).length;

  int get skippedCount =>
      history.where((e) => e.outcome == MissionOutcome.skipped).length;

  /// Average XP per active day (days with at least one real completion).
  double get avgXpPerActiveDay {
    final active = _activeHistory.toList();
    if (active.isEmpty) return 0;
    final days = active
        .map((e) => DateTime(e.completedAt.year, e.completedAt.month, e.completedAt.day))
        .toSet()
        .length;
    if (days == 0) return 0;
    final total = active.fold<int>(0, (sum, e) => sum + e.xpEarned);
    return total / days;
  }

  /// Weekday (1=Monday, 7=Sunday) with the most completions, or null.
  int? get busiestWeekday {
    final active = _activeHistory.toList();
    if (active.isEmpty) return null;
    final counts = List<int>.filled(7, 0);
    for (final e in active) {
      counts[e.completedAt.weekday - 1]++;
    }
    var best = 0;
    for (var i = 1; i < 7; i++) {
      if (counts[i] > counts[best]) best = i;
    }
    return best + 1;
  }

  /// Weekly recap used by the Home summary strip.
  ({int missions, int xp}) get last7DaysSummary {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    var missions = 0;
    var xp = 0;
    for (final e in _activeHistory) {
      if (e.completedAt.isAfter(cutoff)) {
        missions++;
        xp += e.xpEarned;
      }
    }
    return (missions: missions, xp: xp);
  }
}

class _StreakResolution {
  final int streak;
  final int tokens;
  final bool usedFreeze;
  final int tokensEarned;
  const _StreakResolution({
    required this.streak,
    required this.tokens,
    required this.usedFreeze,
    required this.tokensEarned,
  });
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
  // Escapes the full JSON control-character set. Tabs and carriage returns
  // must be escaped too: a raw control character makes the export invalid
  // JSON, which any third-party parser (or a chat app that normalizes
  // pasted text) would reject.
  if (value is String) {
    final escaped = value
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
    return '"$escaped"';
  }
  if (value is num || value is bool) return '$value';
  if (value is Map) {
    final parts = <String>[];
    value.forEach((k, v) => parts.add('"${k.toString().replaceAll('"', '\\"')}":${_valueToJson(v)}'));
    return '{${parts.join(',')}}';
  }
  if (value is Iterable) return '[${value.map(_valueToJson).join(',')}]';
  return '"$value"';
}

/// Guards against pathological pasted input: a huge string, or deeply
/// nested arrays that would recurse until the stack blows.
const int _kMaxBackupChars = 2 * 1024 * 1024;
const int _kMaxJsonDepth = 64;

Map<String, dynamic> _decodeJson(String text) {
  if (text.length > _kMaxBackupChars) {
    throw const FormatException('Backup too large');
  }
  final result = _JsonReader(text).readValue();
  if (result is Map<String, dynamic>) return result;
  throw const FormatException('Not a JSON object');
}

/// Minimal JSON reader for backup import. Only handles the shape our own
/// exporter writes (objects, arrays, strings, numbers, booleans, null).
class _JsonReader {
  final String text;
  int pos = 0;
  int _depth = 0;
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

  /// Guards the recursive descent against stack exhaustion.
  void _enter() {
    if (++_depth > _kMaxJsonDepth) {
      throw const FormatException('Backup nested too deeply');
    }
  }

  void _exit() => _depth--;

  Map<String, dynamic> _readObject() {
    _enter();
    pos++; // {
    final map = <String, dynamic>{};
    _skipWs();
    if (_peek() == '}') {
      pos++;
      _exit();
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
        _exit();
        return map;
      }
      throw const FormatException('Bad object');
    }
  }

  List<dynamic> _readArray() {
    _enter();
    pos++; // [
    final list = <dynamic>[];
    _skipWs();
    if (_peek() == ']') {
      pos++;
      _exit();
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
        _exit();
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
            if (pos + 4 > text.length) {
              throw const FormatException('Bad unicode escape');
            }
            final hex = text.substring(pos, pos + 4);
            final code = int.tryParse(hex, radix: 16);
            if (code == null) throw const FormatException('Bad unicode escape');
            out.write(String.fromCharCode(code));
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
    final parsed = num.tryParse(text.substring(start, pos));
    if (parsed == null) throw const FormatException('Bad number');
    return parsed;
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
