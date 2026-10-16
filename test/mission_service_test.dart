import 'package:flutter_test/flutter_test.dart';
import 'package:boredom/models/mission.dart';
import 'package:boredom/services/mission_catalog.dart';
import 'package:boredom/services/mission_service.dart';

MissionFilter _filter({
  Mood mood = Mood.normal,
  TimeBudget time = TimeBudget.thirtyMin,
  LocationType location = LocationType.anywhere,
  EnergyLevel energy = EnergyLevel.medium,
}) =>
    MissionFilter(
      mood: mood,
      timeBudget: time,
      location: location,
      energy: energy,
    );

void main() {
  group('MissionService.generate', () {
    test('always returns a mission, even for the strictest combo', () {
      for (final mood in Mood.values) {
        for (final energy in EnergyLevel.values) {
          final mission = MissionService.generate(
            _filter(mood: mood, energy: energy),
          );
          expect(MissionCatalog.all.contains(mission), isTrue);
        }
      }
    });

    test('chaos mode can return chaos-only missions', () {
      var sawChaos = false;
      for (var i = 0; i < 200; i++) {
        final mission = MissionService.generate(_filter(), chaosMode: true);
        if (mission.chaosOnly) {
          sawChaos = true;
          break;
        }
      }
      expect(sawChaos, isTrue);
    });

    test('normal mode never returns chaos-only missions', () {
      for (var i = 0; i < 200; i++) {
        final mission = MissionService.generate(_filter());
        expect(mission.chaosOnly, isFalse);
      }
    });

    test('respects the time budget', () {
      for (var i = 0; i < 100; i++) {
        final mission = MissionService.generate(
          _filter(time: TimeBudget.fiveMin),
        );
        expect(mission.maxTime.minutes, lessThanOrEqualTo(5));
      }
    });

    test('skips recently completed ids when alternatives exist', () {
      final exclude = MissionCatalog.all
          .where((m) => !m.chaosOnly)
          .map((m) => m.id)
          .take(5)
          .toSet();
      for (var i = 0; i < 50; i++) {
        final mission = MissionService.generate(
          _filter(),
          excludeIds: exclude,
        );
        expect(exclude.contains(mission.id), isFalse);
      }
    });

    test('still returns a mission when everything is excluded', () {
      final exclude = MissionCatalog.all.map((m) => m.id).toSet();
      final mission = MissionService.generate(
        _filter(),
        excludeIds: exclude,
      );
      expect(MissionCatalog.all.contains(mission), isTrue);
    });
  });
}
