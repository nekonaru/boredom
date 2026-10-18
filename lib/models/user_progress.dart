/// Absurd level names, so it feels like a game instead of a productivity app.
///
/// The milestone list is sorted by level on every lookup instead of relying
/// on the map's insertion order, so adding an entry out of order cannot
/// silently hand a player the wrong title.
class LevelTitles {
  static const List<MapEntry<int, String>> _milestones = [
    MapEntry(1, 'Bored'),
    MapEntry(5, 'Slightly Productive'),
    MapEntry(10, 'Touching Grass'),
    MapEntry(20, 'Main Character'),
    MapEntry(35, 'Certified Not Boring'),
    MapEntry(50, 'Chronically Unbored'),
    MapEntry(75, 'Boredom Slayer'),
    MapEntry(100, 'The Final Boss of Boredom'),
  ];

  static const Map<int, String> _milestonesId = {
    1: 'Bosan',
    5: 'Agak Produktif',
    10: 'Sentuh Rumput',
    20: 'Tokoh Utama',
    35: 'Sertifikat Tidak Bosan',
    50: 'Anti Bosan Kronis',
    75: 'Pembasmi Kebosanan',
    100: 'Bos Terakhir Kebosanan',
  };

  static String titleFor(int level, {String code = 'en'}) {
    final table = code == 'id' ? _milestonesId : null;
    String title = table?[1] ?? _milestones.first.value;
    for (final entry in _milestones) {
      if (level >= entry.key) title = table?[entry.key] ?? entry.value;
    }
    return title;
  }
}

/// User progress: level is derived from total XP with a simple curve.
class UserProgress {
  final int totalXp;
  final int streakDays;
  final DateTime? lastCompletedDate;
  final int rerollsUsedToday;
  final DateTime? rerollResetDate;
  final int totalMissionsCompleted;

  // Used for Statistics and Achievements.
  final int totalRerollsAllTime;
  final int chaosMissionsCompleted;
  final int questChainsCompleted;
  final Map<String, int> categoryCounts; // key = MissionCategory.name
  final int appOpensToday;
  final DateTime? appOpensResetDate;
  final int longestStreak;
  final int freezeTokens;
  final int freezeTokensEarned;
  final int missionsSaved;

  const UserProgress({
    this.totalXp = 0,
    this.streakDays = 0,
    this.lastCompletedDate,
    this.rerollsUsedToday = 0,
    this.rerollResetDate,
    this.totalMissionsCompleted = 0,
    this.totalRerollsAllTime = 0,
    this.chaosMissionsCompleted = 0,
    this.questChainsCompleted = 0,
    this.categoryCounts = const {},
    this.appOpensToday = 0,
    this.appOpensResetDate,
    this.longestStreak = 0,
    this.freezeTokens = 0,
    this.freezeTokensEarned = 0,
    this.missionsSaved = 0,
  });

  // Level curve: higher levels need progressively more XP.
  // Level 1 is the free starting point (0 XP). Level N (N>=2) needs total XP
  // = 50 * (N-1) * N / 2 (triangular, so it stays smooth).
  //
  // FIX: the formula used to be `50 * level * (level+1) / 2`, which treated
  // "level 1" itself as costing 50 XP to reach, even though new users start
  // at level 1 with 0 XP. That made xpIntoCurrentLevel go NEGATIVE
  // (rendering "-50/100 XP" and friends) for every new user until their
  // total XP passed 50 (that is, until finishing the first mission, since
  // the smallest mission XP in the catalog is only 15). This formula shifts
  // the base so level 1 consistently starts at 0 XP.
  static int xpNeededForLevel(int level) =>
      level <= 1 ? 0 : (50 * (level - 1) * level) ~/ 2;

  int get level {
    int lvl = 1;
    while (xpNeededForLevel(lvl + 1) <= totalXp) {
      lvl++;
    }
    return lvl;
  }

  int get xpIntoCurrentLevel => totalXp - xpNeededForLevel(level);
  int get xpNeededForNextLevel =>
      xpNeededForLevel(level + 1) - xpNeededForLevel(level);
  double get levelProgress =>
      xpNeededForNextLevel == 0 ? 1 : xpIntoCurrentLevel / xpNeededForNextLevel;

  /// Localized level title. Defaults to English; pass the active language
  /// code to render it in Bahasa Indonesia.
  String levelTitleFor(String code) => LevelTitles.titleFor(level, code: code);

  String get levelTitle => LevelTitles.titleFor(level);

  UserProgress copyWith({
    int? totalXp,
    int? streakDays,
    DateTime? lastCompletedDate,
    int? rerollsUsedToday,
    DateTime? rerollResetDate,
    int? totalMissionsCompleted,
    int? totalRerollsAllTime,
    int? chaosMissionsCompleted,
    int? questChainsCompleted,
    Map<String, int>? categoryCounts,
    int? appOpensToday,
    DateTime? appOpensResetDate,
    int? longestStreak,
    int? freezeTokens,
    int? freezeTokensEarned,
    int? missionsSaved,
  }) {
    return UserProgress(
      totalXp: totalXp ?? this.totalXp,
      streakDays: streakDays ?? this.streakDays,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      rerollsUsedToday: rerollsUsedToday ?? this.rerollsUsedToday,
      rerollResetDate: rerollResetDate ?? this.rerollResetDate,
      totalMissionsCompleted:
          totalMissionsCompleted ?? this.totalMissionsCompleted,
      totalRerollsAllTime: totalRerollsAllTime ?? this.totalRerollsAllTime,
      chaosMissionsCompleted:
          chaosMissionsCompleted ?? this.chaosMissionsCompleted,
      questChainsCompleted:
          questChainsCompleted ?? this.questChainsCompleted,
      categoryCounts: categoryCounts ?? this.categoryCounts,
      appOpensToday: appOpensToday ?? this.appOpensToday,
      appOpensResetDate: appOpensResetDate ?? this.appOpensResetDate,
      longestStreak: longestStreak ?? this.longestStreak,
      freezeTokens: freezeTokens ?? this.freezeTokens,
      freezeTokensEarned: freezeTokensEarned ?? this.freezeTokensEarned,
      missionsSaved: missionsSaved ?? this.missionsSaved,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalXp': totalXp,
        'streakDays': streakDays,
        'lastCompletedDate': lastCompletedDate?.toIso8601String(),
        'rerollsUsedToday': rerollsUsedToday,
        'rerollResetDate': rerollResetDate?.toIso8601String(),
        'totalMissionsCompleted': totalMissionsCompleted,
        'totalRerollsAllTime': totalRerollsAllTime,
        'chaosMissionsCompleted': chaosMissionsCompleted,
        'questChainsCompleted': questChainsCompleted,
        'categoryCounts': categoryCounts,
        'appOpensToday': appOpensToday,
        'appOpensResetDate': appOpensResetDate?.toIso8601String(),
        'longestStreak': longestStreak,
        'freezeTokens': freezeTokens,
        'freezeTokensEarned': freezeTokensEarned,
        'missionsSaved': missionsSaved,
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
        totalXp: json['totalXp'] ?? 0,
        streakDays: json['streakDays'] ?? 0,
        lastCompletedDate: json['lastCompletedDate'] != null
            ? DateTime.parse(json['lastCompletedDate'])
            : null,
        rerollsUsedToday: json['rerollsUsedToday'] ?? 0,
        rerollResetDate: json['rerollResetDate'] != null
            ? DateTime.parse(json['rerollResetDate'])
            : null,
        totalMissionsCompleted: json['totalMissionsCompleted'] ?? 0,
        totalRerollsAllTime: json['totalRerollsAllTime'] ?? 0,
        chaosMissionsCompleted: json['chaosMissionsCompleted'] ?? 0,
        questChainsCompleted: json['questChainsCompleted'] ?? 0,
        categoryCounts: json['categoryCounts'] != null
            ? Map<String, int>.from(json['categoryCounts'])
            : const {},
        appOpensToday: json['appOpensToday'] ?? 0,
        appOpensResetDate: json['appOpensResetDate'] != null
            ? DateTime.parse(json['appOpensResetDate'])
            : null,
        longestStreak: json['longestStreak'] ?? 0,
        freezeTokens: json['freezeTokens'] ?? 0,
        freezeTokensEarned: json['freezeTokensEarned'] ?? 0,
        missionsSaved: json['missionsSaved'] ?? 0,
      );
}

/// Did the player actually carry out the mission?
///
/// `null` on [CompletedMission.outcome] means the row predates outcome
/// tracking, which is why it is not defaulted to [done]: treating old
/// rows as successes would quietly inflate the follow-through figure.
enum MissionOutcome {
  done,
  partial,
  skipped;

  static MissionOutcome? parse(String? raw) {
    for (final o in values) {
      if (o.name == raw) return o;
    }
    return null;
  }

  /// Share of the mission's XP this outcome is worth.
  double get xpShare {
    switch (this) {
      case MissionOutcome.done:
        return 1;
      case MissionOutcome.partial:
        return 0.6;
      case MissionOutcome.skipped:
        return 0;
    }
  }

  /// A skipped mission is not an active day, so it must not touch the
  /// streak at all.
  bool get countsAsActivity => this != MissionOutcome.skipped;
}

/// One completed-mission history row.
class CompletedMission {
  final String missionId;
  final String title;
  final String emoji;
  final String categoryLabel;
  final int xpEarned;
  final DateTime completedAt;

  /// Null for rows saved before outcome tracking existed.
  final MissionOutcome? outcome;

  const CompletedMission({
    required this.missionId,
    required this.title,
    required this.emoji,
    required this.categoryLabel,
    required this.xpEarned,
    required this.completedAt,
    this.outcome,
  });

  Map<String, dynamic> toJson() => {
        'missionId': missionId,
        'title': title,
        'emoji': emoji,
        'categoryLabel': categoryLabel,
        'xpEarned': xpEarned,
        'completedAt': completedAt.toIso8601String(),
        'outcome': outcome?.name,
      };

  factory CompletedMission.fromJson(Map<String, dynamic> json) =>
      CompletedMission(
        missionId: json['missionId'],
        title: json['title'],
        emoji: json['emoji'],
        categoryLabel: json['categoryLabel'],
        xpEarned: json['xpEarned'],
        completedAt: DateTime.parse(json['completedAt']),
        outcome: MissionOutcome.parse(json['outcome']),
      );
}
