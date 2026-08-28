import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/boredom_provider.dart';
import '../services/achievement_catalog.dart';
import '../utils/app_theme.dart';
import '../widgets/achievement_badge.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unlockedIds =
        context.watch<BoredomProvider>().achievements.map((a) => a.achievementId).toSet();
    final all = AchievementCatalog.all;
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
                const Text(
                  'Achievements',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$unlockedCount/${all.length}',
                    style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12),
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
                  .map((a) => AchievementBadge(achievement: a, unlocked: unlockedIds.contains(a.id)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
