import 'package:flutter/material.dart';
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
    final steps = provider.activeSteps;
    if (steps.isEmpty) return const SizedBox.shrink();
    final done = provider.completedStepIndexes;

    return AppKit.card(
      color: pal.surface,
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
              Text(
                s.stepsDone(done.length, steps.length),
                style: TextStyle(
                  color: provider.allStepsComplete ? pal.success : pal.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppKit.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppKit.rPill),
            child: LinearProgressIndicator(
              value: steps.isEmpty ? 0 : done.length / steps.length,
              minHeight: 8,
              backgroundColor: pal.emptyBar,
              valueColor: AlwaysStoppedAnimation<Color>(
                provider.allStepsComplete ? pal.success : pal.accent,
              ),
            ),
          ),
          const SizedBox(height: AppKit.md),
          for (var i = 0; i < steps.length; i++)
            _StepRow(
              emoji: steps[i].emoji,
              title: provider.allStepsComplete
                  ? steps[i].title
                  : steps[i].title,
              titleId: steps[i].titleId,
              done: done.contains(i),
              onToggle: () {
                buzzIfEnabled(context);
                provider.toggleStep(i);
              },
            ),
        ],
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: done ? pal.success : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppKit.rSm),
                    border: Border.all(
                      color: done ? pal.success : pal.textSecondary,
                      width: 1.6,
                    ),
                  ),
                  child: done
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: AppKit.md),
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: AppKit.sm),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: done ? pal.textSecondary : pal.textPrimary,
                      fontSize: 13,
                      height: 1.3,
                      decoration:
                          done ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
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
