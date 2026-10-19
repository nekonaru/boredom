import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boredom/models/mission.dart';
import 'package:boredom/models/user_progress.dart';
import 'package:boredom/providers/boredom_provider.dart';
import 'package:boredom/services/mission_catalog.dart';
import 'package:boredom/services/quest_chain_catalog.dart';
import 'package:boredom/services/storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    StorageService.instance.clearCache();
  });

  int levelOf(int xp) {
    var level = 1;
    while (UserProgress.xpNeededForLevel(level + 1) <= xp) {
      level++;
    }
    return level;
  }

  void armed(BoredomProvider p) {
    p.currentMission = MissionInstance(
      mission: MissionCatalog.all.first,
      missionNumber: 1,
    );
  }

  group('Skipping must not also hide the mission', () {
    test('a skipped mission can still be rolled again', () async {
      final p = BoredomProvider();
      final missionId = MissionCatalog.all.first.id;
      armed(p);
      await p.completeMission(MissionOutcome.skipped);

      // The roller treated the skip as a recent completion and excluded
      // that mission for seven days: honest answers were punished twice.
      expect(p.history.single.outcome, MissionOutcome.skipped);
      expect(
        p.recentMissionIds.contains(missionId),
        isFalse,
        reason: 'reporting a mission as not done must not ban it for a week',
      );
    });

    test('a done or partial mission is still excluded as before', () async {
      for (final outcome in [
        MissionOutcome.done,
        MissionOutcome.partial,
      ]) {
        final p = BoredomProvider();
        final missionId = MissionCatalog.all.first.id;
        armed(p);
        await p.completeMission(outcome);
        expect(p.recentMissionIds.contains(missionId), isTrue,
            reason: '$outcome should still count as recently done');
      }
    });
  });

  group('No phantom level-up bonus on a partial completion', () {
    test('the milestone is judged on what is actually paid', () {
      // Level 20 starts at 50 * 19 * 20 / 2 = 9500 XP.
      final threshold = UserProgress.xpNeededForLevel(20);
      // A 100 XP mission on a weekend is worth 200. Paid partially that is
      // 120, which lands short of the boundary while the full 200 would
      // have crossed it.
      final weekend = DateTime(2026, 6, 20, 12, 0);
      expect(BoredomProvider.isWeekend(weekend), isTrue);

      final awarded = (BoredomProvider.xpForDate(100, weekend) * 0.6).round();
      expect(awarded, 120);
      // Just inside the window where full XP would have crossed but the
      // partial payment does not.
      final totalXp = threshold - 180;
      expect(
        BoredomProvider.milestoneXpForAwarded(totalXp, awarded),
        0,
        reason: 'no boundary is actually crossed by the awarded amount',
      );
      // The same starting point with the full award does cross.
      expect(
        BoredomProvider.milestoneXpFor(totalXp, 100, weekend),
        BoredomProvider.milestoneBonus(20),
        reason: 'the full award genuinely crosses level 20',
      );
    });

    test('the awarded total never falls below the level it paid for', () {
      // For every starting point near a boundary, the resulting level
      // must match the level whose bonus was granted.
      for (final every in [10, 20, 50]) {
        final threshold = UserProgress.xpNeededForLevel(every);
        for (var delta = 0; delta < 40; delta++) {
          final start = threshold - delta;
          for (final base in [15, 30, 60, 100]) {
            for (final day in [
              DateTime(2026, 6, 17),
              DateTime(2026, 6, 20),
            ]) {
              final full = BoredomProvider.xpForDate(base, day);
              final paid = (full * 0.6).round();
              final bonus =
                  BoredomProvider.milestoneXpForAwarded(start, paid);
              final before = levelOf(start);
              final after = levelOf(start + paid + bonus);
              expect(
                after >= before,
                isTrue,
                reason: 'XP must never go backwards',
              );
              // Whatever bonus was granted, the level it names must be
              // reached, otherwise it was a phantom payment.
              for (var level = before + 1; level <= after; level++) {
                if (level % every == 0) {
                  final owed = BoredomProvider.milestoneBonus(level);
                  expect(bonus, greaterThanOrEqualTo(owed),
                      reason: 'level $every boundary underpaid at $start');
                }
              }
            }
          }
        }
      }
    });
  });

  group('Quest chain steps cannot be claimed twice', () {
    test('a double tap on the final step pays once', () async {
      final p = BoredomProvider();
      final chain = p.availableChains.first;
      await p.startChain(chain.id);
      for (var i = 0; i < chain.steps.length - 1; i++) {
        await p.completeCurrentChainStep();
      }

      // Two calls before the first one's storage writes land.
      final first = p.completeCurrentChainStep();
      final second = p.completeCurrentChainStep();
      await Future.wait([first, second]);

      // The step used to be marked done several awaits in, so the second
      // call slipped through: double XP and two history rows.
      expect(p.progress.questChainsCompleted, 1);
      expect(p.history.length, 1);
      expect(p.questChainProgress, isNull);
    });

    test('a double tap on a middle step advances once', () async {
      final p = BoredomProvider();
      final chain = p.availableChains.first;
      await p.startChain(chain.id);
      expect(p.currentChainStepIndex, 0);

      await Future.wait([
        p.completeCurrentChainStep(),
        p.completeCurrentChainStep(),
      ]);
      expect(p.currentChainStepIndex, 1,
          reason: 'two taps must not skip a step');
    });

    test('undo still works on a middle step', () async {
      final p = BoredomProvider();
      await p.startChain(p.availableChains.first.id);
      expect(await p.completeCurrentChainStep(), isEmpty);
      expect(p.currentChainStepIndex, 1);

      expect(await p.undoLastAction(), isTrue);
      expect(p.currentChainStepIndex, 0,
          reason: 'capturing the snapshot must happen before claiming');
    });
  });

  group('Stored daily challenge ids are validated', () {
    test('an id this build dropped is discarded', () async {
      final source = BoredomProvider();
      await source.init();
      final backup = (await source.exportBackup()).replaceFirst(
            RegExp(r'"challengeId":"dc_\d+"'),
            '"challengeId":"dc_removed_long_ago"',
          );

      final fresh = BoredomProvider();
      expect(await fresh.importBackup(backup), isTrue);
      expect(fresh.dailyChallengeState, isNull);
    });

    test('a valid id survives an import', () async {
      final source = BoredomProvider();
      await source.init();
      final fresh = BoredomProvider();
      expect(await fresh.importBackup(await source.exportBackup()), isTrue);
      expect(fresh.dailyChallengeState, isNotNull);
      expect(fresh.currentDailyChallenge, isNotNull);
    });
  });

  group('In-memory history matches the stored cap', () {
    test('appending past the cap trims memory too', () async {
      final p = BoredomProvider();
      // Fill past the cap through the normal path.
      for (var i = 0; i < StorageService.kMaxHistoryEntries + 5; i++) {
        await StorageService.instance.addHistoryEntry(
          CompletedMission(
            missionId: 'm$i',
            title: 'T$i',
            emoji: '🎯',
            categoryLabel: 'Test',
            xpEarned: 10,
            completedAt: DateTime(2026, 1, 1).add(Duration(minutes: i)),
          ),
        );
      }
      // Now append one more through the provider path.
      armed(p);
      await p.completeMission();

      // Memory used to grow past the cap while disk held only the cap, so
      // the History screen reported a total the device did not hold.
      expect(p.history.length, lessThanOrEqualTo(StorageService.kMaxHistoryEntries));
    });
  });

  group('Chain catalog lookups are strict', () {
    test('every shipped chain resolves', () {
      for (final c in QuestChainCatalog.all) {
        expect(QuestChainCatalog.byId(c.id), isNotNull);
      }
      expect(QuestChainCatalog.byId('nope'), isNull);
    });
  });
}
