import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boredom/models/mission.dart';
import 'package:boredom/providers/boredom_provider.dart';
import 'package:boredom/services/mission_catalog.dart';
import 'package:boredom/services/storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    StorageService.instance.clearCache();
  });

  group('Undo keeps the inbox counter in step with the inbox list', () {
    test('saving after a completion then undoing restores both together',
        () async {
      final p = BoredomProvider();
      p.currentMission = MissionInstance(
        mission: MissionCatalog.all.first,
        missionNumber: 1,
      );
      await p.completeMission();
      expect(p.progress.missionsSaved, 0);

      // Two saves happen AFTER the undo snapshot was taken.
      await p.saveForLater('home_01');
      await p.saveForLater('home_02');
      expect(p.progress.missionsSaved, 2);
      expect(p.savedMissions.length, 2);

      expect(await p.undoLastAction(), isTrue);

      // The inbox and its counter must agree. Before the fix the list still
      // held two entries while the counter was rolled back to 0, which made
      // `missionsSaved` drift further every time an entry was removed.
      expect(p.savedMissions.length, p.progress.missionsSaved);
      expect(p.savedMissions, isEmpty);
      expect(p.progress.missionsSaved, 0);
    });

    test('removing an entry after undo can no longer drive it negative',
        () async {
      final p = BoredomProvider();
      await p.saveForLater('home_01');
      p.currentMission = MissionInstance(
        mission: MissionCatalog.all.first,
        missionNumber: 1,
      );
      await p.completeMission();
      await p.undoLastAction();

      expect(p.progress.missionsSaved, 1);
      expect(p.savedMissions.length, 1);

      await p.removeSavedMission('home_01');
      expect(p.progress.missionsSaved, 0);
      expect(p.progress.missionsSaved, greaterThanOrEqualTo(0));
    });
  });

  group('Saving to the inbox reports its achievements', () {
    test('the unlock is published, not swallowed', () async {
      final p = BoredomProvider();
      // Drive the counter to one below the first save threshold.
      for (var i = 0; i < 9; i++) {
        await p.saveForLater('home_0$i');
      }
      expect(p.lastUnlockedAchievements, isEmpty);

      await p.saveForLater('home_99');
      expect(p.lastUnlockedAchievements, isNotEmpty,
          reason: 'the 10th save unlocks an achievement and must say so');
    });
  });

  group('Startup app-open counter', () {
    test('a retried load counts one open, not several', () async {
      final p = BoredomProvider();
      await p.init();
      expect(p.progress.appOpensToday, 1);

      // Simulates tapping "Try again" on the startup error screen.
      await p.retryLoad();
      expect(p.progress.appOpensToday, 1,
          reason: 'one real app open must never be counted twice');

      await p.retryLoad();
      expect(p.progress.appOpensToday, 1);
    });
  });

  group('Undo leaves storage and memory agreeing on the chain', () {
    test('a fresh provider reads back the chain undo left behind', () async {
      final p = BoredomProvider();
      await p.startChain(p.availableChains.first.id);
      expect(p.questChainProgress, isNotNull);

      p.currentMission = MissionInstance(
        mission: MissionCatalog.all.first,
        missionNumber: 1,
      );
      await p.completeMission();
      expect(await p.undoLastAction(), isTrue);

      // Storage used to be skipped when the restored chain was null, which
      // could leave a chain on disk that the app had already forgotten.
      final fresh = BoredomProvider();
      await fresh.init();
      expect(fresh.questChainProgress?.chainId, p.questChainProgress?.chainId);
      expect(fresh.currentChainStepIndex, p.currentChainStepIndex);
    });
  });
}
