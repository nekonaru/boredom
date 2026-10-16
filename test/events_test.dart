import 'package:flutter_test/flutter_test.dart';
import 'package:boredom/models/mission.dart';
import 'package:boredom/models/user_progress.dart';
import 'package:boredom/providers/boredom_provider.dart';
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
  group('Weekend double XP', () {
    test('Saturday and Sunday double the base XP', () {
      // 2026-01-03 is a Saturday, 2026-01-04 a Sunday, 2026-01-05 a Monday.
      expect(BoredomProvider.xpForDate(30, DateTime(2026, 1, 3)), 60);
      expect(BoredomProvider.xpForDate(30, DateTime(2026, 1, 4)), 60);
      expect(BoredomProvider.xpForDate(30, DateTime(2026, 1, 5)), 30);
    });

    test('isWeekend matches calendar weekends only', () {
      expect(BoredomProvider.isWeekend(DateTime(2026, 1, 3)), isTrue);
      expect(BoredomProvider.isWeekend(DateTime(2026, 1, 7)), isFalse);
    });
  });

  group('Seasonal missions', () {
    test('January-only missions never roll in June', () {
      for (var i = 0; i < 100; i++) {
        final mission = MissionService.generate(
          _filter(),
          now: DateTime(2026, 6, 15),
        );
        expect(mission.months.isEmpty || mission.months.contains(6), isTrue);
      }
    });

    test('December missions can roll in December', () {
      var sawSeasonal = false;
      for (var i = 0; i < 300; i++) {
        final mission = MissionService.generate(
          _filter(),
          now: DateTime(2026, 12, 10),
        );
        if (mission.months.contains(12)) {
          sawSeasonal = true;
          break;
        }
      }
      expect(sawSeasonal, isTrue);
    });
  });

  group('Category weighting', () {
    test('unplayed categories weigh more than played ones', () {
      final mission = MissionCatalog.all.first;
      final fresh = MissionService.weightFor(mission, const {});
      final played = MissionService.weightFor(
        mission,
        {mission.category.name: 9},
      );
      expect(fresh, greaterThan(played));
      expect(fresh, 1.0);
      expect(played, closeTo(0.1, 0.0001));
    });
  });

  group('Freeze tokens storage', () {
    test('tokens survive a JSON round trip', () {
      const p = UserProgress(freezeTokens: 2);
      expect(UserProgress.fromJson(p.toJson()).freezeTokens, 2);
    });

    test('old saves without tokens default to zero', () {
      const p = UserProgress();
      final restored = UserProgress.fromJson(p.toJson()
        ..remove('freezeTokens'));
      expect(restored.freezeTokens, 0);
    });
  });
}
