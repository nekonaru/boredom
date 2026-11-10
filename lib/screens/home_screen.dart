import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/mission.dart';
import '../models/user_progress.dart';
import '../providers/boredom_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/feedback.dart';
import '../widgets/celebration.dart';
import '../widgets/kit.dart';
import '../widgets/selector_row.dart';
import '../widgets/xp_bar.dart';
import '../widgets/mission_sheet.dart';
import '../widgets/daily_challenge_card.dart';
import '../widgets/weekly_summary.dart';
import '../widgets/weekly_insights.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? _midnightTimer;
  Timer? _pulseTimer;
  bool _pulsePrimary = false;
  bool _filtersOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleMidnight();
    // Gentle pulse on the primary action so first-time users notice it.
    _pulseTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _pulsePrimary = true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnightTimer?.cancel();
    _pulseTimer?.cancel();
    super.dispose();
  }

  void _scheduleMidnight() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final delay = nextMidnight.difference(now) + const Duration(seconds: 1);
    _midnightTimer = Timer(delay, () {
      if (!mounted) return;
      context.read<BoredomProvider>().refreshIfDayChanged();
      _scheduleMidnight();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleMidnight();
      context.read<BoredomProvider>().refreshIfDayChanged();
    }
  }

  void _handleCompletion(BuildContext context, AppStrings s,
      BoredomProvider provider) {
    final pal = context.palette;
    final code = s.code;
    final gained = provider.lastXpGained;
    final unlocked = provider.lastUnlockedAchievements;

    if (gained == null && unlocked.isEmpty) return;

    Future<void> undo() async {
      final ok = await provider.undoLastComplete();
      if (context.mounted && ok) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(s.undoDone)));
      }
    }

    if (gained != null && gained > 0) {
      // Success moment: confetti plus any achievement just unlocked, with
      // undo offered in place of the old plain snackbar.
      String? subtitle;
      if (unlocked.isNotEmpty) {
        subtitle = unlocked
            .map((a) =>
                '${a.emoji} ${localizedTitle(en: a.title, id: a.titleId, code: code)}')
            .join('\n');
      }
      if (provider.lastFreezeUsed) {
        subtitle =
            subtitle == null ? s.freezeUsed : '$subtitle\n${s.freezeUsed}';
      }
      showCelebration(
        context,
        emoji: '🎉',
        title: s.xpSnack(gained),
        subtitle: subtitle,
        accent: pal.success,
        actionLabel: provider.canUndo ? s.undoAction : null,
        onAction: provider.canUndo ? undo : null,
      );
    } else if (unlocked.isNotEmpty) {
      // No XP (skipped or partial) but an achievement still opened:
      // celebrate the achievement on its own.
      final first = unlocked.first;
      showCelebration(
        context,
        emoji: first.emoji,
        title: localizedTitle(en: first.title, id: first.titleId, code: code),
        subtitle: s.achievementSnack,
        accent: pal.accent,
      );
    } else {
      // Honest neutral feedback for a skipped or partial outcome.
      AppKit.showXp(
        context,
        s,
        gained: gained ?? 0,
        usedFreeze: provider.lastFreezeUsed,
        onUndo: provider.canUndo ? undo : null,
      );
    }

    provider.clearLastXpGained();
    provider.clearLastUnlockedAchievements();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final pal = context.palette;
    final progress = context.select<BoredomProvider, UserProgress>((p) => p.progress);
    final selectedMood = context.select<BoredomProvider, Mood>((p) => p.selectedMood);
    final selectedTime = context.select<BoredomProvider, TimeBudget>((p) => p.selectedTime);
    final selectedLocation =
        context.select<BoredomProvider, LocationType>((p) => p.selectedLocation);
    final selectedEnergy =
        context.select<BoredomProvider, EnergyLevel>((p) => p.selectedEnergy);
    final chaosMode = context.select<BoredomProvider, bool>((p) => p.chaosMode);
    final rerollsLeft = context.select<BoredomProvider, int>((p) => p.rerollsLeft);
    final streakAtRisk = context.select<BoredomProvider, bool>(
      (p) => p.streakAtRisk,
    );
    final quickWins = context.select<BoredomProvider, bool>(
      (p) => p.quickWinsOnly,
    );
    final freezeTokens = context.select<BoredomProvider, int>(
      (p) => p.progress.freezeTokens,
    );
    final actions = context.read<BoredomProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppKit.lg, AppKit.md, AppKit.lg, AppKit.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: brand + streak chip.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  s.brand,
                  style: TextStyle(
                    color: pal.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                if (progress.streakDays > 0)
                  AppKit.card(
                    color: pal.warning.withValues(alpha: 0.15),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppKit.sm, vertical: AppKit.xs),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          s.streak(progress.streakDays),
                          style: TextStyle(
                            color: pal.warning,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppKit.xl),
            Text(
              s.headline,
              style: TextStyle(
                color: pal.textPrimary,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: AppKit.xs),
            Text(
              s.subhead,
              style: TextStyle(color: pal.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: AppKit.xl),
            XpBar(progress: progress),
            const SizedBox(height: AppKit.lg),

            // Quick-stats row: streak, freeze tokens, this week — combined
            // into one card so the screen doesn't feel like a wall of data.
            AppKit.card(
              color: pal.surface,
              padding: const EdgeInsets.all(AppKit.lg),
              child: Row(
                children: [
                  _QuickStat(
                    emoji: '🔥',
                    value: '${progress.streakDays}',
                    label: s.days(progress.streakDays),
                    color: pal.warning,
                  ),
                  const SizedBox(width: AppKit.lg),
                  if (freezeTokens > 0) ...[
                    _QuickStat(
                      emoji: '❄️',
                      value: '$freezeTokens',
                      label: s.freezeTokens,
                      color: pal.success,
                    ),
                    const SizedBox(width: AppKit.lg),
                  ],
                  _QuickStat(
                    emoji: '🎯',
                    value: '${progress.totalMissionsCompleted}',
                    label: s.missionsWord,
                    color: pal.accent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppKit.lg),

            // Streak-at-risk warning.
            if (streakAtRisk) ...[
              AppKit.card(
                color: pal.surface,
                border: Border.all(
                  color: pal.warning.withValues(alpha: 0.4),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppKit.lg, vertical: AppKit.md),
                child: Row(
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: AppKit.md),
                    Expanded(
                      child: Text(
                        s.streakRisk,
                        style: TextStyle(
                          color: pal.warning,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppKit.lg),
            ],

            // Daily challenge — prominent, right under the stats.
            RepaintBoundary(
              child: const DailyChallengeCard(),
            ),
            const SizedBox(height: AppKit.xl),

            // Weekly summary strip.
            RepaintBoundary(
              child: const WeeklySummaryStrip(),
            ),
            const SizedBox(height: AppKit.xl),

            // Filters — collapsed into one expandable card so the screen
            // does not scroll for miles before reaching the primary action.
            AppKit.card(
              color: pal.surface,
              child: Column(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(AppKit.rLg),
                    onTap: () => setState(() => _filtersOpen = !_filtersOpen),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppKit.lg, vertical: AppKit.md),
                      child: Row(
                        children: [
                          const Text('⚙️', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: AppKit.md),
                          Expanded(
                            child: Text(
                              s.filterTitle,
                              style: TextStyle(
                                color: pal.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: _filtersOpen ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.expand_more,
                              color: pal.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_filtersOpen) ...[
                    const Divider(height: 1),
                    const SizedBox(height: AppKit.lg),
                    SelectorRow<Mood>(
                      title: s.secMood,
                      selected: selectedMood,
                      onChanged: actions.setMood,
                      options: Mood.values
                          .map((m) => SelectorOption(m, m.emoji, s.moodLabel(m)))
                          .toList(),
                    ),
                    const SizedBox(height: AppKit.lg),
                    SelectorRow<TimeBudget>(
                      title: s.secTime,
                      selected: selectedTime,
                      onChanged: actions.setTime,
                      options: TimeBudget.values
                          .map((t) => SelectorOption(t, '⏱️', s.timeLabel(t)))
                          .toList(),
                    ),
                    const SizedBox(height: AppKit.lg),
                    SelectorRow<LocationType>(
                      title: s.secLocation,
                      selected: selectedLocation,
                      onChanged: actions.setLocation,
                      options: LocationType.values
                          .map((l) => SelectorOption(l, l.emoji, s.locationLabel(l)))
                          .toList(),
                    ),
                    const SizedBox(height: AppKit.lg),
                    SelectorRow<EnergyLevel>(
                      title: s.secEnergy,
                      selected: selectedEnergy,
                      onChanged: actions.setEnergy,
                      options: EnergyLevel.values
                          .map((e) => SelectorOption(e, e.emoji, s.energyLabel(e)))
                          .toList(),
                    ),
                    const SizedBox(height: AppKit.lg),
                    AppKit.toggleRow(
                      context,
                      emoji: '⚡',
                      title: s.quickWins,
                      subtitle: s.quickWinsDesc,
                      value: quickWins,
                      onChanged: () => actions.setQuickWins(!quickWins),
                    ),
                    const SizedBox(height: AppKit.lg),
                    AppKit.toggleRow(
                      context,
                      emoji: '☢️',
                      title: s.chaosTitle,
                      subtitle: s.chaosDesc,
                      value: chaosMode,
                      onChanged: () => actions.setChaosMode(!chaosMode),
                    ),
                    const SizedBox(height: AppKit.lg),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppKit.xl),

            // Primary action — pulsed so it invites a tap.
            AppKit.pulseWrapper(
              pulse: _pulsePrimary,
              child: AppKit.primaryButton(
                context: context,
                label:
                    '${chaosMode ? '☢️ ' : '🎲 '}${chaosMode ? s.chaosButton : s.boredButton}',
                backgroundColor: chaosMode ? pal.danger : null,
                onPressed: () async {
                  buzzIfEnabled(context);
                  actions.rollMission();
                  if (!context.mounted) return;
                  await showMissionSheet(context);
                  if (!context.mounted) return;
                  _handleCompletion(context, s, actions);
                },
              ),
            ),
            const SizedBox(height: AppKit.sm),
            Center(
              child: Text(
                s.rerollsLeft(rerollsLeft),
                style: TextStyle(color: pal.textSecondary, fontSize: 12),
              ),
            ),
            const SizedBox(height: AppKit.lg),

            // Weekly insights — shown only when there is enough history,
            // and placed at the bottom so it never crowds the primary action.
            RepaintBoundary(
              child: const WeeklyInsights(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const _QuickStat({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: context.palette.textSecondary, fontSize: 11),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
