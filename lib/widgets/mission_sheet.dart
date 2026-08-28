import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mission.dart';
import '../providers/boredom_provider.dart';
import '../utils/app_theme.dart';

/// Tampilin mission card sebagai bottom sheet yang nggak bisa di-dismiss
/// asal-asalan (biar user mikir ACCEPT / REROLL, bukan swipe-away).
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
  // Guard di level UI: begitu ACCEPT ke-tap, semua tombol langsung
  // ke-disable sampai proses selesai/sheet ketutup. Lapis pertahanan kedua
  // di atas guard yang udah ada di BoredomProvider.completeMission() -
  // provider-nya emang udah aman dari dobel XP walau tombol ini nggak ada,
  // tapi ini nyegah spam-tap keliatan "nyala-nyala" sebelum sheet ketutup.
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BoredomProvider>();
    final instance = provider.currentMission;

    if (instance == null) {
      // Mission udah selesai/di-dismiss dari luar - tutup sheet.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const SizedBox.shrink();
    }

    final mission = instance.mission;
    final numberLabel = '#${instance.missionNumber.toString().padLeft(3, '0')}';

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: const BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MISSION $numberLabel',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(mission.emoji, style: const TextStyle(fontSize: 44)),
            const SizedBox(height: 8),
            Text(
              mission.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              mission.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _InfoPill(label: mission.category.label),
                _InfoPill(label: mission.difficultyStars),
                _InfoPill(label: '${mission.maxTime.minutes} min'),
                _InfoPill(label: '+${mission.baseXp} XP', highlight: true),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            final ok = provider.rerollMission();
                            if (!ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Reroll harian udah abis. Coba lagi besok 😅'),
                                ),
                              );
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text('REROLL (${provider.rerollsLeft})'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            setState(() => _isSubmitting = true);
                            await provider.completeMission();
                            // Nggak perlu setState(_isSubmitting = false) lagi:
                            // widget ini bakal ke-pop/dispose begitu
                            // currentMission jadi null (lewat postFrameCallback
                            // di atas), jadi state ini nggak akan sempat
                            // dipakai buat rebuild lagi.
                            if (context.mounted) Navigator.of(context).pop();
                          },
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text('ACCEPT & COMPLETE'),
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
                child: const Text(
                  'Skip buat sekarang',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlight ? AppColors.success.withValues(alpha: 0.18) : Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: highlight ? AppColors.success : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
