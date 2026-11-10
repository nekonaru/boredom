import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../providers/boredom_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';
import '../utils/feedback.dart';
import '../widgets/kit.dart';

/// Interactive step checklist shown inside the active mission sheet.
/// Every tap toggles a step; the progress bar animates and the finish
/// button turns green once all steps are complete.
class MissionSteps extends StatelessWidget {
  final BoredomProvider provider;
  final AppStrings s;
  final AppPalette pal;

  const MissionSteps({
    super.key,
    required this.provider,
    required this.s,
    required this.pal,
  });

  @override
  Widget build(BuildContext context) {
    // Subscribe to step state so the checklist actually redraws on every
    // tap. Reading the provider directly (without select) meant this
    // widget never rebuilt and the checkboxes looked dead.
    final done = context.select<BoredomProvider, Set<int>>(
      (p) => p.completedStepIndexes,
    );
    final allComplete = context.select<BoredomProvider, bool>(
      (p) => p.allStepsComplete,
    );
    final steps = provider.activeSteps;
    if (steps.isEmpty) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppKit.rLg),
        boxShadow: allComplete
            ? [
                BoxShadow(
                  color: pal.success.withValues(alpha: 0.28),
                  blurRadius: 26,
                  spreadRadius: -6,
                ),
              ]
            : const [],
      ),
      child: AppKit.card(
        color:
            allComplete ? pal.success.withValues(alpha: 0.10) : pal.surface,
        padding: const EdgeInsets.all(AppKit.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  s.missionStepsTitle.toUpperCase(),
                  style: TextStyle(
                    color: pal.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                  ),
                ),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: anim,
                    child: child,
                  ),
                  child: Text(
                    s.stepsDone(done.length, steps.length),
                    key: ValueKey('${done.length}/${steps.length}'),
                    style: TextStyle(
                      color: allComplete ? pal.success : pal.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppKit.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppKit.rPill),
              child: TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: 0,
                  end: steps.isEmpty ? 0 : done.length / steps.length,
                ),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: pal.emptyBar,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    allComplete ? pal.success : pal.accent,
                  ),
                ),
              ),
            ),
            if (allComplete) ...[
              const SizedBox(height: AppKit.sm),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutBack,
                builder: (context, v, child) => Transform.scale(
                  scale: 0.85 + 0.15 * v,
                  child: Opacity(opacity: v, child: child),
                ),
                child: Row(
                  children: [
                    Icon(Icons.celebration, size: 16, color: pal.success),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        s.missionStepsDone,
                        style: TextStyle(
                          color: pal.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppKit.md),
            for (var i = 0; i < steps.length; i++)
              _StepRow(
                emoji: steps[i].emoji,
                title: steps[i].title,
                titleId: steps[i].titleId,
                done: done.contains(i),
                onToggle: () {
                  buzzIfEnabled(context);
                  provider.toggleStep(i);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String emoji;
  final String title;
  final String? titleId;
  final bool done;
  final VoidCallback onToggle;

  const _StepRow({
    required this.emoji,
    required this.title,
    required this.titleId,
    required this.done,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final pal = context.palette;
    final label = localizedTitle(en: title, id: titleId, code: s.code);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppKit.sm),
      child: Material(
        color: done
            ? pal.success.withValues(alpha: 0.12)
            : pal.emptyBar.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppKit.rMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppKit.rMd),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppKit.md,
              vertical: AppKit.sm,
            ),
            child: Row(
              children: [
                _CheckBox(done: done),
                const SizedBox(width: AppKit.md),
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: AppKit.sm),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      color: done ? pal.textSecondary : pal.textPrimary,
                      fontSize: 13,
                      height: 1.3,
                      decoration: done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: done
                          ? pal.textSecondary.withValues(alpha: 0.8)
                          : Colors.transparent,
                    ),
                    child: Text(label),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A clear, tactile checkbox. Empty shows a hollow rounded square; checked
/// fills green and the tick pops with a soft spring so the state change
/// reads instantly.
class _CheckBox extends StatelessWidget {
  final bool done;
  const _CheckBox({required this.done});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: done ? pal.success : pal.surface,
        borderRadius: BorderRadius.circular(AppKit.rSm),
        border: Border.all(
          color: done ? pal.success : pal.textSecondary.withValues(alpha: 0.7),
          width: 1.8,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, anim) => ScaleTransition(
          scale: anim,
          child: child,
        ),
        child: done
            ? const Icon(Icons.check, size: 18, color: Colors.white)
            : const SizedBox.shrink(),
      ),
    );
  }
}
