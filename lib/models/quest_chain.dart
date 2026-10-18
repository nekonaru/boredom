import 'mission.dart';

class QuestStep {
  final String title;
  final String description;
  final String? titleId;
  final String? descriptionId;

  const QuestStep({
    required this.title,
    required this.description,
    this.titleId,
    this.descriptionId,
  });
}

class QuestChain {
  final String id;
  final String title;
  final String description;
  final String? titleId;
  final String? descriptionId;
  final String emoji;
  final List<QuestStep> steps;
  final int rewardXp;

  /// Per-category bucket a finished chain counts towards. Catalog-only:
  /// the stored QuestChainProgress keeps just the chain id and step index.
  final MissionCategory category;

  const QuestChain({
    required this.id,
    required this.title,
    required this.description,
    this.titleId,
    this.descriptionId,
    required this.emoji,
    required this.steps,
    required this.rewardXp,
    this.category = MissionCategory.selfImprovement,
  });
}

/// Progress on one active quest chain.
class QuestChainProgress {
  final String chainId;
  final int currentStepIndex; // 0-based, index of the next step to do

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
