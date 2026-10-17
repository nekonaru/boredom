import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/daily_challenge.dart';
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
                    final provider = context.read<BoredomProvider>();
                    await provider.completeDailyChallenge();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(s.challengeDone(challenge.rewardXp)),
                          backgroundColor: pal.success,
                          action: provider.canUndo
                              ? SnackBarAction(
                                  label: s.undoAction,
                                  textColor: Colors.white,
                                  onPressed: () async {
                                    final ok = await provider.undoLastAction();
                                    if (!context.mounted) return;
                                    await provider.reopenDailyChallenge();
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
                    }
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
