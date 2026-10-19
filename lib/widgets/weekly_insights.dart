import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/user_progress.dart';
import '../providers/boredom_provider.dart';
import '../providers/theme_provider.dart';
import '../services/insights.dart';

/// Behavioural observations derived from the completion history.
///
/// Renders nothing at all when there is not enough history to justify a
/// claim, rather than padding with placeholders.
class WeeklyInsights extends StatelessWidget {
  const WeeklyInsights({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final pal = context.palette;
    final code = s.code;
    final history = context.select<BoredomProvider, List<CompletedMission>>(
      (p) => p.history,
    );

    if (history.length < 5) return const SizedBox.shrink();
    final items = Insights.build(history, DateTime.now());
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.insightsTitle,
          style: TextStyle(
            color: pal.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((i) => _InsightTile(insight: i, code: code)),
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  final Insight insight;
  final String code;
  const _InsightTile({required this.insight, required this.code});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: pal.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(insight.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.title(code),
                    style: TextStyle(
                      color: pal.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    insight.detail(code),
                    style: TextStyle(
                      color: pal.textSecondary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
