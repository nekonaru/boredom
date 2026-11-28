import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import '../widgets/kit.dart';

/// A circular progress ring that shows the follow-through rate without a
/// chart package. A null rate renders an honest dash instead of zero.
class FollowThroughRing extends StatelessWidget {
  final double? rate;
  final String label;
  const FollowThroughRing({
    super.key,
    required this.rate,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final value = (rate ?? 0).clamp(0.0, 1.0);
    return AppKit.card(
      color: pal.surface,
      padding: const EdgeInsets.all(AppKit.lg),
      child: Column(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value),
              duration: AppKit.motion(context, const Duration(milliseconds: 700)),
              curve: AppKit.easeOut,
              builder: (context, animated, _) => CustomPaint(
                painter: _RingPainter(
                  progress: animated,
                  color: rate == null ? pal.textSecondary : pal.success,
                  track: pal.emptyBar,
                ),
                child: Center(
                  child: Text(
                    rate == null
                        ? '-'
                        : '${(animated * 100).round()}%',
                    style: TextStyle(
                      color: pal.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppKit.sm),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: pal.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color track;
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 9.0;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    canvas.drawArc(
      rect,
      0,
      6.283185307179586,
      false,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      rect,
      -1.5707963267948966,
      6.283185307179586 * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}
