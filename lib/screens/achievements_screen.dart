import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/achievement.dart';
import '../providers/boredom_provider.dart';
import '../providers/theme_provider.dart';
import '../services/achievement_catalog.dart';
import '../widgets/achievement_badge.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final pal = context.palette;
    final unlockedIds = context.select<BoredomProvider, Set<String>>(
      (p) => p.achievements.map((a) => a.achievementId).toSet(),
    );
    final progress = context.select<BoredomProvider, ({int missions, int xp})>(
      (p) => (missions: p.progress.totalMissionsCompleted, xp: p.progress.totalXp),
    );
    final actions = context.read<BoredomProvider>();
    const all = AchievementCatalog.all;
    final unlockedCount = all.where((a) => unlockedIds.contains(a.id)).length;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  s.achievementsTitle,
                  style: TextStyle(color: pal.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: pal.accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$unlockedCount/${all.length}',
                    style: TextStyle(color: pal.accent, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: all
                  .map((a) => AchievementBadge(
                        achievement: a,
                        unlocked: unlockedIds.contains(a.id),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            Text(
              s.progressTitle,
              style: TextStyle(color: pal.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...all
                .where((a) => a.metric != AchievementMetric.special)
                .map((a) {
              final current =
                  actions.achievementProgress(a, missions: progress.missions, xp: progress.xp);
              final ratio = a.target == 0
                  ? 0.0
                  : (current / a.target).clamp(0.0, 1.0);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${a.emoji} ${localizedTitle(en: a.title, id: a.titleId, code: s.code)}',
                          style: TextStyle(color: pal.textPrimary, fontSize: 12),
                        ),
                        Text(
                          '$current/${a.target}',
                          style: TextStyle(color: pal.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 6,
                        backgroundColor: pal.emptyBar,
                        valueColor: AlwaysStoppedAnimation(
                          unlockedIds.contains(a.id) ? pal.success : pal.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
