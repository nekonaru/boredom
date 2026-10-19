import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/custom_mission.dart';
import '../models/mission.dart';
import '../models/user_progress.dart';
import '../providers/boredom_provider.dart';
import '../providers/theme_provider.dart';
import '../services/mission_catalog.dart';
import '../services/storage_service.dart';
import '../utils/date_format.dart';
import '../utils/feedback.dart';
import '../widgets/inbox_section.dart';
import '../widgets/quest_chain_section.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _query = '';
  _HistoryRange _range = _HistoryRange.all;
  _OutcomeFilter _outcomeFilter = _OutcomeFilter.all;

  bool _matchesRange(CompletedMission e, _HistoryRange range) {
    if (range == _HistoryRange.all) return true;
    final now = DateTime.now();
    final day = DateTime(
      e.completedAt.year,
      e.completedAt.month,
      e.completedAt.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    return switch (range) {
      _HistoryRange.today => diff == 0,
      _HistoryRange.week => diff >= 0 && diff < 7,
      _HistoryRange.month => diff >= 0 && diff < 30,
      _HistoryRange.all => true,
    };
  }

  bool _matchesOutcome(CompletedMission e, _OutcomeFilter filter) {
    return switch (filter) {
      _OutcomeFilter.all => true,
      // Rows with no outcome predate the feature, so they are neither
      // shown as successes nor hidden as failures.
      _OutcomeFilter.done => e.outcome == MissionOutcome.done,
      _OutcomeFilter.partial => e.outcome == MissionOutcome.partial,
      _OutcomeFilter.skipped => e.outcome == MissionOutcome.skipped,
      _OutcomeFilter.untracked => e.outcome == null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final pal = context.palette;
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
    final filtered = history
        .where((e) => _matchesRange(e, _range))
        .where((e) => _matchesOutcome(e, _outcomeFilter))
        // Search what the row actually shows, otherwise an Indonesian
        // search for "koding" would match nothing on screen.
        .where((e) =>
            q.isEmpty ||
            _titleFor(e, actions, code).toLowerCase().contains(q) ||
            _categoryFor(e, actions, code).toLowerCase().contains(q))
        .toList();
    final favoriteMissions = MissionCatalog.all
        .where((m) => favorites.contains(m.id))
        .toList();
    // Favorites pointing at missions this build no longer ships. They
    // used to vanish silently while still counting toward the stored set,
    // with no way for the user to see or clear them.
    final orphanFavorites = favorites
        .where((id) => actions.missionById(id) == null)
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
                  style: TextStyle(
                    color: pal.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const QuestChainSection(),
                const SizedBox(height: 24),
                const InboxSection(),
                const SizedBox(height: 24),
                Text(
                  s.customTitle,
                  style: TextStyle(
                    color: pal.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.customDesc,
                  style: TextStyle(
                    color: pal.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _showAddCustomDialog(context, s),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(s.customAdd),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: pal.accent,
                    side: BorderSide(color: pal.accent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (customMissions.isEmpty)
                  Text(
                    s.customEmpty,
                    style: TextStyle(
                      color: pal.textSecondary,
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
                  style: TextStyle(
                    color: pal.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (favoriteMissions.isEmpty)
                  Text(
                    s.favoritesEmpty,
                    style: TextStyle(
                      color: pal.textSecondary,
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
                if (orphanFavorites.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    s.favoriteOrphans(orphanFavorites.length),
                    style: TextStyle(color: pal.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => actions.pruneOrphanFavorites(),
                    icon: const Icon(Icons.cleaning_services_outlined, size: 16),
                    label: Text(s.favoritePruneAction),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  s.historyTitle,
                  style: TextStyle(
                    color: pal.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: s.searchHint,
                    hintStyle: TextStyle(
                      color: pal.textSecondary,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: pal.textSecondary,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: pal.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  style: TextStyle(
                    color: pal.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final r in _HistoryRange.values)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(s.historyRangeLabel(r)),
                            selected: _range == r,
                            onSelected: (_) => setState(() => _range = r),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final o in _OutcomeFilter.values)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(s.outcomeFilterLabel(o)),
                            selected: _outcomeFilter == o,
                            onSelected: (_) =>
                                setState(() => _outcomeFilter = o),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Says out loud how many rows are stored versus how many
                // you have actually completed, so a capped list can never
                // be mistaken for the whole record.
                Text(
                  s.historyCount(filtered.length, history.length),
                  style: TextStyle(
                    color: pal.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                if (history.length >= StorageService.kMaxHistoryEntries)
                  Text(
                    s.historyCapNotice(StorageService.kMaxHistoryEntries),
                    style: TextStyle(
                      color: pal.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 8),
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
                    (q.isEmpty && _range == _HistoryRange.all &&
                            _outcomeFilter == _OutcomeFilter.all)
                        ? s.historyEmpty
                        : s.searchEmpty,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: pal.textSecondary),
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
                  return _HistoryTile(
                    entry: entry,
                    code: code,
                    actions: actions,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showAddCustomDialog(BuildContext context, AppStrings s) async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    double xp = 30;
    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final pal = context.palette;
          return AlertDialog(
            backgroundColor: pal.surfaceElevated,
            title: Text(
              s.customAdd,
              style: TextStyle(color: pal.textPrimary, fontSize: 17),
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
                      hintStyle: TextStyle(color: pal.textSecondary),
                    ),
                    style: TextStyle(color: pal.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: s.customDescHint,
                      hintStyle: TextStyle(color: pal.textSecondary),
                    ),
                    style: TextStyle(color: pal.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${s.customXp}: ${xp.toInt()}',
                    style: TextStyle(
                      color: pal.textSecondary,
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
                    // The dialog closed with a plain return, leaving the
                    // modal barrier on top of the Scaffold, so the
                    // snackbar was invisible: tapping Save looked like it
                    // did nothing at all.
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(this.context).showSnackBar(
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
          );
        },
      ),
    );
    // Both controllers used to be leaked on every open.
    titleCtrl.dispose();
    descCtrl.dispose();
  }
}

/// Date windows offered above the history list.
enum _HistoryRange { today, week, month, all }

/// Outcome filters offered above the history list.
enum _OutcomeFilter { all, done, partial, skipped, untracked }

/// Resolves a history entry's title in the active language.
///
/// History stores the English text at the moment of completion, so an
/// Indonesian user used to see an English list even with the app set to
/// Indonesian. The catalog is the source of truth, and only entries that
/// no longer resolve (custom missions, or missions dropped from the
/// catalog) fall back to the stored string.
String _titleFor(CompletedMission entry, BoredomProvider provider, String code) =>
    provider.missionById(entry.missionId)?.titleFor(code) ?? entry.title;

/// Same resolution rule as [_titleFor], for the category line.
String _categoryFor(
  CompletedMission entry,
  BoredomProvider provider,
  String code,
) =>
    provider.missionById(entry.missionId)?.category.labelFor(code) ??
    entry.categoryLabel;

/// One tappable outcome row in the custom-mission bottom sheet.
class _OutcomeOption extends StatelessWidget {
  final String label;
  final String emoji;
  final VoidCallback onTap;
  const _OutcomeOption({
    required this.label,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: pal.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: pal.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small pill showing how a completion actually went. Rows saved before
/// outcome tracking have no outcome and render nothing.
class _OutcomeBadge extends StatelessWidget {
  final MissionOutcome outcome;
  final String code;
  const _OutcomeBadge({required this.outcome, required this.code});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final s = context.str;
    final (label, color) = switch (outcome) {
      MissionOutcome.done => (s.outcomeDoneShort, pal.success),
      MissionOutcome.partial => (s.outcomePartialShort, pal.warning),
      MissionOutcome.skipped => (s.outcomeSkippedShort, pal.textSecondary),
    };
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final CompletedMission entry;
  final String code;
  final BoredomProvider actions;
  const _HistoryTile({
    required this.entry,
    required this.code,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: pal.surface,
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
                    _titleFor(entry, actions, code),
                    style: TextStyle(
                      color: pal.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_categoryFor(entry, actions, code)} · ${formatHistoryDate(entry.completedAt, code: code)}',
                    style: TextStyle(
                      color: pal.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  if (entry.outcome != null) ...[
                    const SizedBox(height: 6),
                    _OutcomeBadge(outcome: entry.outcome!, code: code),
                  ],
                ],
              ),
            ),
            Text(
              '+${entry.xpEarned} XP',
              style: TextStyle(
                color: pal.success,
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
    final pal = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: pal.surface,
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
                    style: TextStyle(
                      color: pal.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '+${mission.baseXp} XP',
                    style: TextStyle(
                      color: pal.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onUnfavorite,
              icon: Icon(Icons.favorite, color: pal.danger, size: 20),
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
    final pal = context.palette;
    final actions = context.read<BoredomProvider>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: pal.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: pal.accent.withValues(alpha: 0.3)),
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
                    style: TextStyle(
                      color: pal.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    mission.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: pal.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                buzzIfEnabled(context);
                // Same three-way outcome as the mission sheet, so custom
                // missions are measured the same way.
                final outcome = await showModalBottomSheet<MissionOutcome>(
                  context: context,
                  builder: (sheetContext) => SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            s.outcomeQuestion,
                            style: TextStyle(
                              color: context.palette.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _OutcomeOption(
                            label: s.outcomeDone,
                            emoji: '✅',
                            onTap: () => Navigator.of(sheetContext)
                                .pop(MissionOutcome.done),
                          ),
                          _OutcomeOption(
                            label: s.outcomePartial,
                            emoji: '🟡',
                            onTap: () => Navigator.of(sheetContext)
                                .pop(MissionOutcome.partial),
                          ),
                          _OutcomeOption(
                            label: s.outcomeSkipped,
                            emoji: '⭕️',
                            onTap: () => Navigator.of(sheetContext)
                                .pop(MissionOutcome.skipped),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                // Dismissed without answering: record nothing rather than
                // assuming a success.
                if (outcome == null || !context.mounted) return;
                final unlocked =
                    await actions.completeCustomMission(mission, outcome);
                if (!context.mounted) return;
                // Report what was actually awarded (weekend double XP and
                // milestone bonuses included), not the base reward.
                final gained = actions.lastXpGained ?? mission.baseXp;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      s.customDone(mission.title, gained),
                    ),
                    backgroundColor: pal.success,
                        action: actions.canUndo
                            ? SnackBarAction(
                                label: s.undoAction,
                                textColor: Colors.white,
                                onPressed: () async {
                                  final ok = await actions.undoLastAction();
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
                for (final a in unlocked) {
                  if (!context.mounted) break;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${s.achievementSnack} ${a.emoji} ${localizedTitle(en: a.title, id: a.titleId, code: s.code)}',
                      ),
                      backgroundColor: pal.accent,
                    ),
                  );
                }
                actions.clearLastUnlockedAchievements();
              },
              child: Text('+${mission.baseXp} XP'),
            ),
            IconButton(
              onPressed: () => _confirmDelete(context, s, actions),
              icon: Icon(
                Icons.delete_outline,
                color: pal.textSecondary,
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
    final pal = context.palette;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: pal.surfaceElevated,
        title: Text(
          s.deleteTitle,
          style: TextStyle(color: pal.textPrimary, fontSize: 16),
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
              style: TextStyle(color: pal.danger),
            ),
          ),
        ],
      ),
    );
  }
}
