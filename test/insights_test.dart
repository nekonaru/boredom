import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boredom/models/mission.dart';
import 'package:boredom/models/user_progress.dart';
import 'package:boredom/providers/boredom_provider.dart';
import 'package:boredom/services/insights.dart';
import 'package:boredom/services/quest_chain_catalog.dart';
import 'package:boredom/services/storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    StorageService.instance.clearCache();
  });

  final now = DateTime(2026, 6, 15, 12, 0);

  CompletedMission at(
    DateTime when, {
    String id = 'home_01',
    MissionOutcome? outcome = MissionOutcome.done,
    int xp = 30,
  }) =>
      CompletedMission(
        missionId: id,
        title: 'T',
        emoji: '🎯',
        categoryLabel: 'Gaming',
        xpEarned: xp,
        completedAt: when,
        outcome: outcome,
      );

  group('Best hour needs real evidence', () {
    test('is null below five completions', () {
      final rows = List.generate(4, (i) => at(now.add(Duration(hours: i))));
      expect(Insights.bestHour(rows), isNull);
    });

    test('is null when the completions are spread flat', () {
      // One per hour across 12 different hours: the peak is 1/12 of the
      // data, well under the 25 percent threshold.
      final rows = List.generate(12, (i) => at(now.add(Duration(hours: i))));
      expect(Insights.bestHour(rows), isNull);
    });

    test('finds a genuine peak', () {
      final rows = [
        ...List.generate(6, (i) => at(DateTime(2026, 6, 14, 21, i))),
        ...List.generate(2, (i) => at(DateTime(2026, 6, 14, 9, i))),
      ];
      expect(Insights.bestHour(rows), 21);
    });
  });

  group('Week over week', () {
    test('is null with no previous week to compare against', () {
      final rows = [at(DateTime(2026, 6, 15, 10))];
      expect(Insights.inLastWeek(rows, now), 1);
      expect(Insights.inPreviousWeek(rows, now), 0);
      // An invented +100 percent would be dishonest.
      expect(Insights.weekOverWeekChange(rows, now), isNull);
    });

    test('measures growth against the previous 7 days', () {
      // Current window is 09 Jun to 15 Jun, previous is 02 Jun to 08 Jun.
      final rows = [
        ...List.generate(4, (i) => at(DateTime(2026, 6, 15, 10, i))),
        ...List.generate(2, (i) => at(DateTime(2026, 6, 5, 10, i))),
      ];
      expect(Insights.inLastWeek(rows, now), 4);
      expect(Insights.inPreviousWeek(rows, now), 2);
      expect(Insights.weekOverWeekChange(rows, now), 100);
    });

    test('measures a decline too', () {
      final rows = [
        ...List.generate(1, (i) => at(DateTime(2026, 6, 15, 10, i))),
        ...List.generate(4, (i) => at(DateTime(2026, 6, 5, 10, i))),
      ];
      expect(Insights.inLastWeek(rows, now), 1);
      expect(Insights.inPreviousWeek(rows, now), 4);
      expect(Insights.weekOverWeekChange(rows, now), -75);
    });

    test('excludes skipped attempts from both weeks', () {
      final rows = [
        at(DateTime(2026, 6, 15, 10)),
        at(DateTime(2026, 6, 15, 11),
            outcome: MissionOutcome.skipped),
        at(DateTime(2026, 6, 5, 10)),
      ];
      expect(Insights.inLastWeek(rows, now), 1);
      expect(Insights.inPreviousWeek(rows, now), 1);
    });

    test('a future-dated row is not counted as this week', () {
      // The rest of the statistics already reject these, so the insights
      // must not quietly accept one either.
      final rows = [
        at(DateTime(2026, 6, 15, 10)),
        at(DateTime(2026, 6, 20, 10)),
      ];
      expect(Insights.inLastWeek(rows, now), 1);
      expect(Insights.avgXpLastWeek(rows, now), 30);
    });
  });

  group('Most skipped category', () {
    test('is null when nothing was skipped', () {
      final rows = List.generate(6, (i) => at(DateTime(2026, 6, 14, 10, i)));
      expect(Insights.mostSkippedCategory(rows), isNull);
    });

    test('is null for a single isolated skip', () {
      // One skip out of everything is not a pattern worth naming.
      final rows = [
        ...List.generate(6, (i) => at(DateTime(2026, 6, 14, 10, i))),
        at(DateTime(2026, 6, 14, 11), outcome: MissionOutcome.skipped),
      ];
      expect(Insights.mostSkippedCategory(rows), isNull);
    });

    test('names the category once it repeats', () {
      final rows = [
        ...List.generate(6, (i) => at(DateTime(2026, 6, 14, 10, i))),
        at(DateTime(2026, 6, 14, 11), outcome: MissionOutcome.skipped),
        at(DateTime(2026, 6, 13, 11), outcome: MissionOutcome.skipped),
      ];
      // home_01 resolves to a real catalog category.
      expect(Insights.mostSkippedCategory(rows), isNotNull);
    });

    test('ignores rows that are not catalog missions', () {
      final rows = [
        at(DateTime(2026, 6, 14, 11),
            id: 'custom_123', outcome: MissionOutcome.skipped),
        at(DateTime(2026, 6, 13, 11),
            id: 'chain_qc_touch_grass', outcome: MissionOutcome.skipped),
      ];
      // Neither custom missions nor finished chains map to a category.
      expect(Insights.mostSkippedCategory(rows), isNull);
    });

    test('a repeated daily-challenge skip is attributed to its category',
        () {
      final rows = [
        at(DateTime(2026, 6, 14, 11),
            id: 'dc_01', outcome: MissionOutcome.skipped),
        at(DateTime(2026, 6, 13, 11),
            id: 'dc_01', outcome: MissionOutcome.skipped),
      ];
      expect(
        Insights.mostSkippedCategory(rows),
        MissionCategory.selfImprovement,
      );
    });
  });

  group('Insight cards', () {
    test('are empty for a brand new player', () {
      expect(Insights.build(const [], now), isEmpty);
    });

    test('never exceed the requested maximum', () {
      final rows = [
        ...List.generate(10, (i) => at(DateTime(2026, 6, 15, 21, i))),
        ...List.generate(6, (i) => at(DateTime(2026, 6, 9, 3, i))),
        ...List.generate(3, (i) => at(DateTime(2026, 6, 12, 5, i),
            outcome: MissionOutcome.skipped)),
      ];
      final built = Insights.build(rows, now, max: 2);
      expect(built.length, lessThanOrEqualTo(2));
      expect(built, isNotEmpty);
    });

    test('carry both an English and an Indonesian string', () {
      final rows = List.generate(8, (i) => at(DateTime(2026, 6, 15, 21, i)));
      final built = Insights.build(rows, now);
      expect(built, isNotEmpty);
      for (final i in built) {
        expect(i.title('en'), isNotEmpty);
        expect(i.title('id'), isNotEmpty);
        expect(i.detail('id'), isNotEmpty);
      }
    });
  });

  group('Quest chain lookup no longer lies', () {
    test('an unknown id returns null instead of the first chain', () {
      expect(QuestChainCatalog.byId('removed_chain'), isNull);
      expect(QuestChainCatalog.byId(QuestChainCatalog.all.first.id),
          isNotNull);
    });

    test('a stored chain id this build dropped is discarded on import',
        () async {
      final source = BoredomProvider();
      await source.startChain(QuestChainCatalog.all.first.id);
      final backup = (await source.exportBackup()).replaceFirst(
            '"chainId":"${QuestChainCatalog.all.first.id}"',
            '"chainId":"chain_removed_long_ago"',
          );

      final fresh = BoredomProvider();
      expect(await fresh.importBackup(backup), isTrue);
      expect(fresh.questChainProgress, isNull);
      expect(fresh.currentChain, isNull);
    });

    test('completing a step of a vanished chain drops it safely', () async {
      final p = BoredomProvider();
      await p.startChain('chain_removed_long_ago');
      expect(p.questChainProgress, isNotNull);

      expect(await p.completeCurrentChainStep(), isEmpty);
      expect(p.questChainProgress, isNull);
      expect(p.progress.totalXp, 0);
    });
  });
}
