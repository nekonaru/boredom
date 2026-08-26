import 'mission.dart';

/// Metrik yang dipakai buat nentuin kapan sebuah achievement ke-unlock.
/// `special` dipakai buat achievement yang di-trigger langsung oleh sebuah
/// event (bukan dihitung dari angka progress), misalnya "selesai jam 11 malam".
enum AchievementMetric {
  totalMissions,
  streak,
  level,
  chaosMissions,
  rerollsAllTime,
  appOpensSingleDay,
  questChainsCompleted,
  categoryCount,
  special,
}

class Achievement {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final AchievementMetric metric;
  final int target;
  final MissionCategory? category; // hanya dipakai kalau metric == categoryCount

  const Achievement({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.metric,
    required this.target,
    this.category,
  });
}

/// Achievement yang sudah ke-unlock, plus kapan.
class UnlockedAchievement {
  final String achievementId;
  final DateTime unlockedAt;

  const UnlockedAchievement({required this.achievementId, required this.unlockedAt});

  Map<String, dynamic> toJson() => {
        'achievementId': achievementId,
        'unlockedAt': unlockedAt.toIso8601String(),
      };

  factory UnlockedAchievement.fromJson(Map<String, dynamic> json) =>
      UnlockedAchievement(
        achievementId: json['achievementId'],
        unlockedAt: DateTime.parse(json['unlockedAt']),
      );
}
