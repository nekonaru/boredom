import 'package:flutter_test/flutter_test.dart';
import 'package:boredom/models/mission.dart';
import 'package:boredom/models/user_progress.dart';
import 'package:boredom/providers/boredom_provider.dart';
import 'package:boredom/services/mission_catalog.dart';
import 'package:boredom/services/mission_service.dart';

MissionFilter _filter() => const MissionFilter(
      mood: Mood.normal,
      timeBudget: TimeBudget.thirtyMin,
      location: LocationType.anywhere,
      energy: EnergyLevel.medium,
    );

void main() {
  group('Muted categories', () {
    test('muted categories never roll', () {
      final muted = <String>{
        MissionCategory.outdoor.name,
        MissionCategory.gaming.name,
        MissionCategory.social.name,
        MissionCategory.creative.name,
      };
      for (var i = 0; i < 150; i++) {
        final mission = MissionService.generate(
          _filter(),
          excludeCategories: muted,
        );
        expect(muted.contains(mission.category.name), isFalse);
      }
    });

    test('muting every category still returns a mission', () {
      final all = MissionCategory.values.map((c) => c.name).toSet();
      final mission = MissionService.generate(
        _filter(),
        excludeCategories: all,
      );
      expect(MissionCatalog.all.contains(mission), isTrue);
    });
  });

  group('Milestone bonus', () {
    test('only multiples of 10 give a bonus', () {
      expect(BoredomProvider.milestoneBonus(0), 0);
      expect(BoredomProvider.milestoneBonus(9), 0);
      expect(BoredomProvider.milestoneBonus(10), 30);
      expect(BoredomProvider.milestoneBonus(20), 60);
      expect(BoredomProvider.milestoneBonus(25), 0);
    });

    test('milestoneLevel reflects XP after the gain', () {
      // 49 XP is still level 1, adding 1 XP reaches level 2.
      expect(BoredomProvider.milestoneLevel(49, 1, DateTime(2026, 1, 5)), 2);
      expect(BoredomProvider.milestoneLevel(0, 15, DateTime(2026, 1, 5)), 1);
    });
  });

  group('Weekly summary', () {
    test('counts only the last 7 days', () {
      final p = BoredomProvider();
      final now = DateTime.now();
      p.history = [
        CompletedMission(
          missionId: 'a',
          title: 'A',
          emoji: '🧪',
          categoryLabel: 'Test',
          xpEarned: 20,
          completedAt: now,
        ),
        CompletedMission(
          missionId: 'b',
          title: 'B',
          emoji: '🧪',
          categoryLabel: 'Test',
          xpEarned: 30,
          completedAt: now.subtract(const Duration(days: 20)),
        ),
      ];
      final summary = p.last7DaysSummary;
      expect(summary.missions, 1);
      expect(summary.xp, 20);
    });
  });

  group('New progress fields persist', () {
    test('freeze tokens earned and saved missions round trip', () {
      const p = UserProgress(freezeTokensEarned: 4, missionsSaved: 12);
      final restored = UserProgress.fromJson(p.toJson());
      expect(restored.freezeTokensEarned, 4);
      expect(restored.missionsSaved, 12);
    });

    test('old saves default the new fields to zero', () {
      final json = const UserProgress().toJson()
        ..remove('freezeTokensEarned')
        ..remove('missionsSaved');
      final restored = UserProgress.fromJson(json);
      expect(restored.freezeTokensEarned, 0);
      expect(restored.missionsSaved, 0);
    });
  });
}