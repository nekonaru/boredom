import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Last-7-days activity bars, drawn with a CustomPainter instead of a
/// chart package so the APK stays small. No animation, no dependencies.
class WeeklyChart extends StatelessWidget {
  final List<int> counts;
  const WeeklyChart({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: SizedBox(
        height: 120,
        width: double.infinity,
        child: CustomPaint(
          painter: _WeeklyChartPainter(counts: counts),
        ),
      ),
    );
  }
}

class _WeeklyChartPainter extends CustomPainter {
  final List<int> counts;
  _WeeklyChartPainter({required this.counts});

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = counts.fold<int>(1, (a, b) => a > b ? a : b);
    const gap = 8.0;
    final barWidth = (size.width - gap * (counts.length - 1)) / counts.length;
    final todayIndex = counts.length - 1;

    for (var i = 0; i < counts.length; i++) {
      final ratio = counts[i] / maxValue;
      final barHeight = (size.height - 18) * ratio;
      final x = i * (barWidth + gap);
      final y = size.height - 18 - barHeight;
      final isToday = i == todayIndex;
      final paint = Paint()
        ..color = isToday
            ? AppColors.accent
            : counts[i] == 0
                ? const Color(0xFF2A2A33)
                : AppColors.accent.withValues(alpha: 0.45);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight < 4 ? 4 : barHeight),
        const Radius.circular(5),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyChartPainter oldDelegate) =>
      oldDelegate.counts != counts;
}
