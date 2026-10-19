import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/mission.dart';
import '../models/user_progress.dart';
import '../providers/boredom_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/kit.dart';
import '../widgets/weekly_chart.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final pal = context.palette;
    final progress = context.select<BoredomProvider, UserProgress>(
      (p) => p.progress,
    );
    final weekCounts = context.select<BoredomProvider, List<int>>(
      (p) => p.last7DaysCounts,
    );
    final monthCounts = context.select<BoredomProvider, List<int>>(
      (p) => p.last30DaysCounts,
    );
    final avgXp = context.select<BoredomProvider, double>(
      (p) => p.avgXpPerActiveDay,
    );
    final bestDay = context.select<BoredomProvider, int?>(
      (p) => p.busiestWeekday,
    );
    // Both derive from `history`, which is not part of `progress`, so they
    // need their own selectors or the new cards would never update.
    final tracked = context.select<BoredomProvider, int>(
      (p) => p.trackedCompletions,
    );
    final rate = context.select<BoredomProvider, double?>(
      (p) => p.followThroughRate,
    );

    final categoryCounts = progress.categoryCounts;
    final maxCount = categoryCounts.values.isEmpty
        ? 1
        : categoryCounts.values.reduce((a, b) => a > b ? a : b);

    // Every category is drawn, including chaos. Chaos Mode can roll the
    // five chaos-only missions, and those carry `category: chaos`, so
    // `categoryCounts['chaos']` really is written. Filtering them out made
    // the bars sum to less than the "missions completed" total above them.
    // (The Profile mute chips do exclude chaos, which is correct there:
    // chaos is a mode, not something to silence.)
    final sortedCategories = MissionCategory.values.toList()
      ..sort((a, b) =>
          (categoryCounts[b.name] ?? 0).compareTo(categoryCounts[a.name] ?? 0));

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppKit.lg, AppKit.md, AppKit.lg, AppKit.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.statsTitle,
              style: TextStyle(color: pal.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppKit.xl),
            Row(
              children: [
                Expanded(
                  child: AppKit.metricCard(context,
                    label: s.mTotalMissions,
                    value: '${progress.totalMissionsCompleted}',
                    emoji: '🎯',
                  ),
                ),
                const SizedBox(width: AppKit.md),
                Expanded(
                  child: AppKit.metricCard(context,
                    label: s.mLongestStreak,
                    value: s.days(progress.longestStreak),
                    emoji: '🔥',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppKit.md),
            Row(
              children: [
                Expanded(
                  child: AppKit.metricCard(context,
                    label: s.mTotalRerolls,
                    value: '${progress.totalRerollsAllTime}',
                    emoji: '🎲',
                  ),
                ),
                const SizedBox(width: AppKit.md),
                Expanded(
                  child: AppKit.metricCard(context,
                    label: s.mChaos,
                    value: '${progress.chaosMissionsCompleted}',
                    emoji: '☢️',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppKit.md),
            // Null means nothing has been tracked yet, which is different
            // from a real 0 percent, so it renders as a dash.
            Row(
              children: [
                Expanded(
                  child: AppKit.metricCard(context,
                    label: s.mFollowThrough,
                    value: rate == null
                        ? '—'
                        : '${(rate * 100).round()}%',
                    emoji: '🎖️',
                  ),
                ),
                const SizedBox(width: AppKit.md),
                Expanded(
                  child: AppKit.metricCard(context,
                    label: s.mFollowThroughDesc,
                    value: '$tracked',
                    emoji: '📋',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppKit.md),
            Row(
              children: [
                Expanded(
                  child: AppKit.metricCard(context,
                    label: s.mAvgXp,
                    value: avgXp.toStringAsFixed(1),
                    emoji: '⚡',
                  ),
                ),
                const SizedBox(width: AppKit.md),
                Expanded(
                  child: AppKit.metricCard(context,
                    label: s.mBestDay,
                    value: bestDay == null ? '-' : s.weekdayName(bestDay),
                    emoji: '📅',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppKit.xxl),
            AppKit.sectionHeader(context, s, title: s.weekTitle),
            const SizedBox(height: AppKit.md),
            RepaintBoundary(
              child: WeeklyChart(counts: weekCounts),
            ),
            const SizedBox(height: AppKit.xxl),
            AppKit.sectionHeader(context, s, title: s.monthTitle),
            const SizedBox(height: AppKit.md),
            RepaintBoundary(
              child: MonthlyChart(counts: monthCounts),
            ),
            const SizedBox(height: AppKit.xxl),
            AppKit.sectionHeader(context, s, title: s.perCategory),
            const SizedBox(height: AppKit.md),
            if (progress.totalMissionsCompleted == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppKit.xl),
                child: Center(
                  child: Text(
                    s.statsEmpty,
                    style: TextStyle(color: pal.textSecondary),
                  ),
                ),
              )
            else
              ...sortedCategories.map((cat) {
                final count = categoryCounts[cat.name] ?? 0;
                final ratio = maxCount == 0 ? 0.0 : count / maxCount;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppKit.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(cat.labelFor(s.code),
                              style: TextStyle(color: pal.textPrimary, fontSize: 13)),
                          Text('$count',
                              style: TextStyle(color: pal.textSecondary, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: AppKit.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppKit.rSm),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: AppKit.md,
                          backgroundColor: pal.emptyBar,
                          valueColor: AlwaysStoppedAnimation(pal.accent),
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
