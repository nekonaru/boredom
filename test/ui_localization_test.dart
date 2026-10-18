import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boredom/models/mission.dart';
import 'package:boredom/providers/boredom_provider.dart';
import 'package:boredom/services/storage_service.dart';
import 'package:boredom/widgets/weekly_chart.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    StorageService.instance.clearCache();
  });

  group('Mission localization helpers', () {
    final mission = Mission(
      id: 'test_01',
      title: 'Do a thing',
      description: 'Explain the thing',
      titleId: 'Lakukan Sebuah Hal',
      descriptionId: 'Jelaskan hal itu',
      emoji: '🎯',
      category: MissionCategory.gaming,
      difficulty: 1,
      baseXp: 10,
      maxTime: TimeBudget.fiveMin,
      moods: const {},
      locations: const {},
      energyLevels: const {},
    );

    test('Indonesian returns the translation', () {
      expect(mission.titleFor('id'), 'Lakukan Sebuah Hal');
      expect(mission.descriptionFor('id'), 'Jelaskan hal itu');
    });

    test('English returns the canonical text', () {
      expect(mission.titleFor('en'), 'Do a thing');
      expect(mission.descriptionFor('en'), 'Explain the thing');
    });

    test('a mission without a translation falls back to English', () {
      final plain = Mission(
        id: 'test_02',
        title: 'Plain',
        description: 'Plain description',
        emoji: '🎯',
        category: MissionCategory.gaming,
        difficulty: 1,
        baseXp: 10,
        maxTime: TimeBudget.fiveMin,
        moods: const {},
        locations: const {},
        energyLevels: const {},
      );
      expect(plain.titleFor('id'), 'Plain');
      expect(plain.descriptionFor('id'), 'Plain description');
    });
  });

  group('Stats covers every category it records', () {
    test('completing a custom mission lands in a visible category', () async {
      final p = BoredomProvider();
      await p.addCustomMission('Mine', 'Do my own thing', 40);
      await p.completeCustomMission(p.customMissions.single);

      expect(p.progress.categoryCounts['custom'], 1);

      // StatsScreen draws every category except chaos. Anything recorded in
      // categoryCounts but missing from that list makes the bars sum to less
      // than the "missions completed" total shown above them.
      final drawn = MissionCategory.values
          .where((c) => c != MissionCategory.chaos)
          .map((c) => c.name)
          .toSet();
      for (final key in p.progress.categoryCounts.keys) {
        expect(drawn.contains(key), isTrue,
            reason: 'category "$key" is counted but never displayed');
      }
    });

    test('every category actually recorded has a row', () async {
      final p = BoredomProvider();
      p.currentMission = MissionInstance(
        mission: const Mission(
          id: 'x_01',
          title: 'X',
          description: 'X',
          emoji: '🎯',
          category: MissionCategory.outdoor,
          difficulty: 1,
          baseXp: 10,
          maxTime: TimeBudget.fiveMin,
          moods: {},
          locations: {},
          energyLevels: {},
        ),
        missionNumber: 1,
      );
      await p.completeMission();
      await p.addCustomMission('Mine', 'Mine', 20);
      await p.completeCustomMission(p.customMissions.single);

      expect(p.progress.categoryCounts.keys,
          containsAll(<String>['outdoor', 'custom']));
    });
  });

  group('ActivityBarsPainter repaints when it must', () {
    List<int> makeCounts() => [0, 1, 2, 3, 0, 4, 5];

    ActivityBarsPainter painter(List<int> counts, Color active) =>
        ActivityBarsPainter(
          counts: counts,
          active: active,
          inactive: active.withValues(alpha: 0.45),
          empty: const Color(0x22000000),
        );

    test('identical data and colors do not repaint', () {
      // List == is identity, so two equal-valued but distinct lists are
      // NOT equal. The painter must compare contents, not instances.
      expect(
        painter(makeCounts(), Colors.red)
            .shouldRepaint(painter(makeCounts(), Colors.red)),
        isFalse,
      );
    });

    test('a changed count repaints', () {
      final before = makeCounts()..[3] = 9;
      final after = makeCounts();
      expect(
        painter(before, Colors.red).shouldRepaint(painter(after, Colors.red)),
        isTrue,
      );
    });

    test('a changed length repaints', () {
      expect(
        painter([1, 2], Colors.red)
            .shouldRepaint(painter([1, 2, 3], Colors.red)),
        isTrue,
      );
    });

    test('a theme or accent change repaints', () {
      // This is the case that was missed: switching accent or light/dark
      // left the bars painted in the old colors.
      expect(
        painter(makeCounts(), Colors.red)
            .shouldRepaint(painter(makeCounts(), Colors.blue)),
        isTrue,
      );
    });
  });
}
