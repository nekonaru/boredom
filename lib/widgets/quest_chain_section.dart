import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../providers/boredom_provider.dart';
import '../utils/app_theme.dart';

class QuestChainSection extends StatelessWidget {
  const QuestChainSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BoredomProvider>();
    final chain = provider.currentChain;

    if (chain == null) {
      return _NoActiveChain(provider: provider);
    }

    final stepIndex = provider.currentChainStepIndex;
    final step = chain.steps[stepIndex];
    final isLastStep = stepIndex == chain.steps.length - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(chain.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  chain.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                'Step ${stepIndex + 1}/${chain.steps.length}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (stepIndex) / chain.steps.length,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            step.title,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            step.description,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _confirmAbandon(context, provider),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Batalkan'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () async {
                    final unlocked = await provider.completeCurrentChainStep();
                    if (!context.mounted) return;
                    if (isLastStep) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${chain.title} tuntas! +${chain.rewardXp} XP 🎉'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Step selesai, lanjut ke berikutnya!')),
                      );
                    }
                    _showAchievementSnackbars(context, unlocked);
                  },
                  child: Text(isLastStep ? 'SELESAIKAN CHAIN' : 'STEP SELESAI'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmAbandon(BuildContext context, BoredomProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Batalkan quest chain?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Progress chain ini akan hilang.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Nggak jadi')),
          TextButton(
            onPressed: () {
              provider.abandonChain();
              Navigator.of(context).pop();
            },
            child: const Text('Batalkan', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _showAchievementSnackbars(BuildContext context, List<Achievement> unlocked) {
    for (final a in unlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Achievement unlocked: ${a.emoji} ${a.title}'),
          backgroundColor: AppColors.accent,
        ),
      );
    }
  }
}

class _NoActiveChain extends StatelessWidget {
  final BoredomProvider provider;
  const _NoActiveChain({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🧩 Quest Chains',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          const Text(
            'Rantai misi bertahap dengan reward XP besar di akhir.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ...provider.availableChains.map(
            (chain) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => provider.startChain(chain.id),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Text(chain.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(chain.title,
                                style: const TextStyle(
                                    color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                            Text('${chain.steps.length} step · +${chain.rewardXp} XP',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
