import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/mission.dart';
import '../models/user_progress.dart';
import '../providers/boredom_provider.dart';
import '../providers/theme_provider.dart';
import '../services/mission_catalog.dart';
import '../widgets/kit.dart';
import '../widgets/mission_sheet.dart';

/// A single search surface across the mission catalog and completion
/// history. Opening a result either rolls that mission for review or shows
/// the saved reflection, without leaving the current tab.
Future<void> showQuickFind(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _QuickFindSheet(),
    );

class _QuickFindSheet extends StatefulWidget {
  const _QuickFindSheet();

  @override
  State<_QuickFindSheet> createState() => _QuickFindSheetState();
}

class _QuickFindSheetState extends State<_QuickFindSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final pal = context.palette;
    final code = s.code;
    final query = _controller.text.trim().toLowerCase();

    final provider = context.read<BoredomProvider>();
    final missions = MissionCatalog.all.where((m) {
      if (query.isEmpty) return false;
      final title = localizedTitle(en: m.title, id: m.titleId, code: code);
      return title.toLowerCase().contains(query) ||
          m.category.labelFor(code).toLowerCase().contains(query);
    }).take(8).toList();

    final history = context.select<BoredomProvider, List<CompletedMission>>(
      (p) => p.history,
    );
    final matches = history.where((e) {
      if (query.isEmpty) return false;
      return e.title.toLowerCase().contains(query) ||
          e.categoryLabel.toLowerCase().contains(query);
    }).take(8).toList();

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        decoration: BoxDecoration(
          color: pal.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppKit.rXl)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppKit.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                style: TextStyle(color: pal.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: s.quickFindHint,
                  hintStyle: TextStyle(color: pal.textSecondary, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: pal.textSecondary),
                  filled: true,
                  fillColor: pal.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppKit.rMd),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppKit.md),
              Expanded(
                child: query.isEmpty
                    ? Center(
                        child: Text(
                          s.quickFindEmptyPrompt,
                          style: TextStyle(
                            color: pal.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ListView(
                        shrinkWrap: true,
                        children: [
                          if (missions.isNotEmpty)
                            AppKit.sectionHeader(context, s,
                                title: s.quickFindMissions),
                          ...missions.map(
                            (m) => ListTile(
                              dense: true,
                              leading: Text(m.emoji,
                                  style: const TextStyle(fontSize: 20)),
                              title: Text(
                                localizedTitle(
                                    en: m.title, id: m.titleId, code: code),
                                style: TextStyle(
                                    color: pal.textPrimary, fontSize: 13),
                              ),
                              subtitle: Text(
                                '+${m.baseXp} XP',
                                style: TextStyle(
                                    color: pal.textSecondary, fontSize: 11),
                              ),
                              onTap: () async {
                                final ok = await provider.replayMission(m.id);
                                if (ok && context.mounted) {
                                  Navigator.of(context).pop();
                                  await showMissionSheet(context);
                                }
                              },
                            ),
                          ),
                          if (matches.isNotEmpty)
                            AppKit.sectionHeader(context, s,
                                title: s.quickFindHistory),
                          ...matches.map(
                            (e) => ListTile(
                              dense: true,
                              leading: Text(e.emoji,
                                  style: const TextStyle(fontSize: 20)),
                              title: Text(
                                e.title,
                                style: TextStyle(
                                    color: pal.textPrimary, fontSize: 13),
                              ),
                              subtitle: Text(
                                '+${e.xpEarned} XP',
                                style: TextStyle(
                                    color: pal.textSecondary, fontSize: 11),
                              ),
                            ),
                          ),
                          if (missions.isEmpty && matches.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(AppKit.xl),
                              child: Text(
                                s.quickFindNoResults,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: pal.textSecondary),
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
