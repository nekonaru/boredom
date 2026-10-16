import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boredom/l10n/app_strings.dart';
import 'package:boredom/models/user_progress.dart';
import 'package:boredom/providers/boredom_provider.dart';
import 'package:boredom/providers/theme_provider.dart';
import 'package:boredom/utils/app_theme.dart';

void main() {
  group('Theme palettes', () {
    test('dark and light palettes differ and are complete', () {
      const accent = Color(0xFF7C6CFF);
      final dark = AppPalette.dark(accent);
      final light = AppPalette.light(accent);
      expect(dark.background, isNot(light.background));
      expect(dark.textPrimary, isNot(light.textPrimary));
      expect(dark.accent, accent);
      expect(light.accent, accent);
    });

    test('accent index clamps into range', () {
      final tp = ThemeProvider.instance;
      expect(tp.accents.length, 5);
      expect(tp.accent, ThemeProvider.accents[0]);
    });
  });

  group('Monthly stats', () {
    BoredomProvider providerWith(List<CompletedMission> entries) {
      final p = BoredomProvider();
      p.history = entries;
      return p;
    }

    CompletedMission entry(DateTime at, int xp) => CompletedMission(
          missionId: 'm_${at.millisecondsSinceEpoch}_$xp',
          title: 'Test',
          emoji: '🧪',
          categoryLabel: 'Test',
          xpEarned: xp,
          completedAt: at,
        );

    test('last30DaysCounts has 30 buckets with today last', () {
      final now = DateTime.now();
      final p = providerWith([entry(now, 10)]);
      final counts = p.last30DaysCounts;
      expect(counts.length, 30);
      expect(counts[29], 1);
      expect(counts[0], 0);
    });

    test('average XP divides by active days only', () {
      final day = DateTime(2026, 1, 5, 12);
      final p = providerWith([
        entry(day, 20),
        entry(day.add(const Duration(hours: 1)), 40),
      ]);
      expect(p.avgXpPerActiveDay, 60);
    });

    test('average XP is zero with no history', () {
      expect(providerWith([]).avgXpPerActiveDay, 0);
      expect(providerWith([]).busiestWeekday, isNull);
    });

    test('busiest weekday picks the most frequent day', () {
      // 2026-01-05 is a Monday, 2026-01-07 a Wednesday.
      final p = providerWith([
        entry(DateTime(2026, 1, 5, 10), 10),
        entry(DateTime(2026, 1, 5, 11), 10),
        entry(DateTime(2026, 1, 7, 10), 10),
      ]);
      expect(p.busiestWeekday, DateTime.monday);
    });
  });

  group('Weekday names', () {
    test('both languages cover all 7 days', () {
      expect(const AppStrings('en').weekdaysShort.length, 7);
      expect(const AppStrings('id').weekdaysShort.length, 7);
      expect(const AppStrings('en').weekdayName(1), 'Monday');
      expect(const AppStrings('id').weekdayName(7), 'Minggu');
    });
  });
}
