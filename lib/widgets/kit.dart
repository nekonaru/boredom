import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/achievement.dart';
import '../providers/theme_provider.dart';

/// Shared UI kit so every screen uses the same spacing, radius, and card
/// shape instead of magic numbers copied between files.
class AppKit {
  AppKit._();

  // ---------------- Spacing ----------------
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  // ---------------- Border radius ----------------
  static const double rSm = 10.0;
  static const double rMd = 14.0;
  static const double rLg = 16.0;
  static const double rXl = 18.0;
  static const double rPill = 28.0;

  // ---------------- Typography tokens (v5) ----------------
  static const double fsCaption = 11.0;
  static const double fsBody = 13.0;
  static const double fsSubtitle = 16.0;
  static const double fsTitle = 20.0;
  static const double fsHeadline = 28.0;
  static const double fsDisplay = 34.0;

  // ---------------- Motion tokens (v5) ----------------
  static const Duration motionFast = Duration(milliseconds: 150);
  static const Duration motionNormal = Duration(milliseconds: 250);
  static const Duration motionSlow = Duration(milliseconds: 400);

  /// UI motion stays under 300ms. [motionSlow] is reserved for entrances and
  /// sheets. Reduced motion keeps the change legible but removes movement.
  static Duration motion(BuildContext context,
          [Duration duration = motionNormal]) =>
      context.motionReduced ? motionFast : duration;

  static Curve get easeOut => Curves.easeOutCubic;
  static Curve get easeInOut => Curves.easeInOutCubic;

  // ---------------- Cards ----------------
  /// Plain surface card used everywhere. Defaults to a subtle border so
  /// every card reads as a discrete surface in both dark and light themes.
  static Widget card({
    Key? key,
    required Widget child,
    Color? color,
    double radius = rLg,
    EdgeInsetsGeometry? padding,
    Border? border,
  }) {
    return Container(
      key: key,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border ??
            Border.all(
              color: const Color(0xFFFFFFFF).withValues(alpha: 0.06),
              width: 1,
            ),
      ),
      child: child,
    );
  }

  // ---------------- Buttons ----------------
  static Widget primaryButton({
    required BuildContext context,
    required String label,
    required Future<void> Function()? onPressed,
    bool loading = false,
    Color? backgroundColor,
    double height = 56,
  }) {
    final pal = context.palette;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : () => onPressed?.call(),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? pal.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rPill)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(label),
      ),
    );
  }

  static Widget outlineButton({
    required BuildContext context,
    required String label,
    required Future<void> Function()? onPressed,
    bool loading = false,
    Color? foregroundColor,
    double height = 56,
  }) {
    final pal = context.palette;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: loading ? null : () => onPressed?.call(),
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor ?? pal.accent,
          side: BorderSide(color: foregroundColor ?? pal.accent),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rPill)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(label),
      ),
    );
  }

  // ---------------- Section header ----------------
  static Widget sectionHeader(BuildContext context, AppStrings s,
      {required String title, String? subtitle}) {
    final pal = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: pal.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: xs),
          Text(
            subtitle,
            style: TextStyle(
              color: pal.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  // ---------------- Metric card (shared between Stats & Profile) ----------------
  static Widget metricCard(BuildContext context,
      {required String label, required String value, required String emoji}) {
    final pal = context.palette;
    return card(
      color: pal.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: sm),
          Text(value,
              style: TextStyle(
                  color: pal.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: xs),
          Text(label, style: TextStyle(color: pal.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  // ---------------- Toggle row (quick wins / chaos / haptics) ----------------
  static Widget toggleRow(BuildContext context,
      {required String emoji,
      required String title,
      required String? subtitle,
      required bool value,
      required void Function()? onChanged}) {
    final pal = context.palette;
    return card(
      color: pal.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(rMd),
        onTap: () => onChanged?.call(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: lg, vertical: md),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: pal.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: xs),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: pal.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: (_) => onChanged?.call(),
                activeThumbColor: pal.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- SnackBar helpers ----------------
  static void showXp(BuildContext context, AppStrings s,
      {required int gained, bool usedFreeze = false, VoidCallback? onUndo}) {
    final pal = context.palette;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          gained > 0 ? s.xpSnack(gained) : s.skippedSnack,
        ),
        backgroundColor: gained > 0 ? pal.success : pal.textSecondary,
        action: onUndo != null
            ? SnackBarAction(
                label: s.undoAction,
                textColor: Colors.white,
                onPressed: onUndo,
              )
            : null,
      ),
    );
    if (usedFreeze) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❄️ ${s.freezeUsed}'),
          backgroundColor: pal.accent,
        ),
      );
    }
  }

  static void showAchievements(BuildContext context, AppStrings s,
      List<Achievement> unlocked, String code) {
    final pal = context.palette;
    for (final a in unlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${s.achievementSnack} ${a.emoji} ${localizedTitle(en: a.title, id: a.titleId, code: code)}',
          ),
          backgroundColor: pal.accent,
        ),
      );
    }
  }

  // ---------------- New components (v5) ----------------

  /// Selectable chip used for filters and one-of-many choices.
  static Widget chip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback? onTap,
    IconData? icon,
  }) {
    final pal = context.palette;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(rPill),
        child: AnimatedContainer(
          duration: motion(context),
          curve: easeOut,
          padding: const EdgeInsets.symmetric(horizontal: md, vertical: sm),
          decoration: BoxDecoration(
            color: selected
                ? pal.accent.withValues(alpha: 0.2)
                : pal.emptyBar.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(rPill),
            border: Border.all(
              color: selected
                  ? pal.accent
                  : pal.textSecondary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 14,
                    color: selected ? pal.accent : pal.textSecondary),
                const SizedBox(width: xs),
              ],
              Text(
                label,
                style: TextStyle(
                  color: selected ? pal.accent : pal.textSecondary,
                  fontSize: fsBody,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shimmer placeholder used while data loads. Animation is skipped when
  /// the platform or the user asked for reduced motion.
  static Widget skeleton(
    BuildContext context, {
    required double width,
    required double height,
    double radius = rSm,
  }) {
    final pal = context.palette;
    final reduce = context.motionReduced;
    return AnimatedContainer(
      duration: motion(context, motionSlow),
      curve: easeInOut,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: pal.emptyBar,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: reduce
          ? null
          : const _Shimmer(),
    );
  }

  /// Empty state with an optional action so a blank screen always offers a
  /// next step instead of only explaining why it is empty.
  static Widget emptyState(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final pal = context.palette;
    return Padding(
      padding: const EdgeInsets.all(xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: pal.textPrimary,
              fontSize: fsTitle,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: sm),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: pal.textSecondary,
              fontSize: fsBody,
              height: 1.5,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: lg),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: pal.accent,
                side: BorderSide(color: pal.accent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rPill),
                ),
              ),
              child: Text(actionLabel),
            ),
          ],
        ],
      ),
    );
  }

  /// Bottom sheet shell with a consistent grabber and safe padding.
  static Widget sheetShell(
    BuildContext context, {
    required Widget child,
  }) {
    final pal = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: pal.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(rXl)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: sm),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: pal.emptyBar,
                borderRadius: BorderRadius.circular(rPill),
              ),
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }

  // ---------------- Animations ----------------

  /// Cross-fades between pages so tab switches feel smooth instead of
  /// abrupt. Wraps the page body; each page must have a unique [key].
  static Widget pageFadeTransition({
    required Widget child,
    required Key key,
    required Duration duration,
  }) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: easeOut,
      switchOutCurve: easeInOut,
      child: KeyedSubtree(key: key, child: child),
    );
  }

  /// Directional slide + fade for tab switches. Moving right advances the
  /// tab, moving left goes back, so the direction matches the gesture.
  static Widget pageDirectionalTransition({
    required Widget child,
    required Key key,
    required bool forward,
    required Duration duration,
  }) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: easeOut,
      switchOutCurve: easeInOut,
      transitionBuilder: (widget, animation) {
        final direction = forward ? 1.0 : -1.0;
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(direction * 0.06, 0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: widget),
        );
      },
      child: KeyedSubtree(key: key, child: child),
    );
  }

  /// Fade + slide up entrance for cards and list items.
  /// [delay] staggers multiple items so they enter one after another.
  static Widget fadeSlideIn({
    required Widget child,
    required Duration delay,
  }) {
    return _FadeSlideIn(delay: delay, child: child);
  }

  /// Subtle pulse used on the primary action to invite a tap without
  /// shouting. Controlled by [pulse] so callers can turn it off.
  static Widget pulseWrapper({
    required Widget child,
    required bool pulse,
  }) {
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      transform: (() {
        final m = Matrix4.identity();
        final s = pulse ? 1.02 : 1.0;
        m[0] = s;
        m[5] = s;
        return m;
      })(),
      child: child,
    );
  }
}

/// Lightweight shimmer for skeleton placeholders. Uses a single controller
/// and transform/opacity only, so it stays cheap while data loads.
class _Shimmer extends StatefulWidget {
  const _Shimmer();

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final shift = -1.0 + 2.0 * _controller.value;
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white.withValues(alpha: 0.22),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment(shift, 0),
            end: Alignment(shift + 1, 0),
          ).createShader(bounds),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

/// Mount-time entrance with an optional stagger. Transform and opacity only,
/// and reduced motion collapses to a short fade with no movement.
class _FadeSlideIn extends StatefulWidget {
  final Duration delay;
  final Widget child;
  const _FadeSlideIn({required this.delay, required this.child});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(covariant _FadeSlideIn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.delay != widget.delay) _schedule();
  }

  void _schedule() {
    _visible = false;
    Future<void>.delayed(widget.delay).then((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduce = context.motionReduced;
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: AppKit.motion(context, AppKit.motionSlow),
      curve: AppKit.easeOut,
      child: AnimatedSlide(
        offset: _visible || reduce ? Offset.zero : const Offset(0, 0.04),
        duration: AppKit.motion(context, AppKit.motionSlow),
        curve: AppKit.easeOut,
        child: widget.child,
      ),
    );
  }
}
