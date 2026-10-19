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

  // ---------------- Cards ----------------
  /// Plain surface card used everywhere.
  static Widget card({
    required Widget child,
    Color? color,
    double radius = rLg,
    EdgeInsetsGeometry? padding,
    Border? border,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border,
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
}
