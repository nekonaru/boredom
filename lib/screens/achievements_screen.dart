import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/achievement.dart';
import '../models/user_progress.dart';
import '../providers/boredom_provider.dart';
import '../providers/theme_provider.dart';
import '../services/achievement_catalog.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/kit.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final pal = context.palette;
    // Cache unlocked ids so the screen does not rebuild everything on every
    // provider notification (a fresh Set per build never compares equal).
    final unlockedIds = context.select<BoredomProvider, Set<String>>(
      (p) => p.achievements.map((a) => a.achievementId).toSet(),
    );
    final progress = context.select<BoredomProvider, UserProgress>(
      (p) => p.progress,
    );
    final actions = context.read<BoredomProvider>();
    const all = AchievementCatalog.all;
    final unlockedCount = all.where((a) => unlockedIds.contains(a.id)).length;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppKit.lg, AppKit.md, AppKit.lg, 0),
            sliver: SliverList.list(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      s.achievementsTitle,
                      style: TextStyle(
                        color: pal.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppKit.sm,
                        vertical: AppKit.xs,
                      ),
                      decoration: BoxDecoration(
                        color: pal.accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unlockedCount/${all.length}',
                        style: TextStyle(
                          color: pal.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppKit.xl),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppKit.lg),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppKit.md,
                mainAxisSpacing: AppKit.md,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final a = all[index];
                  return AchievementBadge(
                    achievement: a,
                    unlocked: unlockedIds.contains(a.id),
                  );
                },
                childCount: all.length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppKit.lg,
              AppKit.xxl,
              AppKit.lg,
              0,
            ),
            sliver: SliverList.list(
              children: [
                Text(
                  s.progressTitle,
                  style: TextStyle(
                    color: pal.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppKit.md),
                ...all
                    .where((a) => a.metric != AchievementMetric.special)
                    .map((a) {
                  final current =
                      actions.achievementProgress(
                    a,
                    missions: progress.totalMissionsCompleted,
                    level: progress.level,
                  );
                  final ratio = a.target == 0
                      ? 0.0
                      : (current / a.target).clamp(0.0, 1.0);
                  final unlocked = unlockedIds.contains(a.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppKit.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${a.emoji} ${localizedTitle(
                                en: a.title,
                                id: a.titleId,
                                code: s.code,
                              )}',
                              style: TextStyle(
                                color: pal.textPrimary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '$current/${a.target}',
                              style: TextStyle(
                                color: pal.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppKit.xs),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppKit.rSm),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: AppKit.md,
                            backgroundColor: pal.emptyBar,
                            valueColor: AlwaysStoppedAnimation(
                              unlocked ? pal.success : pal.accent,
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
          const SliverPadding(
            padding: EdgeInsets.only(bottom: AppKit.xxl),
          ),
        ],
      ),
    );
  }
}
