import 'mission.dart';

/// A user-created mission. Unlike catalog missions it has no filter tags:
/// it is always eligible and completes for its own XP reward.
class CustomMission {
  final String id;
  final String title;
  final String description;
  final int baseXp;
  final DateTime createdAt;

  /// Optional user-defined category. Empty means the default 'Custom'.
  final String category;

  /// Soft-deleted missions are hidden from the UI but kept in storage so
  /// the history they produced still makes sense.
  final bool archived;

  const CustomMission({
    required this.id,
    required this.title,
    required this.description,
    required this.baseXp,
    required this.createdAt,
    this.category = '',
    this.archived = false,
  });

  MissionCategory get missionCategory =>
      category.isEmpty ? MissionCategory.custom : MissionCategory.custom;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'baseXp': baseXp,
        'createdAt': createdAt.toIso8601String(),
        'category': category,
        'archived': archived,
      };

  factory CustomMission.fromJson(Map<String, dynamic> json) => CustomMission(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        baseXp: (json['baseXp'] as num?)?.toInt() ?? 20,
        createdAt: DateTime.parse(json['createdAt'] as String),
        category: json['category'] as String? ?? '',
        archived: json['archived'] as bool? ?? false,
      );

  CustomMission copyWith({
    String? title,
    String? description,
    int? baseXp,
    String? category,
    bool? archived,
  }) =>
      CustomMission(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        baseXp: baseXp ?? this.baseXp,
        createdAt: createdAt,
        category: category ?? this.category,
        archived: archived ?? this.archived,
      );
}

/// A user-defined category for custom missions. Stored separately so the
/// user can rename or recolour it without touching individual missions.
class CustomCategory {
  final String id;
  final String name;
  final String emoji;
  final DateTime createdAt;

  const CustomCategory({
    required this.id,
    required this.name,
    this.emoji = '⭐',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CustomCategory.fromJson(Map<String, dynamic> json) => CustomCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String? ?? '⭐',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
