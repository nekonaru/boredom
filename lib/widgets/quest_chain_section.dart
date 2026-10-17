import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/achievement.dart';
import '../models/quest_chain.dart';
import '../providers/boredom_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/feedback.dart';

class QuestChainSection extends StatelessWidget {
  const QuestChainSection({super.key});

  @override
  Widget build(BuildContext context) {
    final chain = context.select<BoredomProvider, QuestChain?>(
      (p) => p.currentChain,
    );

    if (chain == null) {
      return const _NoActiveChain();
    }

    final s = context.str;
    final pal = context.palette;
    final code = s.code;
    final stepIndex = context.select<BoredomProvider, int>(
      (p) => p.currentChainStepIndex,
    );
    final step = chain.steps[stepIndex];
    final isLastStep = stepIndex == chain.steps.length - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: pal.accent.withValues(alpha: 0.3)),
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
                  localizedTitle(en: chain.title, id: chain.titleId, code: code),
                  style: TextStyle(
                    color: pal.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                s.stepOf(stepIndex + 1, chain.steps.length),
                style: TextStyle(color: pal.textSecondary, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (stepIndex) / chain.steps.length,
              minHeight: 6,
              backgroundColor: pal.emptyBar,
              valueColor: AlwaysStoppedAnimation(pal.accent),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            localizedTitle(en: step.title, id: step.titleId, code: code),
            style: TextStyle(color: pal.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            localizedTitle(en: step.description, id: step.descriptionId, code: code),
            style: TextStyle(color: pal.textSecondary, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _confirmAbandon(context, s),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: pal.danger,
                    side: BorderSide(color: pal.danger),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(s.chainCancel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () async {
                    buzzIfEnabled(context);
                    final provider = context.read<BoredomProvider>();
                    final unlocked = await provider.completeCurrentChainStep();
                    if (!context.mounted) return;
                    final undo = provider.canUndo;
                    if (isLastStep) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            s.chainComplete(
                              localizedTitle(en: chain.title, id: chain.titleId, code: code),
                              chain.rewardXp,
                            ),
                          ),
                          backgroundColor: pal.success,
                          action: undo
                              ? SnackBarAction(
                                  label: s.undoAction,
                                  textColor: Colors.white,
                                  onPressed: () async {
                                    final ok = await provider.undoLastAction();
                                    if (context.mounted && ok) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(s.undoDone)),
                                      );
                                    }
                                  },
                                )
                              : null,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(s.chainStepNext)),
                      );
                    }
                    _showAchievementSnackbars(context, s, unlocked);
                  },
                  child: Text(isLastStep ? s.chainFinish : s.chainStepDone),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmAbandon(BuildContext context, AppStrings s) {
    final pal = context.palette;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: pal.surfaceElevated,
        title: Text(s.abandonTitle, style: TextStyle(color: pal.textPrimary)),
        content: Text(s.abandonBody, style: TextStyle(color: pal.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(s.abandonKeep)),
          TextButton(
            onPressed: () {
              context.read<BoredomProvider>().abandonChain();
              Navigator.of(context).pop();
            },
            child: Text(s.abandonConfirm, style: TextStyle(color: pal.danger)),
          ),
        ],
      ),
    );
  }

  void _showAchievementSnackbars(
    BuildContext context,
    AppStrings s,
    List<Achievement> unlocked,
  ) {
    final pal = context.palette;
    for (final a in unlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${s.achievementSnack} ${a.emoji} ${localizedTitle(en: a.title, id: a.titleId, code: s.code)}',
          ),
          backgroundColor: pal.accent,
        ),
      );
    }
  }
}

class _NoActiveChain extends StatelessWidget {
  const _NoActiveChain();

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final pal = context.palette;
    final code = s.code;
    final chains = context.select<BoredomProvider, List<QuestChain>>(
      (p) => p.availableChains,
    );
    final actions = context.read<BoredomProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🧩 ${s.chainsTitle}',
            style: TextStyle(color: pal.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            s.chainsDesc,
            style: TextStyle(color: pal.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ...chains.map(
            (chain) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => actions.startChain(chain.id),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: pal.surfaceElevated,
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
                            Text(
                              localizedTitle(en: chain.title, id: chain.titleId, code: code),
                              style: TextStyle(
                                color: pal.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Text(
                                s.chainStepsReward(
                                  chain.steps.length,
                                  chain.rewardXp,
                                ),
                                style: TextStyle(color: pal.textSecondary, fontSize: 11)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: pal.textSecondary),
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
