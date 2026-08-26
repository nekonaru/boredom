import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mission.dart';
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
    final provider = context.watch<BoredomProvider>();
    final progress = provider.progress;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'B O R E D O M',
                  style: TextStyle(
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
                      color: AppColors.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '🔥 ${progress.streakDays} DAY STREAK',
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
            const Text(
              'YOU ARE BORED.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'So... what now?',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 24),
            XpBar(progress: progress),
            const SizedBox(height: 16),
            const DailyChallengeCard(),
            const SizedBox(height: 28),

            SelectorRow<Mood>(
              title: 'MOOD',
              selected: provider.selectedMood,
              onChanged: provider.setMood,
              options: Mood.values
                  .map((m) => SelectorOption(m, m.emoji, m.label))
                  .toList(),
            ),
            const SizedBox(height: 16),
            SelectorRow<TimeBudget>(
              title: 'PUNYA WAKTU',
              selected: provider.selectedTime,
              onChanged: provider.setTime,
              options: TimeBudget.values
                  .map((t) => SelectorOption(t, '⏱️', t.label))
                  .toList(),
            ),
            const SizedBox(height: 16),
            SelectorRow<LocationType>(
              title: 'LOKASI',
              selected: provider.selectedLocation,
              onChanged: provider.setLocation,
              options: LocationType.values
                  .map((l) => SelectorOption(l, l.emoji, l.label))
                  .toList(),
            ),
            const SizedBox(height: 16),
            SelectorRow<EnergyLevel>(
              title: 'ENERGI',
              selected: provider.selectedEnergy,
              onChanged: provider.setEnergy,
              options: EnergyLevel.values
                  .map((e) => SelectorOption(e, e.emoji, e.label))
                  .toList(),
            ),

            const SizedBox(height: 28),

            // Chaos mode toggle.
            InkWell(
              onTap: () => provider.setChaosMode(!provider.chaosMode),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: provider.chaosMode
                      ? AppColors.danger.withOpacity(0.15)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: provider.chaosMode ? AppColors.danger : Colors.white12,
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
                          const Text(
                            'CHAOS MODE',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Abaikan semua preferensi. Apapun bisa keluar.',
                            style: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.9),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: provider.chaosMode,
                      onChanged: provider.setChaosMode,
                      activeColor: AppColors.danger,
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
                  provider.rollMission();
                  await showMissionSheet(context);
                  if (!context.mounted) return;
                  if (provider.lastXpGained != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Mantap! +${provider.lastXpGained} XP 🎉'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    provider.clearLastXpGained();
                  }
                  for (final a in provider.lastUnlockedAchievements) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Achievement unlocked: ${a.emoji} ${a.title}'),
                        backgroundColor: AppColors.accent,
                      ),
                    );
                  }
                  provider.clearLastUnlockedAchievements();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      provider.chaosMode ? AppColors.danger : AppColors.accent,
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                child: Text(provider.chaosMode ? '☢️ CHAOS ME' : '🎲 I\'M BORED'),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                '${provider.rerollsLeft} reroll tersisa hari ini',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
