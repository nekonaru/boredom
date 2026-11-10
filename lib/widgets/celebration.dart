import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';

/// Shows a brief celebratory overlay: a confetti burst behind a card that
/// pops in, lingers, and fades out. Used for mission completion and
/// achievement unlocks so a win feels like a win instead of a plain
/// snackbar. Safe to call from a button handler; the overlay sits above
/// every route (including modal sheets) and dismisses itself.
void showCelebration(
  BuildContext context, {
  required String emoji,
  required String title,
  String? subtitle,
  Color? accent,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(milliseconds: 2600),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _CelebrationOverlay(
      emoji: emoji,
      title: title,
      subtitle: subtitle,
      accent: accent,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      onDismissed: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

/// One confetti piece. Parameters are fixed at construction so the burst
/// is deterministic across frames (no flicker from a shared Random).
class _Particle {
  final double angle;
  final double speed;
  final double size;
  final double spin;
  final Color color;

  const _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.spin,
    required this.color,
  });
}

List<_Particle> _buildParticles(Color accent) {
  const palette = <Color>[
    Color(0xFFFFC94D), // gold
    Color(0xFFFF6B6B), // red
    Color(0xFF4DD6A8), // green
    Color(0xFF6BB8FF), // blue
    Color(0xFFB48CFF), // purple
  ];
  const count = 68;
  final rand = math.Random(42);
  return List.generate(count, (i) {
    final angle = (i / count) * 2 * math.pi + rand.nextDouble() * 0.5;
    return _Particle(
      angle: angle,
      speed: 0.45 + rand.nextDouble() * 0.6,
      size: 4 + rand.nextDouble() * 4,
      spin: rand.nextDouble() * 2 - 1,
      color: i % 3 == 0 ? accent : palette[i % palette.length],
    );
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _ConfettiPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final origin = Offset(size.width / 2, size.height * 0.40);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    for (final p in particles) {
      final travel = progress * p.speed;
      final dx = math.cos(p.angle) * travel * size.width * 0.62;
      final dy = math.sin(p.angle) * travel * size.height * 0.62 +
          travel * travel * size.height * 0.9;
      final pos = origin + Offset(dx, dy);
      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin * progress * 6);
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size * 2,
          height: p.size * 1.4,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.progress != progress || old.particles != particles;
}

class _CelebrationOverlay extends StatefulWidget {
  final String emoji;
  final String title;
  final String? subtitle;
  final Color? accent;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
  final VoidCallback onDismissed;

  const _CelebrationOverlay({
    required this.emoji,
    required this.title,
    this.subtitle,
    this.accent,
    this.actionLabel,
    this.onAction,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _cardScale;
  late final Animation<double> _cardOpacity;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = _buildParticles(widget.accent ?? const Color(0xFFFFC94D));
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _cardScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutBack),
    );
    _cardOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.12, curve: Curves.easeOut),
    );
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final accent = widget.accent ?? pal.accent;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          // Confetti resolves within the first 60% so it reads as a burst,
          // not slow-motion rain.
          final confetti = (t / 0.6).clamp(0.0, 1.0);
          // Whole overlay fades out over the last 15%.
          final fade = t < 0.85 ? 1.0 : (1.0 - (t - 0.85) / 0.15);
          return Stack(
            children: [
              Opacity(
                opacity: 0.35 * fade,
                child: const ColoredBox(color: Colors.black),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _ConfettiPainter(
                    progress: confetti,
                    particles: _particles,
                  ),
                ),
              ),
              Center(
                child: Opacity(
                  opacity: _cardOpacity.value * fade,
                  child: Transform.scale(
                    scale: _cardScale.value,
                    child: _card(accent, pal),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _card(Color accent, AppPalette pal) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 36),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      constraints: const BoxConstraints(maxWidth: 340),
      decoration: BoxDecoration(
        color: pal.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.35),
            blurRadius: 48,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: pal.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
          if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: pal.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          if (widget.actionLabel != null && widget.onAction != null) ...[
            const SizedBox(height: 4),
            TextButton(
              onPressed: () {
                widget.onAction?.call();
                widget.onDismissed();
              },
              style: TextButton.styleFrom(
                foregroundColor: accent,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: Text(widget.actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
