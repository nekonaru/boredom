class QuestStep {
  final String title;
  final String description;

  const QuestStep({required this.title, required this.description});
}

class QuestChain {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final List<QuestStep> steps;
  final int rewardXp;

  const QuestChain({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.steps,
    required this.rewardXp,
  });
}

/// Progress user di satu quest chain yang lagi aktif.
class QuestChainProgress {
  final String chainId;
  final int currentStepIndex; // 0-based, index step yang harus dikerjain berikutnya

  const QuestChainProgress({required this.chainId, required this.currentStepIndex});

  Map<String, dynamic> toJson() => {
        'chainId': chainId,
        'currentStepIndex': currentStepIndex,
      };

  factory QuestChainProgress.fromJson(Map<String, dynamic> json) =>
      QuestChainProgress(
        chainId: json['chainId'],
        currentStepIndex: json['currentStepIndex'] ?? 0,
      );

  QuestChainProgress copyWith({int? currentStepIndex}) => QuestChainProgress(
        chainId: chainId,
        currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      );
}
