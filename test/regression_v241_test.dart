import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boredom/models/mission.dart';
import 'package:boredom/models/user_progress.dart';
import 'package:boredom/providers/boredom_provider.dart';
import 'package:boredom/services/mission_catalog.dart';
import 'package:boredom/services/mission_service.dart';
import 'package:boredom/services/storage_service.dart';

MissionFilter _filter() => const MissionFilter(
      mood: Mood.normal,
      timeBudget: TimeBudget.thirtyMin,
      location: LocationType.anywhere,
      energy: EnergyLevel.medium,
    );

/// Fails the analyzer as a test if a provider field is ever mutated in
/// place again, which `context.select` cannot observe.
void expectNewInstance(Object? before, Object? after, String label) {
  expect(identical(before, after), isFalse, reason: '$label must be a new instance');
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    StorageService.instance.clearCache();
  });

  group('Regressions: select needs new instances', () {
    test('toggleFavorite publishes a new Set', () async {
      final p = BoredomProvider();
      await p.toggleFavorite('home_01');
      final afterFirst = p.favoriteIds;
      expect(afterFirst.contains('home_01'), isTrue);

      await p.toggleFavorite('home_02');
      expectNewInstance(afterFirst, p.favoriteIds, 'favoriteIds');

      await p.toggleFavorite('home_01');
      expect(p.favoriteIds.contains('home_01'), isFalse);
      expect(p.isFavorite('home_02'), isTrue);
    });

    test('toggleCategoryMuted publishes a new Set', () async {
      final p = BoredomProvider();
      expect(await p.toggleCategoryMuted(MissionCategory.gaming), isTrue);
      final afterFirst = p.mutedCategories;
      expect(p.isCategoryMuted(MissionCategory.gaming.name), isTrue);

      expect(await p.toggleCategoryMuted(MissionCategory.coding), isTrue);
      expectNewInstance(afterFirst, p.mutedCategories, 'mutedCategories');
      expect(p.isCategoryMuted(MissionCategory.coding.name), isTrue);
    });

    test('the last playable category cannot be muted', () async {
      final p = BoredomProvider();
      final playable = MissionCategory.values
          .where((c) => c != MissionCategory.chaos)
          .toList();
      for (final c in playable.sublist(0, playable.length - 1)) {
        expect(await p.toggleCategoryMuted(c), isTrue);
      }
      // Muting the final one is refused so the generator still has content.
      expect(await p.toggleCategoryMuted(playable.last), isFalse);
      expect(p.isCategoryMuted(playable.last.name), isFalse);
    });

    test('inbox mutations publish a new list', () async {
      final p = BoredomProvider();
      await p.saveForLater('home_01');
      final afterFirst = p.savedMissions;
      expect(p.isSavedForLater('home_01'), isTrue);

      await p.saveForLater('home_02');
      expectNewInstance(afterFirst, p.savedMissions, 'savedMissions');

      await p.removeSavedMission('home_01');
      expect(p.isSavedForLater('home_01'), isFalse);
    });
  });

  group('Regressions: inbox restore', () {
    test('restores the exact mission that was tapped', () async {
      final p = BoredomProvider();
      await p.saveForLater('home_01');
      await p.saveForLater('code_02');

      final restored = await p.restoreSavedMission('code_02');
      expect(restored, isNotNull);
      expect(restored!.mission.id, 'code_02');
      // The other inbox entry is untouched.
      expect(p.isSavedForLater('home_01'), isTrue);
      expect(p.isSavedForLater('code_02'), isFalse);
    });

    test('returns null for an id that is not in the inbox', () async {
      final p = BoredomProvider();
      expect(await p.restoreSavedMission('home_01'), isNull);
    });

    test('a restored mission survives a later roll only by being replaced',
        () async {
      // Documents the original bug: rollMission always overwrites the
      // restored slot, which is why InboxSection opens the sheet directly.
      final p = BoredomProvider();
      await p.saveForLater('home_01');
      final restored = await p.restoreSavedMission('home_01');
      expect(restored, isNotNull);

      p.rollMission();
      expect(identical(p.currentMission, restored), isFalse);
    });
  });

  group('Regressions: milestone XP', () {
    test('pays once when a boundary is crossed, not every completion', () {
      // 9500 XP is the exact threshold for level 20.
      const atBoundary = 9500;
      expect(BoredomProvider.milestoneLevel(atBoundary - 1, 0,
              DateTime(2026, 1, 5)),
          19);
      // Crossing 20 pays 60.
      expect(BoredomProvider.milestoneXpFor(atBoundary - 1, 30,
              DateTime(2026, 1, 5)),
          60);
      // Sitting on level 20 pays nothing more.
      expect(BoredomProvider.milestoneXpFor(atBoundary, 30,
              DateTime(2026, 1, 5)),
          0);
      expect(BoredomProvider.milestoneXpFor(atBoundary + 500, 30,
              DateTime(2026, 1, 5)),
          0);
    });

    test('counts every boundary when a jump skips one', () {
      // A huge grant from level 19 to level 21 crosses level 20 only.
      final jump = BoredomProvider.milestoneXpFor(
        9400,
        300,
        DateTime(2026, 1, 5),
      );
      expect(jump, 60);
    });
  });

  group('Regressions: muted categories', () {
    test('chaos mode also honours muted categories', () {
      for (var i = 0; i < 200; i++) {
        final mission = MissionService.generate(
          _filter(),
          chaosMode: true,
          excludeCategories: {MissionCategory.chaos.name},
        );
        expect(mission.category.name, isNot(MissionCategory.chaos.name));
      }
    });
  });

  group('Regressions: history persistence', () {
    test('saveHistory keeps the newest entries oldest-first', () async {
      final storage = StorageService.instance;
      // 205 entries, newest first, as the provider holds them.
      final newestFirst = List.generate(
        205,
        (i) => CompletedMission(
          missionId: 'm$i',
          title: 'Mission $i',
          emoji: '🧪',
          categoryLabel: 'Test',
          xpEarned: 10,
          // Higher index = older, so index 0 is the newest.
          completedAt: DateTime(2026, 1, 1).add(Duration(minutes: 205 - i)),
        ),
      );

      await storage.saveHistory(newestFirst);
      final loaded = await storage.loadHistory();

      expect(loaded.length, 200);
      // The newest 200 survive; the 5 oldest are dropped.
      expect(loaded.first.missionId, 'm4');
      expect(loaded.last.missionId, 'm204');
      expect(loaded.map((e) => e.missionId), isNot(contains('m0')));
    });

    test('history stays ordered after appending past the cap', () async {
      final storage = StorageService.instance;
      final list = List.generate(
        199,
        (i) => CompletedMission(
          missionId: 'm$i',
          title: 'Mission $i',
          emoji: '🧪',
          categoryLabel: 'Test',
          xpEarned: 10,
          completedAt: DateTime(2026, 1, 1).add(Duration(minutes: i)),
        ),
      );
      await storage.saveHistory(list);

      // Now append two more through the normal path.
      for (var i = 0; i < 2; i++) {
        await storage.addHistoryEntry(
          CompletedMission(
            missionId: 'new$i',
            title: 'New $i',
            emoji: '🧪',
            categoryLabel: 'Test',
            xpEarned: 10,
            completedAt: DateTime(2026, 1, 2),
          ),
        );
      }

      final loaded = await storage.loadHistory();
      expect(loaded.length, 200);
      // The newest entry must not have been silently dropped.
      expect(loaded.first.missionId, 'new1');
      expect(loaded.map((e) => e.missionId), isNot(contains('m0')));
    });
  });

  group('Regressions: undo restores the quest chain', () {
    test('finishing then undoing brings the chain back', () async {
      final p = BoredomProvider();
      await p.startChain('qc_reset_arc');
      // Complete every step.
      while (p.currentChainStepIndex < p.currentChain!.steps.length - 1) {
        await p.completeCurrentChainStep();
      }
      await p.completeCurrentChainStep();

      expect(p.currentChain, isNull, reason: 'chain finished');
      expect(p.progress.questChainsCompleted, 1);

      expect(p.canUndo, isTrue);
      expect(await p.undoLastAction(), isTrue);

      expect(p.currentChain, isNotNull, reason: 'chain must come back');
      expect(p.progress.questChainsCompleted, 0);
    });
  });

  group('Regressions: mission completion publishes a new history list', () {
    test('history list identity changes after a completion', () async {
      final p = BoredomProvider();
      p.currentMission = MissionInstance(
        mission: MissionCatalog.all.first,
        missionNumber: 1,
      );
      final before = p.history;
      await p.completeMission();
      expectNewInstance(before, p.history, 'history');
      expect(p.history.length, 1);
    });
  });
}