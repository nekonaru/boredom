import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/mission.dart';
import '../models/user_progress.dart';
import '../providers/boredom_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/feedback.dart';
import '../widgets/kit.dart';
import '../widgets/weekly_summary.dart';
import '../widgets/selector_row.dart';
import '../widgets/xp_bar.dart';
import '../widgets/mission_sheet.dart';
import '../widgets/daily_challenge_card.dart';
import '../widgets/weekly_insights.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleMidnight();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnightTimer?.cancel();
    super.dispose();
  }

  /// Wakes up just after midnight and rolls the day over.
  ///
  /// Without this, leaving the app open across midnight kept yesterday's
  /// streak warning, reroll allowance, and daily challenge on screen until
  /// the app was backgrounded and resumed.
  void _scheduleMidnight() {
    // Cancel first. Resuming the app re-arms this, and without the cancel
    // the previous chain kept re-arming itself: N background/resume cycles
    // meant N independent timers and N redundant midnight writes.
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

  /// Runs the provider's day-rollover check when the app resumes, so a
  /// long-lived process does not keep serving yesterday's challenge.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // The timer can fire while backgrounded, or be an hour out of date
      // after a long suspend, so resume is still the primary trigger.
      _scheduleMidnight();
      context.read<BoredomProvider>().refreshIfDayChanged();
    }
  }

  void _handleCompletion(BuildContext context, AppStrings s,
      BoredomProvider provider) {
    final gained = provider.lastXpGained;
    // A skipped mission sets lastXpGained to 0. Gating on null showed a
    // green "+0 XP" celebration for the exact outcome the feature exists
    // to discourage.
    if (gained != null) {
      AppKit.showXp(context, s,
          gained: gained,
          usedFreeze: provider.lastFreezeUsed,
          onUndo: provider.canUndo
              ? () async {
                  final ok = await provider.undoLastComplete();
                  if (context.mounted && ok) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(s.undoDone)));
                  }
                }
              : null);
      provider.clearLastXpGained();
    }
    final code = s.code;
    for (final a in provider.lastUnlockedAchievements) {
      if (!context.mounted) break;
      AppKit.showAchievements(context, s, [a], code);
    }
    provider.clearLastUnlockedAchievements();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final pal = context.palette;
    // Selective rebuilds: each piece only listens to the field it renders,
    // so tapping a chip does not rebuild the whole page.
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
    final actions = context.read<BoredomProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppKit.lg, AppKit.md, AppKit.lg, AppKit.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    child: Text(
                      '🔥 ${s.streak(progress.streakDays)}',
                      style: TextStyle(
                        color: pal.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
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
            if (streakAtRisk) ...[
              const SizedBox(height: AppKit.md),
              AppKit.borderedCard(
                context: context,
                borderColor: pal.warning.withValues(alpha: 0.4),
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
            ],
            const SizedBox(height: AppKit.lg),
            RepaintBoundary(
              child: const WeeklySummaryStrip(),
            ),
            const SizedBox(height: AppKit.lg),
            RepaintBoundary(
              child: const DailyChallengeCard(),
            ),
            const SizedBox(height: AppKit.xl),
            RepaintBoundary(
              child: const WeeklyInsights(),
            ),
            const SizedBox(height: AppKit.xl),
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
            const SizedBox(height: AppKit.xl),
            AppKit.toggleRow(
              context,
              emoji: '⚡',
              title: s.quickWins,
              subtitle: s.quickWinsDesc,
              value: quickWins,
              onChanged: () => actions.setQuickWins(!quickWins),
              activeColor: pal.success,
            ),
            const SizedBox(height: AppKit.xl),
            AppKit.toggleRow(
              context,
              emoji: '☢️',
              title: s.chaosTitle,
              subtitle: s.chaosDesc,
              value: chaosMode,
              onChanged: () => actions.setChaosMode(!chaosMode),
              activeColor: pal.danger,
            ),
            const SizedBox(height: AppKit.xxl),
            AppKit.primaryButton(
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
            const SizedBox(height: AppKit.sm),
            Center(
              child: Text(
                s.rerollsLeft(rerollsLeft),
                style: TextStyle(color: pal.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
