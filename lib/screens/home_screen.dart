import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/mission.dart';
import '../models/user_progress.dart';
import '../providers/boredom_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/selector_row.dart';
import '../widgets/xp_bar.dart';
import '../widgets/mission_sheet.dart';
import '../widgets/daily_challenge_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    // Selective rebuilds: each piece only listens to the field it renders,
    // so tapping a chip does not rebuild the whole page.
    final progress = context.select<BoredomProvider, UserProgress>((p) => p.progress);
    final selectedMood = context.select<BoredomProvider, Mood>((p) => p.selectedMood);
    final selectedTime = context.select<BoredomProvider, TimeBudget>((p) => p.selectedTime);
    final selectedLocation = context.select<BoredomProvider, LocationType>((p) => p.selectedLocation);
    final selectedEnergy = context.select<BoredomProvider, EnergyLevel>((p) => p.selectedEnergy);
    final chaosMode = context.select<BoredomProvider, bool>((p) => p.chaosMode);
    final rerollsLeft = context.select<BoredomProvider, int>((p) => p.rerollsLeft);
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
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                if (progress.streakDays > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '🔥 ${s.streak(progress.streakDays)}',
                      style: const TextStyle(
                        color: AppColors.warning,
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
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              s.subhead,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 24),
            XpBar(progress: progress),
            const SizedBox(height: 16),
            const DailyChallengeCard(),
            const SizedBox(height: 28),

            SelectorRow<Mood>(
              title: s.secMood,
              selected: selectedMood,
              onChanged: actions.setMood,
              options: Mood.values
                  .map((m) => SelectorOption(m, m.emoji, m.label))
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
                  .map((l) => SelectorOption(l, l.emoji, l.label))
                  .toList(),
            ),
            const SizedBox(height: 16),
            SelectorRow<EnergyLevel>(
              title: s.secEnergy,
              selected: selectedEnergy,
              onChanged: actions.setEnergy,
              options: EnergyLevel.values
                  .map((e) => SelectorOption(e, e.emoji, e.label))
                  .toList(),
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
                      ? AppColors.danger.withValues(alpha: 0.15)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: chaosMode ? AppColors.danger : Colors.white12,
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
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            s.chaosDesc,
                            style: TextStyle(
                              color: AppColors.textSecondary.withValues(alpha: 0.9),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: chaosMode,
                      onChanged: actions.setChaosMode,
                      activeThumbColor: AppColors.danger,
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
                  actions.rollMission();
                  if (!context.mounted) return;
                  await showMissionSheet(context);
                  if (!context.mounted) return;
                  final provider = context.read<BoredomProvider>();
                  if (provider.lastXpGained != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(s.xpSnack(provider.lastXpGained!)),
                        backgroundColor: AppColors.success,
                      ),
                    );
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
                        backgroundColor: AppColors.accent,
                      ),
                    );
                  }
                  provider.clearLastUnlockedAchievements();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      chaosMode ? AppColors.danger : AppColors.accent,
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                child: Text(chaosMode ? '☢️ ${s.chaosButton}' : '🎲 ${s.boredButton}'),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                s.rerollsLeft(rerollsLeft),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
