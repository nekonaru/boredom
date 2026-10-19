import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/mission.dart';
import '../models/user_progress.dart';
import '../providers/boredom_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import 'onboarding_screen.dart';
import '../utils/app_theme.dart';
import '../widgets/kit.dart';
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
    final reminderEnabled = context.select<BoredomProvider, bool>(
      (p) => p.reminderEnabled,
    );
    final reminderTime = context.select<BoredomProvider, int>(
      (p) => p.reminderHour * 60 + p.reminderMinute,
    );
    final muted = context.select<BoredomProvider, Set<String>>(
      (p) => p.mutedCategories,
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
        padding: const EdgeInsets.fromLTRB(AppKit.lg, AppKit.md, AppKit.lg, AppKit.xxl),
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
            const SizedBox(height: AppKit.xl),
            AppKit.card(
              color: pal.surface,
              padding: const EdgeInsets.all(AppKit.lg),
              child: XpBar(progress: progress),
            ),
            const SizedBox(height: AppKit.lg),
            Row(
              children: [
                Expanded(
                  child: AppKit.metricCard(context,
                    label: s.mTotalMissions,
                    value: '${progress.totalMissionsCompleted}',
                  ),
                ),
                const SizedBox(width: AppKit.md),
                Expanded(
                  child: AppKit.metricCard(context,
                    label: s.mActiveStreak,
                    value: s.days(progress.streakDays),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppKit.md),
            Row(
              children: [
                Expanded(
                  child: AppKit.metricCard(context,
                    label: s.mTotalXp,
                    value: '${progress.totalXp}',
                  ),
                ),
                const SizedBox(width: AppKit.md),
                Expanded(
                  child: AppKit.metricCard(context,
                    label: s.mRerollsToday,
                    value: '$rerollsLeft/$kMaxRerollsPerDay',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppKit.lg),
            AppKit.card(
              color: pal.surface,
              padding: const EdgeInsets.all(AppKit.lg),
              child: Row(
                children: [
                  const Text('❄️', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: AppKit.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${s.freezeTitle} · ${progress.freezeTokens}',
                          style: TextStyle(
                            color: pal.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: AppKit.xs),
                        Text(
                          s.freezeDesc(progress.freezeTokens),
                          style: TextStyle(
                            color: pal.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppKit.xxl),
            _AppearanceSection(
              s: s,
              pal: pal,
              isLight: isLight,
              accentIndex: accentIndex,
              hapticsEnabled: hapticsEnabled,
              provider: provider,
            ),
            const SizedBox(height: AppKit.xxl),
            _LanguageSection(
              s: s,
              pal: pal,
              isIndonesian: isIndonesian,
              provider: provider,
            ),
            const SizedBox(height: AppKit.xxl),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const OnboardingScreen(popOnFinish: true),
                  ),
                );
              },
              icon: const Icon(Icons.help_outline, size: 18),
              label: Text(s.replayOnboarding),
              style: OutlinedButton.styleFrom(
                foregroundColor: pal.accent,
                side: BorderSide(color: pal.accent),
                padding: const EdgeInsets.symmetric(vertical: AppKit.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppKit.rPill),
                ),
              ),
            ),
            const SizedBox(height: AppKit.xxl),
            _ReminderSection(
              s: s,
              pal: pal,
              reminderEnabled: reminderEnabled,
              reminderTime: reminderTime,
              provider: provider,
              onPickTime: () => _pickReminderTime(context, s, provider),
            ),
            const SizedBox(height: AppKit.xxl),
            _MutedSection(
              s: s,
              pal: pal,
              muted: muted,
              provider: provider,
            ),
            const SizedBox(height: AppKit.xxl),
            _BackupSection(
              s: s,
              pal: pal,
              provider: provider,
              onImport: () => _showImportDialog(context, s, provider),
            ),
            const SizedBox(height: AppKit.xxl),
            _AboutSection(
              s: s,
              pal: pal,
            ),
            const SizedBox(height: AppKit.xxl),
            AppKit.outlineButton(
              context: context,
              label: s.resetBtn,
              foregroundColor: pal.danger,
              onPressed: () => _confirmReset(context, s, provider),
            ),
            const SizedBox(height: AppKit.xxl),
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

  void _pickReminderTime(
    BuildContext context,
    AppStrings s,
    BoredomProvider provider,
  ) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: provider.reminderHour,
        minute: provider.reminderMinute,
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    ).then((picked) {
      if (picked == null) return;
      provider.setReminderTime(picked.hour, picked.minute);
    });
  }

  Future<void> _showImportDialog(
    BuildContext context,
    AppStrings s,
    BoredomProvider provider,
  ) async {
    final pal = context.palette;
    // Disposed after the dialog closes. The controller used to leak on
    // every open.
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            // Pops through the dialog's own context. Using the outer
            // ProfileScreen context meant a second pop could dismiss the
            // app's only route and close it.
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(s.dialogCancel),
          ),
          TextButton(
            onPressed: () async {
              final ok = await provider.importBackup(ctrl.text);
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(ok ? s.backupRestored : s.backupInvalid)),
              );
            },
            child: Text(s.backupImport),
          ),
        ],
      ),
    );
    ctrl.dispose();
  }

  void _confirmReset(
    BuildContext context,
    AppStrings s,
    BoredomProvider provider,
  ) {
    final pal = context.palette;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: pal.surfaceElevated,
        title: Text(s.resetTitle, style: TextStyle(color: pal.textPrimary)),
        content: Text(
          s.resetBody,
          style: TextStyle(color: pal.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(s.dialogCancel),
          ),
          TextButton(
            onPressed: () {
              provider.resetProgress();
              Navigator.of(dialogContext).pop();
            },
            child: Text(s.resetConfirm, style: TextStyle(color: pal.danger)),
          ),
        ],
      ),
    );
  }
}

/// Appearance: theme toggle, accent swatches, haptics.
class _AppearanceSection extends StatelessWidget {
  final AppStrings s;
  final AppPalette pal;
  final bool isLight;
  final int accentIndex;
  final bool hapticsEnabled;
  final BoredomProvider provider;

  const _AppearanceSection({
    required this.s,
    required this.pal,
    required this.isLight,
    required this.accentIndex,
    required this.hapticsEnabled,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppKit.sectionHeader(context, s, title: s.appearanceTitle),
        const SizedBox(height: AppKit.md),
        AppKit.card(
          color: pal.surface,
          padding: const EdgeInsets.all(AppKit.lg),
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
              const SizedBox(height: AppKit.md),
              Text(
                s.accentTitle,
                style: TextStyle(color: pal.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: AppKit.sm),
              Row(
                children: List.generate(
                  ThemeProvider.accents.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(right: AppKit.md),
                    child: Semantics(
                      label: s.accentName(i),
                      selected: i == accentIndex,
                      inMutuallyExclusiveGroup: true,
                      button: true,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppKit.rLg),
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
              ),
              const SizedBox(height: AppKit.lg),
              AppKit.toggleRow(
                context,
                emoji: '📳',
                title: s.hapticsTitle,
                subtitle: s.hapticsDesc,
                value: hapticsEnabled,
                onChanged: () => provider.setHapticsEnabled(!hapticsEnabled),
                activeColor: pal.accent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Language toggle + replay onboarding.
class _LanguageSection extends StatelessWidget {
  final AppStrings s;
  final AppPalette pal;
  final bool isIndonesian;
  final BoredomProvider provider;

  const _LanguageSection({
    required this.s,
    required this.pal,
    required this.isIndonesian,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppKit.sectionHeader(context, s, title: s.languageTitle),
        const SizedBox(height: AppKit.md),
        AppKit.card(
          color: pal.surface,
          padding: const EdgeInsets.symmetric(horizontal: AppKit.lg, vertical: AppKit.xs),
          child: Row(
            children: [
              const Text('🌍', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppKit.md),
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
      ],
    );
  }
}

/// Reminder toggle + time picker.
class _ReminderSection extends StatelessWidget {
  final AppStrings s;
  final AppPalette pal;
  final bool reminderEnabled;
  final int reminderTime;
  final BoredomProvider provider;
  final VoidCallback onPickTime;

  const _ReminderSection({
    required this.s,
    required this.pal,
    required this.reminderEnabled,
    required this.reminderTime,
    required this.provider,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppKit.sectionHeader(context, s, title: s.remindersTitle),
        const SizedBox(height: AppKit.md),
        Container(
          padding: const EdgeInsets.all(AppKit.lg),
          decoration: BoxDecoration(
            color: pal.surface,
            borderRadius: BorderRadius.circular(AppKit.rLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.remindersTitle,
                          style: TextStyle(color: pal.textPrimary, fontSize: 14),
                        ),
                        Text(
                          s.remindersDesc,
                          style: TextStyle(color: pal.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: reminderEnabled,
                    onChanged: (v) async {
                      final ok = await provider.setReminder(v);
                      if (!context.mounted) return;
                      if (v && !ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(s.reminderBlocked)),
                        );
                      }
                    },
                    activeThumbColor: pal.accent,
                  ),
                ],
              ),
              if (reminderEnabled) ...[
                const SizedBox(height: AppKit.sm),
                OutlinedButton.icon(
                  onPressed: onPickTime,
                  icon: const Icon(Icons.schedule, size: 18),
                  label: Text(
                    '${(reminderTime ~/ 60).toString().padLeft(2, '0')}:' 
                    '${(reminderTime % 60).toString().padLeft(2, '0')}',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: pal.accent,
                    side: BorderSide(color: pal.accent),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Muted categories filter chips.
class _MutedSection extends StatelessWidget {
  final AppStrings s;
  final AppPalette pal;
  final Set<String> muted;
  final BoredomProvider provider;

  const _MutedSection({
    required this.s,
    required this.pal,
    required this.muted,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppKit.sectionHeader(context, s, title: s.mutedCategories),
        const SizedBox(height: AppKit.xs),
        Text(
          s.mutedDesc,
          style: TextStyle(color: pal.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: AppKit.md),
        Wrap(
          spacing: AppKit.sm,
          runSpacing: AppKit.sm,
          children: MissionCategory.values
              .where((c) => c != MissionCategory.chaos)
              .map((c) {
            final isMuted = muted.contains(c.name);
            return FilterChip(
              label: Text(c.labelFor(s.code)),
              selected: isMuted,
              showCheckmark: false,
              avatar: Icon(
                isMuted ? Icons.visibility_off : Icons.visibility,
                size: 16,
                color: isMuted ? pal.warning : pal.textSecondary,
              ),
              backgroundColor: pal.surface,
              selectedColor: pal.warning.withValues(alpha: 0.18),
              labelStyle: TextStyle(
                color: isMuted ? pal.warning : pal.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (v) async {
                final changed = await provider.toggleCategoryMuted(c);
                if (!changed && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.muteLastBlocked)),
                  );
                }
              },
            );
          })
          .toList(),
        ),
      ],
    );
  }
}

/// Backup export / import.
class _BackupSection extends StatelessWidget {
  final AppStrings s;
  final AppPalette pal;
  final BoredomProvider provider;
  final VoidCallback onImport;

  const _BackupSection({
    required this.s,
    required this.pal,
    required this.provider,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppKit.sectionHeader(context, s, title: s.backupTitle),
        const SizedBox(height: AppKit.xs),
        Text(
          s.backupDesc,
          style: TextStyle(color: pal.textSecondary, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: AppKit.md),
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
                  padding: const EdgeInsets.symmetric(vertical: AppKit.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppKit.rPill),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppKit.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onImport,
                icon: const Icon(Icons.download_outlined, size: 18),
                label: Text(s.backupImport),
                style: OutlinedButton.styleFrom(
                  foregroundColor: pal.accent,
                  side: BorderSide(color: pal.accent),
                  padding: const EdgeInsets.symmetric(vertical: AppKit.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppKit.rPill),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// About text + version footer.
class _AboutSection extends StatelessWidget {
  final AppStrings s;
  final AppPalette pal;

  const _AboutSection({required this.s, required this.pal});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppKit.sectionHeader(context, s, title: s.aboutTitle),
        const SizedBox(height: AppKit.xs),
        Text(
          s.aboutBody,
          style: TextStyle(color: pal.textSecondary, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }
}
