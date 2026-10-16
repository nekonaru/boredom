import 'mission.dart';

/// A user-created mission. Unlike catalog missions it has no filter tags:
/// it is always eligible and completes for its own XP reward.
class CustomMission {
  final String id;
  final String title;
  final String description;
  final int baseXp;
  final DateTime createdAt;

  const CustomMission({
    required this.id,
    required this.title,
    required this.description,
    required this.baseXp,
    required this.createdAt,
  });

  MissionCategory get category => MissionCategory.custom;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'baseXp': baseXp,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CustomMission.fromJson(Map<String, dynamic> json) => CustomMission(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        baseXp: (json['baseXp'] as num?)?.toInt() ?? 20,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
