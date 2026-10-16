import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/achievement.dart';
import '../providers/theme_provider.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;

  const AchievementBadge({super.key, required this.achievement, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final pal = context.palette;
    final code = s.code;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked ? pal.accent.withValues(alpha: 0.12) : pal.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unlocked
              ? pal.accent.withValues(alpha: 0.5)
              : pal.textSecondary.withValues(alpha: 0.3),
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
            unlocked
                ? localizedTitle(en: achievement.title, id: achievement.titleId, code: code)
                : s.lockedName,
            style: TextStyle(
              color: unlocked ? pal.textPrimary : pal.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unlocked
                ? localizedTitle(
                    en: achievement.description,
                    id: achievement.descriptionId,
                    code: code,
                  )
                : s.lockedDesc,
            style: TextStyle(color: pal.textSecondary, fontSize: 11, height: 1.3),
          ),
        ],
      ),
    );
  }
}
