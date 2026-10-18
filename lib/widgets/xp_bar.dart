import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/user_progress.dart';
import '../providers/theme_provider.dart';

class XpBar extends StatelessWidget {
  final UserProgress progress;
  const XpBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: pal.accent.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'LV.${progress.level}',
            style: TextStyle(
              color: pal.accent,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                progress.levelTitleFor(context.str.code),
                style: TextStyle(
                  color: pal.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress.levelProgress.clamp(0, 1),
                  minHeight: 6,
                  backgroundColor: pal.emptyBar,
                  valueColor: AlwaysStoppedAnimation(pal.accent),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${progress.xpIntoCurrentLevel}/${progress.xpNeededForNextLevel} XP',
          style: TextStyle(color: pal.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}
