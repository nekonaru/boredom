import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/custom_mission.dart';
import '../models/mission.dart';
import '../models/user_progress.dart';
import '../providers/boredom_provider.dart';
import '../services/mission_catalog.dart';
import '../utils/app_theme.dart';
import '../utils/date_format.dart';
import '../widgets/quest_chain_section.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final code = s.code;
    final history = context.select<BoredomProvider, List<CompletedMission>>(
      (p) => p.history,
    );
    final favorites = context.select<BoredomProvider, Set<String>>(
      (p) => p.favoriteIds,
    );
    final customMissions = context.select<BoredomProvider, List<CustomMission>>(
      (p) => p.customMissions,
    );
    final actions = context.read<BoredomProvider>();

    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? history
        : history
            .where((e) =>
                e.title.toLowerCase().contains(q) ||
                e.categoryLabel.toLowerCase().contains(q))
            .toList();
    final favoriteMissions = MissionCatalog.all
        .where((m) => favorites.contains(m.id))
        .toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverList.list(
              children: [
                Text(
                  s.missionsTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const QuestChainSection(),
                const SizedBox(height: 24),
                Text(
                  s.customTitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.customDesc,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _showAddCustomDialog(context, s),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(s.customAdd),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (customMissions.isEmpty)
                  Text(
                    s.customEmpty,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  )
                else
                  ...customMissions.map(
                    (m) => _CustomMissionTile(mission: m),
                  ),
                const SizedBox(height: 24),
                Text(
                  s.favoritesTitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (favoriteMissions.isEmpty)
                  Text(
                    s.favoritesEmpty,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  )
                else
                  ...favoriteMissions.map(
                    (m) => _FavoriteTile(
                      mission: m,
                      code: code,
                      onUnfavorite: () => actions.toggleFavorite(m.id),
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  s.historyTitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: s.searchHint,
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          if (filtered.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    q.isEmpty ? s.historyEmpty : s.searchEmpty,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final entry = filtered[index];
                  return _HistoryTile(entry: entry, code: code);
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showAddCustomDialog(BuildContext context, AppStrings s) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    double xp = 30;
    return showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          title: Text(
            s.customAdd,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 17),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    hintText: s.customNameHint,
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: s.customDescHint,
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                Text(
                  '${s.customXp}: ${xp.toInt()}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Slider(
                  value: xp,
                  min: 5,
                  max: 200,
                  divisions: 39,
                  label: '${xp.toInt()} XP',
                  onChanged: (v) => setDialogState(() => xp = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(s.dialogCancel),
            ),
            TextButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty ||
                    descCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.customInvalid)),
                  );
                  return;
                }
                context.read<BoredomProvider>().addCustomMission(
                      titleCtrl.text,
                      descCtrl.text,
                      xp.toInt(),
                    );
                Navigator.of(context).pop();
              },
              child: Text(s.customSave),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final CompletedMission entry;
  final String code;
  const _HistoryTile({required this.entry, required this.code});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(entry.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${entry.categoryLabel} · ${formatHistoryDate(entry.completedAt, code: code)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '+${entry.xpEarned} XP',
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  final Mission mission;
  final String code;
  final VoidCallback onUnfavorite;
  const _FavoriteTile({
    required this.mission,
    required this.code,
    required this.onUnfavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(mission.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizedTitle(en: mission.title, id: mission.titleId, code: code),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '+${mission.baseXp} XP',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onUnfavorite,
              icon: const Icon(Icons.favorite, color: AppColors.danger, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomMissionTile extends StatelessWidget {
  final CustomMission mission;
  const _CustomMissionTile({required this.mission});

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final actions = context.read<BoredomProvider>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Text('⭐', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    mission.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                final unlocked = await actions.completeCustomMission(mission);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      s.customDone(mission.title, mission.baseXp),
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
                for (final a in unlocked) {
                  if (!context.mounted) break;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${s.achievementSnack} ${a.emoji} ${localizedTitle(en: a.title, id: a.titleId, code: s.code)}',
                      ),
                      backgroundColor: AppColors.accent,
                    ),
                  );
                }
                actions.clearLastUnlockedAchievements();
              },
              child: Text('+${mission.baseXp} XP'),
            ),
            IconButton(
              onPressed: () => _confirmDelete(context, s, actions),
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    AppStrings s,
    BoredomProvider actions,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Text(
          s.deleteTitle,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(s.dialogCancel),
          ),
          TextButton(
            onPressed: () {
              actions.deleteCustomMission(mission.id);
              Navigator.of(context).pop();
            },
            child: Text(
              s.deleteConfirm,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
