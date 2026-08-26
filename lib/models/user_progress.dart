/// Nama-nama level absurd, biar berasa game bukan aplikasi produktivitas.
class LevelTitles {
  static const Map<int, String> _milestones = {
    1: 'Bored',
    5: 'Slightly Productive',
    10: 'Touching Grass',
    20: 'Main Character',
    35: 'Certified Not Boring',
    50: 'Chronically Unbored',
    75: 'Boredom Slayer',
    100: 'The Final Boss of Boredom',
  };

  static String titleFor(int level) {
    String title = 'Bored';
    for (final entry in _milestones.entries) {
      if (level >= entry.key) title = entry.value;
    }
    return title;
  }
}

/// Progress user: level dihitung dari total XP dengan kurva sederhana.
class UserProgress {
  final int totalXp;
  final int streakDays;
  final DateTime? lastCompletedDate;
  final int rerollsUsedToday;
  final DateTime? rerollResetDate;
  final int totalMissionsCompleted;

  const UserProgress({
    this.totalXp = 0,
    this.streakDays = 0,
    this.lastCompletedDate,
    this.rerollsUsedToday = 0,
    this.rerollResetDate,
    this.totalMissionsCompleted = 0,
  });

  // Kurva level: makin tinggi level, makin butuh banyak XP.
  // Level N butuh total XP = 50 * N * (N+1) / 2 (segitiga, biar smooth).
  static int xpNeededForLevel(int level) => (50 * level * (level + 1)) ~/ 2;

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

  String get levelTitle => LevelTitles.titleFor(level);

  UserProgress copyWith({
    int? totalXp,
    int? streakDays,
    DateTime? lastCompletedDate,
    int? rerollsUsedToday,
    DateTime? rerollResetDate,
    int? totalMissionsCompleted,
  }) {
    return UserProgress(
      totalXp: totalXp ?? this.totalXp,
      streakDays: streakDays ?? this.streakDays,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      rerollsUsedToday: rerollsUsedToday ?? this.rerollsUsedToday,
      rerollResetDate: rerollResetDate ?? this.rerollResetDate,
      totalMissionsCompleted:
          totalMissionsCompleted ?? this.totalMissionsCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalXp': totalXp,
        'streakDays': streakDays,
        'lastCompletedDate': lastCompletedDate?.toIso8601String(),
        'rerollsUsedToday': rerollsUsedToday,
        'rerollResetDate': rerollResetDate?.toIso8601String(),
        'totalMissionsCompleted': totalMissionsCompleted,
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
      );
}

/// Satu baris riwayat misi yang sudah selesai.
class CompletedMission {
  final String missionId;
  final String title;
  final String emoji;
  final String categoryLabel;
  final int xpEarned;
  final DateTime completedAt;

  const CompletedMission({
    required this.missionId,
    required this.title,
    required this.emoji,
    required this.categoryLabel,
    required this.xpEarned,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'missionId': missionId,
        'title': title,
        'emoji': emoji,
        'categoryLabel': categoryLabel,
        'xpEarned': xpEarned,
        'completedAt': completedAt.toIso8601String(),
      };

  factory CompletedMission.fromJson(Map<String, dynamic> json) =>
      CompletedMission(
        missionId: json['missionId'],
        title: json['title'],
        emoji: json['emoji'],
        categoryLabel: json['categoryLabel'],
        xpEarned: json['xpEarned'],
        completedAt: DateTime.parse(json['completedAt']),
      );
}
