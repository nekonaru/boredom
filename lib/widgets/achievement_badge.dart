import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../utils/app_theme.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;

  const AchievementBadge({super.key, required this.achievement, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked ? AppColors.accent.withOpacity(0.12) : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unlocked ? AppColors.accent.withOpacity(0.5) : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: unlocked ? 1 : 0.35,
            child: Text(achievement.emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 8),
          Text(
            unlocked ? achievement.title : '???',
            style: TextStyle(
              color: unlocked ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unlocked ? achievement.description : 'Belum ke-unlock',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.3),
          ),
        ],
      ),
    );
  }
}
