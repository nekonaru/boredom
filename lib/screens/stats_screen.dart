import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/mission.dart';
import '../models/user_progress.dart';
import '../providers/boredom_provider.dart';
import '../providers/theme_provider.dart';
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
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.statsTitle,
              style: TextStyle(color: pal.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(label: s.mTotalMissions, value: '${progress.totalMissionsCompleted}', emoji: '🎯'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(label: s.mLongestStreak, value: s.days(progress.longestStreak), emoji: '🔥'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(label: s.mTotalRerolls, value: '${progress.totalRerollsAllTime}', emoji: '🎲'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(label: s.mChaos, value: '${progress.chaosMissionsCompleted}', emoji: '☢️'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: s.mAvgXp,
                    value: avgXp.toStringAsFixed(1),
                    emoji: '⚡',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: s.mBestDay,
                    value: bestDay == null ? '-' : s.weekdayName(bestDay),
                    emoji: '📅',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              s.weekTitle,
              style: TextStyle(color: pal.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            RepaintBoundary(
              child: WeeklyChart(counts: weekCounts),
            ),
            const SizedBox(height: 28),
            Text(
              s.monthTitle,
              style: TextStyle(color: pal.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            RepaintBoundary(
              child: MonthlyChart(counts: monthCounts),
            ),
            const SizedBox(height: 28),
            Text(
              s.perCategory,
              style: TextStyle(color: pal.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (progress.totalMissionsCompleted == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  s.statsEmpty,
                  style: TextStyle(color: pal.textSecondary),
                ),
              )
            else
              ...sortedCategories.map((cat) {
                final count = categoryCounts[cat.name] ?? 0;
                final ratio = maxCount == 0 ? 0.0 : count / maxCount;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 10,
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

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  const _MetricCard({required this.label, required this.value, required this.emoji});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: pal.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(color: pal.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: pal.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
