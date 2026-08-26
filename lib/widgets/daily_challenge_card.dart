import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/boredom_provider.dart';
import '../utils/app_theme.dart';

class DailyChallengeCard extends StatelessWidget {
  const DailyChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BoredomProvider>();
    final challenge = provider.currentDailyChallenge;
    if (challenge == null) return const SizedBox.shrink();

    final completed = provider.dailyChallengeCompleted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: completed ? AppColors.success.withOpacity(0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: completed ? AppColors.success.withOpacity(0.4) : Colors.white12,
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
                const Text(
                  "TODAY'S CHALLENGE",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  challenge.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  challenge.description,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          completed
              ? const Icon(Icons.check_circle, color: AppColors.success)
              : ElevatedButton(
                  onPressed: () async {
                    await provider.completeDailyChallenge();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Challenge selesai! +${challenge.rewardXp} XP 🎉'),
                          backgroundColor: AppColors.success,
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
