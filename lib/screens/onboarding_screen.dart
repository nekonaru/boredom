import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/mission.dart';
import '../providers/boredom_provider.dart';
import '../providers/theme_provider.dart';
import '../services/mission_service.dart';
import '../utils/app_theme.dart';
import '../utils/feedback.dart';
import '../widgets/kit.dart';

/// Interactive walkthrough: five short steps that let the player touch the
/// real mechanics instead of reading about them.
///
/// Shown automatically the first time only. Existing players can replay it
/// from Profile, in which case [popOnFinish] pops back to wherever it was
/// launched from instead of letting the startup gate swap the tree.
class OnboardingScreen extends StatefulWidget {
  final bool popOnFinish;
  const OnboardingScreen({super.key, this.popOnFinish = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _stepCount = 5;

  final _controller = PageController();
  int _page = 0;
  Mission? _preview;
  bool _accepted = false;
  bool _remind = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == _stepCount - 1) {
      _finish(context);
      return;
    }
    _controller.nextPage(
      duration: AppKit.motion(context, const Duration(milliseconds: 280)),
      curve: AppKit.easeOut,
    );
  }

  void _rollPreview() {
    final provider = context.read<BoredomProvider>();
    buzzIfEnabled(context);
    final mission = MissionService.generate(
      MissionFilter(
        mood: provider.selectedMood,
        timeBudget: provider.selectedTime,
        location: provider.selectedLocation,
        energy: provider.selectedEnergy,
      ),
      now: DateTime.now(),
    );
    setState(() {
      _preview = mission;
      _accepted = false;
    });
  }

  Future<void> _finish(BuildContext context) async {
    final provider = context.read<BoredomProvider>();
    final navigator = Navigator.of(context);
    if (_remind) {
      await provider.setReminder(true);
    }
    provider.completeOnboarding();
    // On a replay the startup gate is not driving this widget, so nothing
    // else would take the user back.
    if (widget.popOnFinish && navigator.canPop()) {
      navigator.pop();
    }
  }

  Widget _step(BuildContext context, AppStrings s, AppPalette pal) {
    switch (_page) {
      case 0:
        return _OnboardingPage(
          emoji: '🎲',
          title: s.onbWelcomeTitle,
          body: s.onbWelcomeBody,
        );
      case 1:
        return _OnboardingMoodStep(s: s, pal: pal);
      case 2:
        return _OnboardingRollStep(
          s: s,
          pal: pal,
          preview: _preview,
          onRoll: _rollPreview,
        );
      case 3:
        return _OnboardingAcceptStep(
          s: s,
          pal: pal,
          preview: _preview,
          accepted: _accepted,
          onAccept: () => setState(() => _accepted = true),
        );
      case 4:
        return _OnboardingReminderStep(
          s: s,
          pal: pal,
          value: _remind,
          onChanged: (v) => setState(() => _remind = v),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  bool get _canAdvance {
    switch (_page) {
      case 2:
        return _preview != null;
      case 3:
        return _accepted;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final pal = context.palette;
    final last = _page == _stepCount - 1;

    return Scaffold(
      backgroundColor: pal.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _finish(context),
                child: Text(
                  s.onbSkip,
                  style: TextStyle(color: pal.textSecondary),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _stepCount,
                padEnds: false,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _page == i
                    ? _step(context, s, pal)
                    : const SizedBox.shrink(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _stepCount,
                (i) => AnimatedContainer(
                  duration: AppKit.motion(context),
                  curve: AppKit.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _page ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(6),
                    color: i == _page
                        ? pal.accent
                        : pal.textSecondary.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppKit.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppKit.xl),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canAdvance ? _next : null,
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: pal.emptyBar,
                  ),
                  child: Text(last ? s.onbStart : s.onbNext),
                ),
              ),
            ),
            const SizedBox(height: AppKit.xl),
          ],
        ),
      ),
    );
  }
}

/// Static hero page used for the welcome step.
class _OnboardingPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String body;
  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return _OnboardingFrame(
      emoji: emoji,
      title: title,
      body: body,
      child: const SizedBox.shrink(),
    );
  }
}

/// Shared layout: glowing emoji, title, body, then an interactive area.
class _OnboardingFrame extends StatelessWidget {
  final String emoji;
  final String title;
  final String body;
  final Widget child;
  const _OnboardingFrame({
    required this.emoji,
    required this.title,
    required this.body,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppKit.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppKit.lg),
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  pal.accent.withValues(alpha: 0.26),
                  pal.accent.withValues(alpha: 0),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: AppKit.xl),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: pal.textPrimary,
              fontSize: AppKit.fsHeadline,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppKit.md),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: pal.textSecondary,
              fontSize: AppKit.fsSubtitle,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppKit.xl),
          child,
        ],
      ),
    );
  }
}

/// Step 2: the player changes a real preference right away.
class _OnboardingMoodStep extends StatelessWidget {
  final AppStrings s;
  final AppPalette pal;
  const _OnboardingMoodStep({required this.s, required this.pal});

  @override
  Widget build(BuildContext context) {
    final selected = context.select<BoredomProvider, Mood>(
      (p) => p.selectedMood,
    );
    final provider = context.read<BoredomProvider>();
    return _OnboardingFrame(
      emoji: '✨',
      title: s.onbMoodTitle,
      body: s.onbMoodBody,
      child: Column(
        children: [
          for (final mood in Mood.values)
            Padding(
              padding: const EdgeInsets.only(bottom: AppKit.sm),
              child: AppKit.chip(
                context,
                label: s.moodLabel(mood),
                selected: selected == mood,
                onTap: () {
                  buzzIfEnabled(context);
                  provider.setMood(mood);
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Step 3: roll a real catalog mission as a side-effect-free preview.
class _OnboardingRollStep extends StatelessWidget {
  final AppStrings s;
  final AppPalette pal;
  final Mission? preview;
  final VoidCallback onRoll;
  const _OnboardingRollStep({
    required this.s,
    required this.pal,
    required this.preview,
    required this.onRoll,
  });

  @override
  Widget build(BuildContext context) {
    return _OnboardingFrame(
      emoji: '🎯',
      title: s.onbRollTitle,
      body: s.onbRollBody,
      child: Column(
        children: [
          OutlinedButton.icon(
            onPressed: onRoll,
            icon: const Icon(Icons.casino),
            label: Text(s.onbRollBtn),
            style: OutlinedButton.styleFrom(
              foregroundColor: pal.accent,
              side: BorderSide(color: pal.accent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppKit.rPill),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          if (preview != null) ...[
            const SizedBox(height: AppKit.lg),
            AnimatedSwitcher(
              duration: AppKit.motion(context, AppKit.motionSlow),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: AppKit.card(
                key: ValueKey(preview!.id),
                color: pal.surface,
                padding: const EdgeInsets.all(AppKit.lg),
                child: Column(
                  children: [
                    Text(preview!.emoji, style: const TextStyle(fontSize: 36)),
                    const SizedBox(height: AppKit.sm),
                    Text(
                      s.onbRolledLabel,
                      style: TextStyle(
                        color: pal.textSecondary,
                        fontSize: AppKit.fsCaption,
                      ),
                    ),
                    const SizedBox(height: AppKit.xs),
                    Text(
                      localizedTitle(
                        en: preview!.title,
                        id: preview!.titleId,
                        code: s.code,
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: pal.textPrimary,
                        fontSize: AppKit.fsSubtitle,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Step 4: a practice accept with the same satisfying feedback as a real win.
class _OnboardingAcceptStep extends StatelessWidget {
  final AppStrings s;
  final AppPalette pal;
  final Mission? preview;
  final bool accepted;
  final VoidCallback onAccept;
  const _OnboardingAcceptStep({
    required this.s,
    required this.pal,
    required this.preview,
    required this.accepted,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return _OnboardingFrame(
      emoji: accepted ? '🏆' : '✅',
      title: s.onbDoneTitle,
      body: s.onbDoneBody,
      child: Column(
        children: [
          AnimatedContainer(
            duration: AppKit.motion(context, AppKit.motionSlow),
            curve: AppKit.easeOut,
            padding: const EdgeInsets.all(AppKit.lg),
            decoration: BoxDecoration(
              color: accepted
                  ? pal.success.withValues(alpha: 0.14)
                  : pal.surface,
              borderRadius: BorderRadius.circular(AppKit.rLg),
              border: Border.all(
                color: accepted ? pal.success : pal.emptyBar,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  accepted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: accepted ? pal.success : pal.textSecondary,
                  size: 28,
                ),
                const SizedBox(width: AppKit.md),
                Text(
                  accepted ? s.onbAcceptPreview : s.onbSkippedPreview,
                  style: TextStyle(
                    color: accepted ? pal.success : pal.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (!accepted) ...[
            const SizedBox(height: AppKit.lg),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  buzzIfEnabled(context);
                  onAccept();
                },
                icon: const Icon(Icons.check),
                label: Text(s.onbAcceptPreview),
                style: OutlinedButton.styleFrom(
                  foregroundColor: pal.success,
                  side: BorderSide(color: pal.success),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppKit.rPill),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Step 5: opt into the existing reminder instead of explaining it abstractly.
class _OnboardingReminderStep extends StatelessWidget {
  final AppStrings s;
  final AppPalette pal;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _OnboardingReminderStep({
    required this.s,
    required this.pal,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _OnboardingFrame(
      emoji: '⏰',
      title: s.onbRemindTitle,
      body: s.onbRemindBody,
      child: AppKit.card(
        color: pal.surface,
        child: AppKit.toggleRow(
          context,
          emoji: '🔔',
          title: s.onbRemindToggle,
          subtitle: null,
          value: value,
          onChanged: () => onChanged(!value),
        ),
      ),
    );
  }
}
