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
    if (counts.isEmpty || size.width <= 0) return;
    final maxValue = counts.fold<int>(1, (a, b) => a > b ? a : b);
    // The gap has to shrink with the bar count. A fixed 8px gap looked
    // fine for the 7-day chart but ate 8 * 29 = 232px of the 30-day
    // chart's canvas, leaving bars 1.9px wide, and went negative on
    // narrower layouts, which Rect.fromLTWH rejects.
    final gap = counts.length > 14 ? 2.0 : 8.0;
    final available = size.width - gap * (counts.length - 1);
    if (available <= 0) return;
    final barWidth = available / counts.length;
    final todayIndex = counts.length - 1;
    // A radius wider than half the bar is not a valid RRect.
    final radius = Radius.circular(
      (barWidth / 2).clamp(0.0, counts.length > 14 ? 2.0 : 5.0),
    );

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
        radius,
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
