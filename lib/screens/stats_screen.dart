import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/mission.dart';
import '../models/user_progress.dart';
import '../providers/boredom_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/weekly_chart.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final progress = context.select<BoredomProvider, UserProgress>(
      (p) => p.progress,
    );
    final weekCounts = context.select<BoredomProvider, List<int>>(
      (p) => p.last7DaysCounts,
    );

    final categoryCounts = progress.categoryCounts;
    final maxCount = categoryCounts.values.isEmpty
        ? 1
        : categoryCounts.values.reduce((a, b) => a > b ? a : b);

    // Sort every category (including zeros) so the chart stays consistent.
    final sortedCategories = MissionCategory.values
        .where((c) => c != MissionCategory.chaos && c != MissionCategory.custom)
        .toList()
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
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
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
            const SizedBox(height: 28),
            Text(
              s.weekTitle,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            RepaintBoundary(
              child: WeeklyChart(counts: weekCounts),
            ),
            const SizedBox(height: 28),
            Text(
              s.perCategory,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (progress.totalMissionsCompleted == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  s.statsEmpty,
                  style: const TextStyle(color: AppColors.textSecondary),
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
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                          Text('$count',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 10,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation(AppColors.accent),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
