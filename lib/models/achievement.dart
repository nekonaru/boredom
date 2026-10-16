import 'mission.dart';

/// Metric used to decide when an achievement unlocks.
/// `special` marks event-triggered achievements (not derived from a counter),
/// for example "finished after 11 PM".
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
  final String description;
  final String? titleId;
  final String? descriptionId;
  final String emoji;
  final AchievementMetric metric;
  final int target;
  final MissionCategory? category; // only used when metric == categoryCount

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.titleId,
    this.descriptionId,
    required this.emoji,
    required this.metric,
    required this.target,
    this.category,
  });
}

/// An unlocked achievement, plus when it happened.
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
