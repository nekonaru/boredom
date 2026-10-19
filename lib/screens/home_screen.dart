import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/mission.dart';
import '../models/user_progress.dart';
import '../providers/boredom_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/feedback.dart';
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
  /// streak-at-risk banner, reroll allowance, and daily challenge on
  /// screen until the app was backgrounded and resumed.
  void _scheduleMidnight() {
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

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final pal = context.palette;
    // Selective rebuilds: each piece only listens to the field it renders,
    // so tapping a chip does not rebuild the whole page.
    final progress = context.select<BoredomProvider, UserProgress>((p) => p.progress);
    final selectedMood = context.select<BoredomProvider, Mood>((p) => p.selectedMood);
    final selectedTime = context.select<BoredomProvider, TimeBudget>((p) => p.selectedTime);
    final selectedLocation = context.select<BoredomProvider, LocationType>((p) => p.selectedLocation);
    final selectedEnergy = context.select<BoredomProvider, EnergyLevel>((p) => p.selectedEnergy);
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
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: pal.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
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
            const SizedBox(height: 24),
            Text(
              s.headline,
              style: TextStyle(
                color: pal.textPrimary,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              s.subhead,
              style: TextStyle(color: pal.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 24),
            XpBar(progress: progress),
            if (streakAtRisk) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: pal.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: pal.warning.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
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
            const SizedBox(height: 16),
            const WeeklySummaryStrip(),
            const SizedBox(height: 16),
            const DailyChallengeCard(),
            const SizedBox(height: 28),
            const WeeklyInsights(),
            const SizedBox(height: 28),

            SelectorRow<Mood>(
              title: s.secMood,
              selected: selectedMood,
              onChanged: actions.setMood,
              options: Mood.values
                  .map((m) => SelectorOption(m, m.emoji, s.moodLabel(m)))
                  .toList(),
            ),
            const SizedBox(height: 16),
            SelectorRow<TimeBudget>(
              title: s.secTime,
              selected: selectedTime,
              onChanged: actions.setTime,
              options: TimeBudget.values
                  .map((t) => SelectorOption(t, '⏱️', s.timeLabel(t)))
                  .toList(),
            ),
            const SizedBox(height: 16),
            SelectorRow<LocationType>(
              title: s.secLocation,
              selected: selectedLocation,
              onChanged: actions.setLocation,
              options: LocationType.values
                  .map((l) => SelectorOption(l, l.emoji, s.locationLabel(l)))
                  .toList(),
            ),
            const SizedBox(height: 16),
            SelectorRow<EnergyLevel>(
              title: s.secEnergy,
              selected: selectedEnergy,
              onChanged: actions.setEnergy,
              options: EnergyLevel.values
                  .map((e) => SelectorOption(e, e.emoji, s.energyLabel(e)))
                  .toList(),
            ),

            // Quick wins toggle: narrows rolls to missions of 15 minutes or less.
            InkWell(
              onTap: () => actions.setQuickWins(!quickWins),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: quickWins
                      ? pal.success.withValues(alpha: 0.12)
                      : pal.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: quickWins
                        ? pal.success
                        : pal.textSecondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.quickWins,
                            style: TextStyle(
                              color: pal.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            s.quickWinsDesc,
                            style: TextStyle(
                              color: pal.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: quickWins,
                      onChanged: actions.setQuickWins,
                      activeThumbColor: pal.success,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Chaos mode toggle.
            InkWell(
              onTap: () => actions.setChaosMode(!chaosMode),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: chaosMode
                      ? pal.danger.withValues(alpha: 0.15)
                      : pal.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: chaosMode
                        ? pal.danger
                        : pal.textSecondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('☢️', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.chaosTitle,
                            style: TextStyle(
                              color: pal.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            s.chaosDesc,
                            style: TextStyle(
                              color: pal.textSecondary.withValues(alpha: 0.9),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: chaosMode,
                      onChanged: actions.setChaosMode,
                      activeThumbColor: pal.danger,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () async {
                  buzzIfEnabled(context);
                  actions.rollMission();
                  if (!context.mounted) return;
                  await showMissionSheet(context);
                  if (!context.mounted) return;
                  final provider = context.read<BoredomProvider>();
                  if (provider.lastXpGained != null) {
                    final gained = provider.lastXpGained!;
                    final usedFreeze = provider.lastFreezeUsed;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(s.xpSnack(gained)),
                        backgroundColor: pal.success,
                        action: provider.canUndo
                            ? SnackBarAction(
                                label: s.undoAction,
                                textColor: Colors.white,
                                onPressed: () async {
                                  final ok = await provider.undoLastComplete();
                                  if (context.mounted && ok) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(s.undoDone)),
                                    );
                                  }
                                },
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
                    provider.clearLastXpGained();
                  }
                  final code = s.code;
                  for (final a in provider.lastUnlockedAchievements) {
                    if (!context.mounted) break;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${s.achievementSnack} ${a.emoji} ${localizedTitle(en: a.title, id: a.titleId, code: code)}',
                        ),
                        backgroundColor: pal.accent,
                      ),
                    );
                  }
                  provider.clearLastUnlockedAchievements();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      chaosMode ? pal.danger : pal.accent,
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                child: Text(chaosMode ? '☢️ ${s.chaosButton}' : '🎲 ${s.boredButton}'),
              ),
            ),
            const SizedBox(height: 10),
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
