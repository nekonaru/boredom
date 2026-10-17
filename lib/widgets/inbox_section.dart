import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/mission.dart';
import '../models/saved_mission.dart';
import '../providers/boredom_provider.dart';
import '../providers/theme_provider.dart';

/// Missions parked for later. Kept to 50 entries, newest first.
class InboxSection extends StatelessWidget {
  const InboxSection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final pal = context.palette;
    final code = s.code;
    final saved = context.select<BoredomProvider, List<SavedMission>>(
      (p) => p.savedMissions,
    );
    final actions = context.read<BoredomProvider>();

    final entries = <Widget>[];
    for (final entry in saved) {
      final mission = actions.missionById(entry.missionId);
      if (mission == null) continue;
      entries.add(_InboxTile(mission: mission, code: code));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.inboxTitle,
          style: TextStyle(
            color: pal.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          Text(
            s.inboxEmpty,
            style: TextStyle(color: pal.textSecondary, fontSize: 12),
          )
        else
          ...entries,
      ],
    );
  }
}

class _InboxTile extends StatelessWidget {
  final Mission mission;
  final String code;
  const _InboxTile({required this.mission, required this.code});

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
          border: Border.all(color: pal.warning.withValues(alpha: 0.3)),
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
                    style: TextStyle(color: pal.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                final restored = await actions.restoreSavedMission();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(restored ? s.inboxRestored : s.inboxDone)),
                );
              },
              child: Text(s.playSaved),
            ),
            IconButton(
              onPressed: () async {
                await actions.removeSavedMission(mission.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.inboxDone)),
                  );
                }
              },
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
}