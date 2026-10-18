import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/mission.dart';
import '../models/user_progress.dart';
import '../providers/boredom_provider.dart';
import '../providers/theme_provider.dart';
import '../services/share_card.dart';
import '../utils/feedback.dart';

/// Shows the mission card as a bottom sheet that cannot be casually
/// dismissed (so the user thinks ACCEPT vs REROLL instead of swiping away).
Future<void> showMissionSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: false,
    builder: (_) => const MissionSheet(),
  );
}

class MissionSheet extends StatefulWidget {
  const MissionSheet({super.key});

  @override
  State<MissionSheet> createState() => _MissionSheetState();
}

class _MissionSheetState extends State<MissionSheet> {
  // UI-level guard: once ACCEPT is tapped, every button disables until the
  // flow finishes or the sheet closes. Second layer above the guard already
  // in BoredomProvider.completeMission: the provider is safe from double XP
  // even without this, but this stops spam taps from visibly flickering.
  bool _isSubmitting = false;

  /// Single entry point for all three outcome buttons, so the submitting
  /// guard and the pop behave identically no matter which was tapped.
  Future<void> _submit(
    BuildContext context,
    BoredomProvider provider,
    MissionOutcome outcome,
  ) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    buzzIfEnabled(context);
    await provider.completeMission(outcome);
    // No need to reset _isSubmitting: this widget is popped/disposed once
    // currentMission becomes null (via the post-frame callback above), so
    // this state never rebuilds again.
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.str;
    final pal = context.palette;
    final instance = context.select<BoredomProvider, MissionInstance?>(
      (p) => p.currentMission,
    );

    if (instance == null) {
      // Mission was finished or dismissed from outside, close the sheet.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const SizedBox.shrink();
    }

    final provider = context.read<BoredomProvider>();
    final mission = instance.mission;
    final code = s.code;
    final title = localizedTitle(en: mission.title, id: mission.titleId, code: code);
    final description = localizedTitle(
      en: mission.description,
      id: mission.descriptionId,
      code: code,
    );
    final isFav = context.select<BoredomProvider, bool>(
      (p) => p.isFavorite(mission.id),
    );
    final isDisliked = context.select<BoredomProvider, bool>(
      (p) => p.isDisliked(mission.id),
    );
    final isSaved = context.select<BoredomProvider, bool>(
      (p) => p.isSavedForLater(mission.id),
    );
    final categoryMuted = context.select<BoredomProvider, bool>(
      (p) => p.isCategoryMuted(mission.category.name),
    );
    final rerollsLeft = context.select<BoredomProvider, int>(
      (p) => p.rerollsLeft,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: pal.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        // Scrollable so long titles, big text scales, and short viewports
        // do not overflow.
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.missionNo(instance.missionNumber),
                    style: TextStyle(
                      color: pal.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => provider.toggleFavorite(mission.id),
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? pal.danger : pal.textSecondary,
                  ),
                ),
                IconButton(
                  onPressed: () => provider.toggleDislike(mission.id),
                  icon: Icon(
                    isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                    color: isDisliked ? pal.warning : pal.textSecondary,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await provider.saveForLater(mission.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(s.savedForLater)),
                      );
                    }
                  },
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved ? pal.success : pal.textSecondary,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final box = context.findRenderObject() as RenderBox?;
                    final origin = box == null
                        ? null
                        : box.localToGlobal(Offset.zero) & box.size;
                    // The sheet is shown before the mission is accepted, so
                    // this is the XP the mission is worth *now*: on a
                    // weekend the base value would understate it by half.
                    final projectedXp =
                        BoredomProvider.xpForDate(mission.baseXp, DateTime.now());
                    final ok = await ShareCard.shareMission(
                      emoji: mission.emoji,
                      title: title,
                      description: description,
                      xp: projectedXp,
                      level: provider.progress.level,
                      levelTitle:
                          provider.progress.levelTitleFor(s.code),
                      accent: pal.accent,
                      background: pal.background,
                      origin: origin,
                    );
                    if (!ok && context.mounted) {
                      // Fall back to plain text so a share is never a
                      // silent no-op.
                      await ShareCard.shareText(
                        s.shareText(
                          title,
                          projectedXp,
                          provider.progress.level,
                        ),
                        origin: origin,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(s.shareCardFailed)),
                        );
                      }
                    }
                  },
                  icon: Icon(Icons.ios_share, color: pal.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(mission.emoji, style: const TextStyle(fontSize: 44)),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: pal.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(
                color: pal.textSecondary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _InfoPill(label: mission.category.labelFor(code)),
                _InfoPill(label: mission.difficultyStars),
                _InfoPill(label: s.minutesShort(mission.maxTime.minutes)),
                _InfoPill(label: '+${mission.baseXp} XP', highlight: true),
                if (BoredomProvider.isWeekend(DateTime.now()))
                  _InfoPill(label: s.weekendTag, highlight: true),
                if (categoryMuted) _InfoPill(label: s.mutedLabel),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async {
                  final changed = await provider.toggleCategoryMuted(
                    mission.category,
                  );
                  if (!changed && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(s.muteLastBlocked)),
                    );
                  }
                },
                icon: const Icon(Icons.visibility_off_outlined, size: 16),
                label: Text(
                  categoryMuted ? s.unmuted : s.notInterested,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: pal.textSecondary,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            buzzIfEnabled(context);
                            final ok = await provider.rerollMission();
                            if (!ok && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(s.rerollEmpty),
                                ),
                              );
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: pal.textPrimary,
                      side: BorderSide(
                        color: pal.textSecondary.withValues(alpha: 0.3),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(s.rerollBtn(rerollsLeft)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => _submit(context, provider, MissionOutcome.done),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(s.acceptBtn),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Outcome tracking. One extra row, no extra tap: the primary
            // button above is still "Done", and these record the honest
            // answer without a follow-up dialog that could be dismissed
            // and lose the completion.
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () =>
                            _submit(context, provider, MissionOutcome.partial),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: pal.textPrimary,
                      side: BorderSide(
                        color: pal.textSecondary.withValues(alpha: 0.3),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      s.outcomePartial,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () =>
                            _submit(context, provider, MissionOutcome.skipped),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: pal.textSecondary,
                      side: BorderSide(
                        color: pal.textSecondary.withValues(alpha: 0.3),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      s.outcomeSkipped,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        provider.dismissMission();
                        Navigator.of(context).pop();
                      },
                child: Text(
                  s.skipBtn,
                  style: TextStyle(color: pal.textSecondary),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final bool highlight;
  const _InfoPill({required this.label, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlight ? pal.success.withValues(alpha: 0.18) : pal.emptyBar,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: highlight ? pal.success : pal.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
