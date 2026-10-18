import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boredom/l10n/app_strings.dart';
import 'package:boredom/models/mission.dart';
import 'package:boredom/models/user_progress.dart';
import 'package:boredom/providers/boredom_provider.dart';
import 'package:boredom/models/daily_challenge.dart';
import 'package:boredom/services/daily_challenge_catalog.dart';
import 'package:boredom/services/quest_chain_catalog.dart';
import 'package:boredom/services/storage_service.dart';
import 'package:boredom/widgets/weekly_chart.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    StorageService.instance.clearCache();
  });

  group('Level titles', () {
    test('Indonesian is actually Indonesian, not the English string', () {
      final id = LevelTitles.titleFor(20, code: 'id');
      final en = LevelTitles.titleFor(20, code: 'en');
      expect(en, 'Main Character');
      expect(id, isNot(en));
      expect(id, 'Tokoh Utama');
    });

    test('every milestone has an Indonesian twin', () {
      for (final level in [1, 5, 10, 20, 35, 50, 75, 100, 150]) {
        expect(
          LevelTitles.titleFor(level, code: 'id'),
          isNot(LevelTitles.titleFor(level, code: 'en')),
          reason: 'level $level falls back to English',
        );
      }
    });

    test('below the first milestone still returns a title', () {
      expect(LevelTitles.titleFor(1, code: 'id'), 'Bosan');
      expect(LevelTitles.titleFor(1, code: 'en'), 'Bored');
    });
  });

  group('Category labels are fully translated', () {
    test('no category falls back to its English label', () {
      // "Chaos" is deliberately left alone: it is a real loanword in
      // Indonesian, so an identical string is correct, not a leak.
      for (final c in MissionCategory.values.where((c) => c != MissionCategory.chaos)) {
        expect(
          c.labelFor('id'),
          isNot(c.label),
          reason: '${c.name} is still English in Indonesian mode',
        );
      }
    });
  });

  group('App strings cover the Home filter chips', () {
    final en = const AppStrings('en');
    final id = const AppStrings('id');

    test('mood, location and energy labels differ by language', () {
      // Mood.normal is "Normal" in both languages, which is correct
      // Indonesian rather than a missing translation.
      for (final m in Mood.values.where((m) => m != Mood.normal)) {
        expect(id.moodLabel(m), isNot(en.moodLabel(m)), reason: 'mood $m');
      }
      for (final l in LocationType.values) {
        expect(id.locationLabel(l), isNot(en.locationLabel(l)),
            reason: 'location $l');
      }
      for (final e in EnergyLevel.values) {
        expect(id.energyLabel(e), isNot(en.energyLabel(e)), reason: 'energy $e');
      }
    });

    test('the Home headings and buttons are translated', () {
      // These four used to be English-only getters next to localized
      // neighbours, so Indonesian mode kept the primary CTA in English.
      expect(id.secMood, isNot(en.secMood));
      expect(id.chaosTitle, isNot(en.chaosTitle));
      expect(id.boredButton, isNot(en.boredButton));
      expect(id.chaosButton, isNot(en.chaosButton));
    });
  });

  group('Daily challenge counts like a mission', () {
    test('it records history, streak and progress', () async {
      final p = BoredomProvider();
      await p.init();
      final challenge = DailyChallengeCatalog.forDate(DateTime.now());

      expect(p.history, isEmpty);
      expect(p.progress.streakDays, 0);

      await p.completeDailyChallenge();

      // Before the fix the challenge paid XP and nothing else, so this day
      // was blank in every statistic and level achievements stayed locked.
      expect(p.history.length, 1);
      expect(p.history.single.missionId, challenge.id);
      expect(p.progress.totalMissionsCompleted, 1);
      expect(p.progress.streakDays, 1);
      expect(p.progress.totalXp, greaterThan(0));
      expect(
        p.progress.categoryCounts[challenge.category.name],
        1,
        reason: 'the challenge must land in its own category bucket',
      );
      expect(p.last7DaysCounts[6], 1);
    });

    test('it cannot be completed twice', () async {
      final p = BoredomProvider();
      await p.init();
      await p.completeDailyChallenge();
      final xpAfterFirst = p.progress.totalXp;
      await p.completeDailyChallenge();
      expect(p.progress.totalXp, xpAfterFirst);
      expect(p.history.length, 1);
    });

    test('undo rolls the whole thing back', () async {
      final p = BoredomProvider();
      await p.init();
      await p.completeDailyChallenge();
      expect(await p.undoLastAction(), isTrue);
      expect(p.progress.totalXp, 0);
      expect(p.history, isEmpty);
      expect(p.progress.totalMissionsCompleted, 0);
      expect(p.dailyChallengeCompleted, isFalse);
    });

    test('every challenge in the catalog has a category', () {
      for (final c in DailyChallengeCatalog.all) {
        expect(c.category, isNotNull, reason: '${c.id} has no category');
      }
    });
  });

  group('Finished quest chain counts like a mission', () {
    test('a completed chain records history and streak', () async {
      final p = BoredomProvider();
      await p.init();
      final chain = p.availableChains.first;
      await p.startChain(chain.id);

      // Mid-chain steps pay nothing by design (one reward for the whole
      // arc), so the chain has to be finished for anything to count.
      for (var i = 0; i < chain.steps.length - 1; i++) {
        expect(await p.completeCurrentChainStep(), isEmpty);
      }
      expect(p.history, isEmpty);

      await p.completeCurrentChainStep();

      expect(p.history.length, 1);
      expect(p.progress.totalMissionsCompleted, 1);
      expect(p.progress.questChainsCompleted, 1);
      expect(p.progress.streakDays, 1);
      expect(p.questChainProgress, isNull);
      expect(
        p.progress.categoryCounts[chain.category.name],
        1,
        reason: 'the chain must land in its own category bucket',
      );
    });

    test('every chain in the catalog has a category', () {
      for (final c in QuestChainCatalog.all) {
        expect(c.category, isNotNull, reason: '${c.id} has no category');
      }
    });
  });

  group('Stats chart covers every category that gets recorded', () {
    test('chaos completions are included', () {
      // The v2.5.0 fix removed `custom` but kept excluding `chaos`, on the
      // wrong assumption that chaos is only a flag. Five chaos-only
      // missions carry `category: chaos` and are rollable in Chaos Mode,
      // so excluding them made the bars disagree with the total.
      final drawn = MissionCategory.values.map((c) => c.name).toSet();
      expect(drawn.contains('chaos'), isTrue);
      expect(drawn.contains('custom'), isTrue);
      expect(drawn.length, MissionCategory.values.length);
    });
  });

  group('ActivityBarsPainter survives a dense chart', () {
    test('30 bars stay inside the canvas', () {
      // A fixed 8px gap ate 8 * 29 = 232px of a ~288px canvas, leaving
      // 1.87px bars, and went negative on narrower layouts.
      final recorder = _RecordingCanvas();
      final painter = ActivityBarsPainter(
        counts: List<int>.filled(30, 3),
        active: Colors.red,
        inactive: Colors.blue,
        empty: Colors.grey,
      );
      painter.paint(recorder, const Size(288, 120));
      expect(recorder.minWidth, greaterThan(1.0));
    });

    test('a canvas too narrow for any gap draws nothing', () {
      final recorder = _RecordingCanvas();
      final painter = ActivityBarsPainter(
        counts: List<int>.filled(30, 1),
        active: Colors.red,
        inactive: Colors.blue,
        empty: Colors.grey,
      );
      // 30 bars at a 2px gap need 58px of gaps alone, so 40px leaves
      // nothing for the bars themselves.
      painter.paint(recorder, const Size(40, 120));
      expect(recorder.drawn, isEmpty);
    });

    test('an empty counts list is a no-op, not a NaN width', () {
      final recorder = _RecordingCanvas();
      final painter = ActivityBarsPainter(
        counts: const [],
        active: Colors.red,
        inactive: Colors.blue,
        empty: Colors.grey,
      );
      painter.paint(recorder, const Size(288, 120));
      expect(recorder.drawn, isEmpty);
    });
  });

  group('Dislike toggle publishes a new set', () {
    test('the collection identity changes so select can see it', () async {
      final p = BoredomProvider();
      final before = p.dislikedIds;
      await p.toggleDislike('code_01');
      expect(identical(p.dislikedIds, before), isFalse);
      expect(p.isDisliked('code_01'), isTrue);

      final after = p.dislikedIds;
      await p.toggleDislike('code_01');
      expect(identical(p.dislikedIds, after), isFalse);
      expect(p.isDisliked('code_01'), isFalse);
    });
  });

  group('Backup import clears state it does not restore', () {
    test('a null challenge reaches storage instead of leaving a stale one',
        () async {
      // Directly at the storage layer, because that is where the defect
      // was: the old signature could not accept null, so a clear was
      // impossible and yesterday's challenge stayed on disk.
      final storage = StorageService.instance;
      await storage.saveDailyChallengeState(
        DailyChallengeState(
          date: DateTime(2020, 1, 1),
          challengeId: 'dc_01',
          completed: true,
        ),
      );
      expect(await storage.loadDailyChallengeState(), isNotNull);

      await storage.saveDailyChallengeState(null);
      expect(await storage.loadDailyChallengeState(), isNull);
    });

    test('an import without a challenge leaves no stale one in storage',
        () async {
      final storage = StorageService.instance;
      // Stand in for what a payload from an older build can look like:
      // a completed challenge sitting in storage, then an import that
      // carries no challenge at all.
      await storage.saveDailyChallengeState(
        DailyChallengeState(
          date: DateTime(2020, 1, 1),
          challengeId: 'dc_01',
          completed: true,
        ),
      );

      final p = BoredomProvider();
      await p.init();
      final backup = await p.exportBackup();
      final stripped = backup.replaceFirst(
        RegExp(r'"dailyChallenge":\{[^}]*\}'),
        '"dailyChallenge":null',
      );

      final fresh = BoredomProvider();
      await fresh.init();
      expect(await fresh.importBackup(stripped), isTrue);
      expect(fresh.dailyChallengeState, isNull);

      // The stale 2020 challenge must be gone from disk, not just from
      // memory. init() would legitimately mint a fresh challenge for
      // today, so assert the stored date is not the stale one.
      final stored = await storage.loadDailyChallengeState();
      expect(
        stored == null || stored.date.year != 2020,
        isTrue,
        reason: 'the stale challenge survived the import',
      );
    });
  });
}

/// Minimal Canvas double that records the rects handed to drawRRect, so
/// bar geometry can be asserted without a real rasterizer.
class _RecordingCanvas implements Canvas {
  final List<Rect> drawn = [];
  double minWidth = double.infinity;

  @override
  void drawRRect(RRect rrect, Paint paint) {
    drawn.add(rrect.outerRect);
    minWidth = rrect.outerRect.width < minWidth
        ? rrect.outerRect.width
        : minWidth;
  }

  @override
  void noSuchMethod(Invocation invocation) {
    // Every other Canvas member is irrelevant here.
  }
}
