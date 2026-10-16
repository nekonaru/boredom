import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/user_progress.dart';
import '../providers/boredom_provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/xp_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final progress = context.select<BoredomProvider, UserProgress>(
      (p) => p.progress,
    );
    final rerollsLeft = context.select<BoredomProvider, int>(
      (p) => p.rerollsLeft,
    );
    final isIndonesian = context.select<LanguageProvider, bool>(
      (p) => p.isIndonesian,
    );
    final provider = context.read<BoredomProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.profileTitle,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: XpBar(progress: progress),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(label: s.mTotalMissions, value: '${progress.totalMissionsCompleted}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(label: s.mActiveStreak, value: s.days(progress.streakDays)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(label: s.mTotalXp, value: '${progress.totalXp}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: s.mRerollsToday,
                    value: '$rerollsLeft/$kMaxRerollsPerDay',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              s.languageTitle,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('🌍', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isIndonesian ? s.languageIndonesian : s.languageEnglish,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    ),
                  ),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('EN')),
                      ButtonSegment(value: true, label: Text('ID')),
                    ],
                    selected: {isIndonesian},
                    onSelectionChanged: (selected) {
                      context.read<LanguageProvider>().setLocale(
                        Locale(selected.first ? 'id' : 'en'),
                      );
                    },
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              s.aboutTitle,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              s.aboutBody,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _confirmReset(context, s, provider),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(s.resetBtn),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                '${s.versionFooter(kAppVersion)} · github.com/nekonaru/boredom',
                style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(
    BuildContext context,
    AppStrings s,
    BoredomProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Text(s.resetTitle, style: const TextStyle(color: AppColors.textPrimary)),
        content: Text(
          s.resetBody,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(s.dialogCancel),
          ),
          TextButton(
            onPressed: () {
              provider.resetProgress();
              Navigator.of(context).pop();
            },
            child: Text(s.resetConfirm, style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
