import 'package:flutter_test/flutter_test.dart';
import 'package:boredom/models/user_progress.dart';
import 'package:boredom/services/history_filter.dart';

void main() {
  final now = DateTime(2026, 6, 15, 12, 0);

  CompletedMission at(
    DateTime when, {
    String title = 'Touch Grass',
    String category = 'Outdoor',
    MissionOutcome? outcome = MissionOutcome.done,
  }) =>
      CompletedMission(
        missionId: 'm',
        title: title,
        emoji: '🎯',
        categoryLabel: category,
        xpEarned: 20,
        completedAt: when,
        outcome: outcome,
      );

  bool inRange(CompletedMission e, HistoryRange r) =>
      HistoryFilters.matchesRange(e, r, now: now);

  group('Date windows', () {
    test('today means today, whatever the time of day', () {
      expect(inRange(at(DateTime(2026, 6, 15, 0, 1)), HistoryRange.today),
          isTrue);
      expect(inRange(at(DateTime(2026, 6, 15, 23, 59)), HistoryRange.today),
          isTrue);
      expect(inRange(at(DateTime(2026, 6, 14, 23, 59)), HistoryRange.today),
          isFalse);
    });

    test('the week window is seven calendar days, not 168 hours', () {
      // 23:59 six days back is 144 hours back but still inside the
      // window; a rolling-hours implementation would have dropped it.
      expect(inRange(at(DateTime(2026, 6, 9, 23, 59)), HistoryRange.week),
          isTrue);
      expect(inRange(at(DateTime(2026, 6, 8, 23, 59)), HistoryRange.week),
          isFalse);
    });

    test('the month window is thirty calendar days', () {
      expect(inRange(at(DateTime(2026, 5, 17)), HistoryRange.month), isTrue);
      expect(inRange(at(DateTime(2026, 5, 16)), HistoryRange.month), isFalse);
    });

    test('all time includes everything', () {
      expect(inRange(at(DateTime(2019, 1, 1)), HistoryRange.all), isTrue);
    });

    test('a future-dated row is never in any window', () {
      // A clock change can leave a stamp in the future. It must not show
      // up as "today", which would quietly rewrite the user's record.
      final future = at(DateTime(2026, 6, 20, 10));
      for (final r in HistoryRange.values) {
        expect(inRange(future, r), isFalse, reason: '$r should reject it');
      }
    });
  });

  group('Outcome filters', () {
    test('each outcome matches only itself', () {
      final done = at(now);
      final partial = at(now, outcome: MissionOutcome.partial);
      final skipped = at(now, outcome: MissionOutcome.skipped);
      final legacy = at(now, outcome: null);

      expect(HistoryFilters.matchesOutcome(done, HistoryFilter.done), isTrue);
      expect(HistoryFilters.matchesOutcome(partial, HistoryFilter.done),
          isFalse);
      expect(
          HistoryFilters.matchesOutcome(legacy, HistoryFilter.done), isFalse);

      expect(HistoryFilters.matchesOutcome(partial, HistoryFilter.partial),
          isTrue);
      expect(HistoryFilters.matchesOutcome(skipped, HistoryFilter.skipped),
          isTrue);
    });

    test('legacy rows land in untracked and nowhere else', () {
      final legacy = at(now, outcome: null);
      expect(HistoryFilters.matchesOutcome(legacy, HistoryFilter.untracked),
          isTrue);
      expect(HistoryFilters.matchesOutcome(legacy, HistoryFilter.done),
          isFalse);
      expect(HistoryFilters.matchesOutcome(legacy, HistoryFilter.skipped),
          isFalse);
    });

    test('all includes legacy rows too', () {
      expect(
        HistoryFilters.matchesOutcome(at(now, outcome: null),
            HistoryFilter.all),
        isTrue,
      );
    });
  });

  group('Combined filtering', () {
    final rows = [
      at(DateTime(2026, 6, 15, 10), title: 'Coding', category: 'Ngoding'),
      at(DateTime(2026, 6, 15, 11),
          title: 'Gaming', category: 'Gim', outcome: MissionOutcome.skipped),
      at(DateTime(2026, 6, 3, 10), title: 'Coding', category: 'Ngoding'),
      at(DateTime(2026, 6, 2, 10), title: 'Old', category: 'Lama'),
    ];

    List<CompletedMission> run({
      String query = '',
      HistoryRange range = HistoryRange.all,
      HistoryFilter outcome = HistoryFilter.all,
    }) =>
        HistoryFilters.apply(
          rows,
          query: query,
          range: range,
          outcome: outcome,
          now: now,
          titleOf: (e) => e.title,
          categoryOf: (e) => e.categoryLabel,
        );

    test('search matches the text the row renders', () {
      expect(run(query: 'coding').length, 2);
      expect(run(query: 'ngoding').length, 2);
      expect(run(query: 'nothing here'), isEmpty);
    });

    test('search is case insensitive and trims', () {
      expect(run(query: '  CODING  ').length, 2);
    });

    test('date and outcome filters compose', () {
      final result = run(
        range: HistoryRange.week,
        outcome: HistoryFilter.done,
      );
      expect(result.length, 1);
      expect(result.first.title, 'Coding');
    });

    test('a skipped row is excluded by the activity filters', () {
      final result = run(range: HistoryRange.today);
      expect(result.length, 1);
      expect(result.first.title, 'Coding');
    });

    test('isUnfiltered drives the right empty-state copy', () {
      expect(
        HistoryFilters.isUnfiltered(
          query: '',
          range: HistoryRange.all,
          outcome: HistoryFilter.all,
        ),
        isTrue,
      );
      // A whitespace-only query is still unfiltered.
      expect(
        HistoryFilters.isUnfiltered(
          query: '   ',
          range: HistoryRange.all,
          outcome: HistoryFilter.all,
        ),
        isTrue,
      );
      expect(
        HistoryFilters.isUnfiltered(
          query: '',
          range: HistoryRange.today,
          outcome: HistoryFilter.all,
        ),
        isFalse,
      );
      expect(
        HistoryFilters.isUnfiltered(
          query: '',
          range: HistoryRange.all,
          outcome: HistoryFilter.done,
        ),
        isFalse,
      );
    });

    test('every filter value is reachable and none throw', () {
      for (final r in HistoryRange.values) {
        for (final o in HistoryFilter.values) {
          expect(() => run(range: r, outcome: o), returnsNormally);
        }
      }
    });
  });
}
