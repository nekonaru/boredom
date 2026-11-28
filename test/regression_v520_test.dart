import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boredom/models/journal_entry.dart';
import 'package:boredom/models/mission.dart';
import 'package:boredom/models/user_progress.dart';
import 'package:boredom/providers/boredom_provider.dart';
import 'package:boredom/services/insights.dart';
import 'package:boredom/services/mission_catalog.dart';
import 'package:boredom/services/storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    StorageService.instance.clearCache();
  });

  group('v5.2 journal model', () {
    test('round trips all fields and falls back safely on junk', () {
      final entry = JournalEntry(
        missionId: 'm1',
        note: 'felt good',
        mood: JournalMood.great,
        writtenAt: DateTime(2026, 11, 28, 9, 30),
      );
      final restored = JournalEntry.fromJson(entry.toJson());
      expect(restored.missionId, 'm1');
      expect(restored.note, 'felt good');
      expect(restored.mood, JournalMood.great);
      expect(restored.writtenAt, DateTime(2026, 11, 28, 9, 30));
      final junk = JournalEntry.fromJson({'mood': 'nonsense'});
      expect(junk.mood, JournalMood.okay);
    });
  });

  group('v5.2 category roll', () {
    test('rollFromCategory refuses when a mission is active', () async {
      final provider = BoredomProvider()..init();
      final category = MissionCategory.outdoor;
      expect(await provider.rollFromCategory(category.name), isTrue);
      expect(provider.currentMission?.mission.category, category);
      expect(await provider.rollFromCategory(category.name), isFalse);
    });

    test('rollFromCategory honors dislikes', () async {
      final provider = BoredomProvider()..init();
      final pool = MissionCatalog.all
          .where((m) => m.category == MissionCategory.creative)
          .toList();
      provider.dislikedIds = pool.map((m) => m.id).toSet();
      expect(await provider.rollFromCategory(MissionCategory.creative.name),
          isFalse);
    });
  });

  group('v5.2 insight action', () {
    test('skipped insight carries a category for the roll action', () {
      final base = DateTime(2026, 11, 28);
      final outdoorIds = MissionCatalog.all
          .where((m) => m.category == MissionCategory.outdoor)
          .map((m) => m.id)
          .toList();
      expect(outdoorIds.length, greaterThan(1));
      final history = List.generate(
        4,
        (i) => CompletedMission(
          missionId: outdoorIds[i % outdoorIds.length],
          title: 'Outdoor $i',
          emoji: '🌳',
          categoryLabel: 'Outdoor',
          xpEarned: 0,
          completedAt: base.subtract(Duration(days: i)),
          outcome: MissionOutcome.skipped,
        ),
      );
      final items = Insights.build(history, base);
      final actionable = items.where((i) => i.categoryName != null).toList();
      expect(actionable, isNotEmpty);
      expect(actionable.first.categoryName, MissionCategory.outdoor.name);
    });
  });
}
