import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

/// Last-7-days activity bars, drawn with a CustomPainter instead of a
/// chart package so the APK stays small. No animation, no dependencies.
class WeeklyChart extends StatelessWidget {
  final List<int> counts;
  const WeeklyChart({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: SizedBox(
        height: 120,
        width: double.infinity,
        child: CustomPaint(
          painter: ActivityBarsPainter(
            counts: counts,
            active: pal.accent,
            inactive: pal.accent.withValues(alpha: 0.45),
            empty: pal.emptyBar,
          ),
        ),
      ),
    );
  }
}

/// Last-30-days activity bars. Same painter, thinner bars.
class MonthlyChart extends StatelessWidget {
  final List<int> counts;
  const MonthlyChart({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: SizedBox(
        height: 100,
        width: double.infinity,
        child: CustomPaint(
          painter: ActivityBarsPainter(
            counts: counts,
            active: pal.accent,
            inactive: pal.accent.withValues(alpha: 0.45),
            empty: pal.emptyBar,
          ),
        ),
      ),
    );
  }
}

class ActivityBarsPainter extends CustomPainter {
  final List<int> counts;
  final Color active;
  final Color inactive;
  final Color empty;
  ActivityBarsPainter({
    required this.counts,
    required this.active,
    required this.inactive,
    required this.empty,
  });

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
            ? active
            : counts[i] == 0
                ? empty
                : inactive;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight < 4 ? 4 : barHeight),
        const Radius.circular(5),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ActivityBarsPainter oldDelegate) {
    // List `==` is identity, so comparing the lists directly only ever said
    // "changed" for the wrong reason. Compare element by element, and
    // compare the colors too: without them, switching theme or accent kept
    // the old bar colors painted.
    if (oldDelegate.counts.length != counts.length) return true;
    for (var i = 0; i < counts.length; i++) {
      if (oldDelegate.counts[i] != counts[i]) return true;
    }
    return oldDelegate.active != active ||
        oldDelegate.inactive != inactive ||
        oldDelegate.empty != empty;
  }
}
