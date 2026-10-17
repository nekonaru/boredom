import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/user_progress.dart';
import '../providers/boredom_provider.dart';
import '../providers/theme_provider.dart';

/// Weekly recap strip shown on Home: missions completed, XP earned,
/// and current streak, so progress is visible without opening Stats.
class WeeklySummaryStrip extends StatelessWidget {
  const WeeklySummaryStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final pal = context.palette;
    final summary =
        context.select<BoredomProvider, ({int missions, int xp})>(
      (p) => p.last7DaysSummary,
    );
    final streak = context.select<BoredomProvider, UserProgress>(
      (p) => p.progress,
    ).streakDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.weeklySummary,
            style: TextStyle(
              color: pal.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Metric(
                emoji: '🎯',
                value: '${summary.missions}',
                label: s.summaryMissions(summary.missions),
                color: pal.accent,
              ),
              const SizedBox(width: 18),
              _Metric(
                emoji: '⚡',
                value: '+${summary.xp}',
                label: 'XP',
                color: pal.success,
              ),
              const SizedBox(width: 18),
              _Metric(
                emoji: '🔥',
                value: '$streak',
                label: s.days(streak),
                color: pal.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;
  const _Metric({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$emoji $value', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: pal.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}