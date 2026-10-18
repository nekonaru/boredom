import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boredom/models/mission.dart';
import 'package:boredom/models/user_progress.dart';
import 'package:boredom/providers/boredom_provider.dart';
import 'package:boredom/services/mission_catalog.dart';
import 'package:boredom/services/storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    StorageService.instance.clearCache();
  });

  MissionInstance armed(BoredomProvider p) {
    p.currentMission = MissionInstance(
      mission: MissionCatalog.all.first,
      missionNumber: 1,
    );
    return p.currentMission!;
  }

  group('Outcome values', () {
    test('a skipped mission is not activity and pays nothing', () {
      expect(MissionOutcome.skipped.xpShare, 0);
      expect(MissionOutcome.skipped.countsAsActivity, isFalse);
      expect(MissionOutcome.partial.xpShare, closeTo(0.6, 0.001));
      expect(MissionOutcome.partial.countsAsActivity, isTrue);
      expect(MissionOutcome.done.xpShare, 1);
      expect(MissionOutcome.done.countsAsActivity, isTrue);
    });

    test('parsing tolerates junk without throwing', () {
      expect(MissionOutcome.parse('done'), MissionOutcome.done);
      expect(MissionOutcome.parse('partial'), MissionOutcome.partial);
      expect(MissionOutcome.parse('nonsense'), isNull);
      expect(MissionOutcome.parse(null), isNull);
    });
  });

  group('Skipping does not buy you a streak', () {
    test('no XP, no streak, no completion count', () async {
      final p = BoredomProvider();
      armed(p);
      final mission = p.currentMission!.mission;

      await p.completeMission(MissionOutcome.skipped);

      expect(p.progress.totalXp, 0);
      expect(p.progress.streakDays, 0);
      expect(p.progress.totalMissionsCompleted, 0);
      expect(p.progress.categoryCounts[mission.category.name], isNull);
      expect(p.progress.lastCompletedDate, isNull);
      // The attempt is still visible, which is the point of recording it.
      expect(p.history.length, 1);
      expect(p.history.single.outcome, MissionOutcome.skipped);
    });

    test('it cannot revive a streak either', () async {
      final p = BoredomProvider();
      armed(p);
      await p.completeMission(MissionOutcome.done);
      expect(p.progress.streakDays, 1);

      armed(p);
      await p.completeMission(MissionOutcome.skipped);

      // The streak must survive untouched rather than reset or advance.
      expect(p.progress.streakDays, 1);
      expect(p.progress.totalMissionsCompleted, 1);
      expect(p.history.length, 2);
    });
  });

  group('Partial credit', () {
    test('pays roughly 60 percent and still counts the day', () async {
      final p = BoredomProvider();
      armed(p);
      await p.completeMission(MissionOutcome.partial);
      expect(p.progress.totalXp, greaterThan(0));
      expect(p.progress.streakDays, 1);
      expect(p.progress.totalMissionsCompleted, 1);
      expect(p.history.single.outcome, MissionOutcome.partial);
    });
  });

  group('Statistics exclude skipped attempts', () {
    test('a skipped row does not inflate any missions-completed figure',
        () async {
      final p = BoredomProvider();
      armed(p);
      await p.completeMission(MissionOutcome.done);
      armed(p);
      await p.completeMission(MissionOutcome.skipped);
      armed(p);
      await p.completeMission(MissionOutcome.done);

      expect(p.history.length, 3, reason: 'all three attempts are recorded');
      expect(p.progress.totalMissionsCompleted, 2);
      expect(p.last7DaysCounts[6], 2);
      expect(p.last7DaysSummary.missions, 2);
      expect(p.busiestWeekday, isNotNull);
      // Two real days of XP, not three.
      expect(p.avgXpPerActiveDay, greaterThan(0));
    });

    test('follow-through reflects the honest answers', () async {
      final p = BoredomProvider();
      armed(p);
      await p.completeMission(MissionOutcome.done);
      armed(p);
      await p.completeMission(MissionOutcome.partial);
      armed(p);
      await p.completeMission(MissionOutcome.skipped);

      expect(p.trackedCompletions, 3);
      expect(p.partialCount, 1);
      expect(p.skippedCount, 1);
      expect(p.followThroughRate, closeTo(1 / 3, 0.001));
    });

    test('follow-through is null, not zero, before anything is tracked',
        () async {
      final p = BoredomProvider();
      expect(p.trackedCompletions, 0);
      expect(p.followThroughRate, isNull,
          reason: 'no data must not look like a genuine 0 percent');
    });
  });

  group('Undo', () {
    test('rolls a skipped attempt back too', () async {
      final p = BoredomProvider();
      armed(p);
      await p.completeMission(MissionOutcome.skipped);
      expect(p.history.length, 1);

      expect(await p.undoLastAction(), isTrue);
      expect(p.history, isEmpty);
      expect(p.progress.totalMissionsCompleted, 0);
    });

    test('rolls a partial completion back', () async {
      final p = BoredomProvider();
      armed(p);
      await p.completeMission(MissionOutcome.partial);
      final xp = p.progress.totalXp;
      expect(await p.undoLastAction(), isTrue);
      expect(p.progress.totalXp, 0);
      expect(xp, greaterThan(0));
    });
  });

  group('Persistence', () {
    test('the outcome survives a reload', () async {
      final p = BoredomProvider();
      armed(p);
      await p.completeMission(MissionOutcome.partial);

      final reloaded = BoredomProvider();
      await reloaded.init();
      expect(reloaded.history.single.outcome, MissionOutcome.partial);
    });

    test('rows without an outcome load as null, not as success', () async {
      // Simulates a history row written by a version that predates
      // outcome tracking.
      final legacy = const CompletedMission(
        missionId: 'home_01',
        title: 'Old row',
        emoji: '🎯',
        categoryLabel: 'Gaming',
        xpEarned: 25,
        completedAt: DateTime(2024, 1, 1),
      );
      final parsed = CompletedMission.fromJson(legacy.toJson());
      expect(parsed.outcome, isNull);

      // Legacy rows must still count as activity, exactly as before.
      final p = BoredomProvider();
      p.history = [legacy];
      expect(p.last7DaysCounts[6], 1,
          reason: 'a day with only a legacy row still counts');
      expect(p.avgXpPerActiveDay, 25);
    });

    test('an outcome survives a backup round trip', () async {
      final p = BoredomProvider();
      armed(p);
      await p.completeMission(MissionOutcome.partial);

      final fresh = BoredomProvider();
      expect(await fresh.importBackup(await p.exportBackup()), isTrue);
      expect(fresh.history.single.outcome, MissionOutcome.partial);
    });
  });

  group('Custom missions follow the same rules', () {
    test('a skipped custom mission pays nothing', () async {
      final p = BoredomProvider();
      await p.addCustomMission('Mine', 'Do my thing', 60);
      await p.completeCustomMission(
        p.customMissions.single,
        MissionOutcome.skipped,
      );
      expect(p.progress.totalXp, 0);
      expect(p.progress.streakDays, 0);
      expect(p.history.single.outcome, MissionOutcome.skipped);
    });

    test('a partial custom mission pays about 60 percent', () async {
      final p = BoredomProvider();
      await p.addCustomMission('Mine', 'Do my thing', 60);
      await p.completeCustomMission(
        p.customMissions.single,
        MissionOutcome.partial,
      );
      expect(p.progress.totalXp, greaterThan(0));
      expect(p.progress.totalXp, lessThan(60));
      expect(p.progress.streakDays, 1);
    });
  });
}
