import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mission.dart';
import '../providers/boredom_provider.dart';
import '../utils/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BoredomProvider>();
    final progress = provider.progress;

    final categoryCounts = progress.categoryCounts;
    final maxCount = categoryCounts.values.isEmpty
        ? 1
        : categoryCounts.values.reduce((a, b) => a > b ? a : b);

    // Urutkan semua kategori (termasuk yang masih 0) biar chart konsisten.
    final sortedCategories = MissionCategory.values.where((c) => c != MissionCategory.chaos).toList()
      ..sort((a, b) =>
          (categoryCounts[b.name] ?? 0).compareTo(categoryCounts[a.name] ?? 0));

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(label: 'Total Misi', value: '${progress.totalMissionsCompleted}', emoji: '🎯'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(label: 'Longest Streak', value: '${progress.longestStreak} hari', emoji: '🔥'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(label: 'Total Reroll', value: '${progress.totalRerollsAllTime}', emoji: '🎲'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(label: 'Chaos Missions', value: '${progress.chaosMissionsCompleted}', emoji: '☢️'),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Misi per Kategori',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (progress.totalMissionsCompleted == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Belum ada data. Selesaikan beberapa misi dulu.',
                  style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.8)),
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
                          Text(cat.label,
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
