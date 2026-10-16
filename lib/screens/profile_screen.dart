import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/user_progress.dart';
import '../providers/boredom_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/xp_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final pal = context.palette;
    final progress = context.select<BoredomProvider, UserProgress>(
      (p) => p.progress,
    );
    final rerollsLeft = context.select<BoredomProvider, int>(
      (p) => p.rerollsLeft,
    );
    final hapticsEnabled = context.select<BoredomProvider, bool>(
      (p) => p.hapticsEnabled,
    );
    final isIndonesian = context.select<LanguageProvider, bool>(
      (p) => p.isIndonesian,
    );
    final isLight = context.select<ThemeProvider, bool>(
      (p) => p.isLight,
    );
    final accentIndex = context.select<ThemeProvider, int>(
      (p) => p.accentIndex,
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
              style: TextStyle(
                color: pal.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: pal.surface,
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
              s.appearanceTitle,
              style: TextStyle(color: pal.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: pal.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(value: false, label: Text(s.themeDark)),
                      ButtonSegment(value: true, label: Text(s.themeLight)),
                    ],
                    selected: {isLight},
                    onSelectionChanged: (selected) {
                      context.read<ThemeProvider>().setLight(selected.first);
                    },
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    s.accentTitle,
                    style: TextStyle(color: pal.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(
                      ThemeProvider.accents.length,
                      (i) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () =>
                              context.read<ThemeProvider>().setAccent(i),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ThemeProvider.accents[i],
                              border: Border.all(
                                color: i == accentIndex
                                    ? pal.textPrimary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: i == accentIndex
                                ? const Icon(Icons.check, color: Colors.white, size: 18)
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.hapticsTitle,
                              style: TextStyle(color: pal.textPrimary, fontSize: 14),
                            ),
                            Text(
                              s.hapticsDesc,
                              style: TextStyle(color: pal.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: hapticsEnabled,
                        onChanged: provider.setHapticsEnabled,
                        activeThumbColor: pal.accent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              s.languageTitle,
              style: TextStyle(color: pal.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: pal.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('🌍', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isIndonesian ? s.languageIndonesian : s.languageEnglish,
                      style: TextStyle(color: pal.textPrimary, fontSize: 14),
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
              s.backupTitle,
              style: TextStyle(color: pal.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              s.backupDesc,
              style: TextStyle(color: pal.textSecondary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final text = await provider.exportBackup();
                      await Clipboard.setData(ClipboardData(text: text));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(s.backupCopied)),
                        );
                      }
                    },
                    icon: const Icon(Icons.upload_outlined, size: 18),
                    label: Text(s.backupExport),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: pal.accent,
                      side: BorderSide(color: pal.accent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showImportDialog(context, s, provider),
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: Text(s.backupImport),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: pal.accent,
                      side: BorderSide(color: pal.accent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              s.aboutTitle,
              style: TextStyle(color: pal.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              s.aboutBody,
              style: TextStyle(color: pal.textSecondary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _confirmReset(context, s, provider),
                style: OutlinedButton.styleFrom(
                  foregroundColor: pal.danger,
                  side: BorderSide(color: pal.danger),
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
                style: TextStyle(color: pal.textSecondary.withValues(alpha: 0.6), fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImportDialog(
    BuildContext context,
    AppStrings s,
    BoredomProvider provider,
  ) {
    final pal = context.palette;
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: pal.surfaceElevated,
        title: Text(s.backupImport, style: TextStyle(color: pal.textPrimary, fontSize: 17)),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          decoration: InputDecoration(hintText: s.backupPasteHint),
          style: TextStyle(color: pal.textPrimary, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(s.dialogCancel),
          ),
          TextButton(
            onPressed: () async {
              final ok = await provider.importBackup(ctrl.text);
              if (!context.mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(ok ? s.backupRestored : s.backupInvalid)),
              );
            },
            child: Text(s.backupImport),
          ),
        ],
      ),
    );
  }

  void _confirmReset(
    BuildContext context,
    AppStrings s,
    BoredomProvider provider,
  ) {
    final pal = context.palette;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: pal.surfaceElevated,
        title: Text(s.resetTitle, style: TextStyle(color: pal.textPrimary)),
        content: Text(
          s.resetBody,
          style: TextStyle(color: pal.textSecondary),
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
            child: Text(s.resetConfirm, style: TextStyle(color: pal.danger)),
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
    final pal = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  color: pal.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: pal.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
