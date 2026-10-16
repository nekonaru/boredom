class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String? titleId;
  final String? descriptionId;
  final String emoji;
  final int rewardXp;

  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    this.titleId,
    this.descriptionId,
    required this.emoji,
    required this.rewardXp,
  });
}

/// Daily state: which challenge is active today and whether it is done.
class DailyChallengeState {
  final DateTime date;
  final String challengeId;
  final bool completed;

  const DailyChallengeState({
    required this.date,
    required this.challengeId,
    required this.completed,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'challengeId': challengeId,
        'completed': completed,
      };

  factory DailyChallengeState.fromJson(Map<String, dynamic> json) =>
      DailyChallengeState(
        date: DateTime.parse(json['date']),
        challengeId: json['challengeId'],
        completed: json['completed'] ?? false,
      );

  DailyChallengeState copyWith({bool? completed}) => DailyChallengeState(
        date: date,
        challengeId: challengeId,
        completed: completed ?? this.completed,
      );
}
