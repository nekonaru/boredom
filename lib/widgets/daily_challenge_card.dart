import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/daily_challenge.dart';
import '../models/user_progress.dart';
import '../providers/boredom_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/feedback.dart';

class DailyChallengeCard extends StatelessWidget {
  const DailyChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final pal = context.palette;
    final challenge = context.select<BoredomProvider, DailyChallenge?>(
      (p) => p.currentDailyChallenge,
    );
    if (challenge == null) return const SizedBox.shrink();

    final completed = context.select<BoredomProvider, bool>(
      (p) => p.dailyChallengeCompleted,
    );
    final code = s.code;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: completed ? pal.success.withValues(alpha: 0.1) : pal.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: completed
              ? pal.success.withValues(alpha: 0.4)
              : pal.textSecondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Text(challenge.emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.todayChallenge,
                  style: TextStyle(
                    color: pal.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  localizedTitle(en: challenge.title, id: challenge.titleId, code: code),
                  style: TextStyle(
                    color: pal.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  localizedTitle(
                    en: challenge.description,
                    id: challenge.descriptionId,
                    code: code,
                  ),
                  style: TextStyle(color: pal.textSecondary, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          completed
              ? Icon(Icons.check_circle, color: pal.success)
              : ElevatedButton(
                  onPressed: () async {
                    buzzIfEnabled(context);
                    final outcome = await showModalBottomSheet<MissionOutcome>(
                      context: context,
                      isScrollControlled: true,
                      builder: (sheetContext) => SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                s.outcomeQuestion,
                                style: TextStyle(
                                  color: pal.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _OutcomeOption(
                                label: s.outcomeDone,
                                emoji: '✅',
                                onTap: () => Navigator.of(sheetContext)
                                    .pop(MissionOutcome.done),
                              ),
                              _OutcomeOption(
                                label: s.outcomePartial,
                                emoji: '🟡',
                                onTap: () => Navigator.of(sheetContext)
                                    .pop(MissionOutcome.partial),
                              ),
                              _OutcomeOption(
                                label: s.outcomeSkipped,
                                emoji: '⭕️',
                                onTap: () => Navigator.of(sheetContext)
                                    .pop(MissionOutcome.skipped),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    // Dismissed without answering: record nothing rather than
                    // assuming a success.
                    if (outcome == null || !context.mounted) return;
                    final provider = context.read<BoredomProvider>();
                    await provider.completeDailyChallenge(outcome);
                    if (!context.mounted) return;
                    final gained = provider.lastXpGained ?? 0;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          gained > 0
                              ? s.challengeDone(gained)
                              : s.skippedSnack,
                        ),
                        backgroundColor:
                            gained > 0 ? pal.success : pal.textSecondary,
                        action: provider.canUndo
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
                    provider.clearLastXpGained();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  child: Text('+${challenge.rewardXp}'),
                ),
        ],
      ),
    );
  }
}

/// One tappable outcome row in the daily-challenge bottom sheet.
class _OutcomeOption extends StatelessWidget {
  final String label;
  final String emoji;
  final VoidCallback onTap;
  const _OutcomeOption({
    required this.label,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: pal.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: pal.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
