import 'package:flutter_test/flutter_test.dart';
import 'package:boredom/models/user_progress.dart';

void main() {
  group('UserProgress level curve', () {
    test('new users start at level 1 with no negative XP display', () {
      const p = UserProgress();
      expect(p.level, 1);
      expect(p.xpIntoCurrentLevel, 0);
      expect(p.xpIntoCurrentLevel, greaterThanOrEqualTo(0));
    });

    test('level thresholds follow the triangular curve', () {
      // Level 2 needs 50 XP, level 3 needs 150 XP total.
      expect(UserProgress.xpNeededForLevel(1), 0);
      expect(UserProgress.xpNeededForLevel(2), 50);
      expect(UserProgress.xpNeededForLevel(3), 150);
    });

    test('level rises exactly at thresholds', () {
      expect(const UserProgress(totalXp: 49).level, 1);
      expect(const UserProgress(totalXp: 50).level, 2);
      expect(const UserProgress(totalXp: 149).level, 2);
      expect(const UserProgress(totalXp: 150).level, 3);
    });

    test('level progress stays within 0..1', () {
      const p = UserProgress(totalXp: 75);
      expect(p.levelProgress, greaterThanOrEqualTo(0));
      expect(p.levelProgress, lessThanOrEqualTo(1));
    });

    test('every level has a non-empty title', () {
      for (var level = 1; level <= 120; level++) {
        expect(LevelTitles.titleFor(level), isNotEmpty);
      }
    });

    test('JSON round trip preserves fields', () {
      const p = UserProgress(
        totalXp: 123,
        streakDays: 4,
        totalMissionsCompleted: 7,
        longestStreak: 9,
      );
      final restored = UserProgress.fromJson(p.toJson());
      expect(restored.totalXp, 123);
      expect(restored.streakDays, 4);
      expect(restored.totalMissionsCompleted, 7);
      expect(restored.longestStreak, 9);
    });
  });
}
