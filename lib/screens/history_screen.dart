import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/boredom_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/quest_chain_section.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<BoredomProvider>().history;
    final dateFormat = DateFormat('d MMM, HH:mm');

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Text(
            'Missions',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const QuestChainSection(),
          const SizedBox(height: 24),
          const Text(
            'Riwayat',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Belum ada misi yang selesai.\nBalik ke Home dan klik "I\'M BORED".',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.8)),
              ),
            )
          else
            ...history.map((entry) {
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
                              '${entry.categoryLabel} · ${dateFormat.format(entry.completedAt)}',
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
            }),
        ],
      ),
    );
  }
}
