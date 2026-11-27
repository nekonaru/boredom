import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boredom/models/user_progress.dart';
import 'package:boredom/providers/theme_provider.dart';
import 'package:boredom/services/history_filter.dart';
import 'package:boredom/services/storage_service.dart';
import 'package:boredom/utils/app_theme.dart';
import 'package:boredom/widgets/weekly_chart.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    StorageService.instance.clearCache();
  });

  group('v5.0 theme', () {
    test('black palette is a true black surface with semantic colors intact',
        () {
      final black = AppPalette.black(const Color(0xFF7C6CFF));
      expect(black.background, const Color(0xFF000000));
      expect(black.success, AppPalette.dark(const Color(0xFF7C6CFF)).success);
      expect(black.danger, AppPalette.dark(const Color(0xFF7C6CFF)).danger);
    });

    test('theme mode persists and old light boolean migrates once', () async {
      SharedPreferences.setMockInitialValues({'theme_light': true});
      StorageService.instance.clearCache();
      final tp = ThemeProvider.instance;
      await tp.load();
      expect(tp.themeMode, ThemeModeKind.light);
      expect(tp.isLight, isTrue);
      await tp.setThemeMode(ThemeModeKind.black);
      expect(tp.materialThemeMode, ThemeMode.dark);
      expect(tp.paletteFor(Brightness.dark).background,
          const Color(0xFF000000));
      expect(tp.fontScale, 1.0);
      await tp.setFontScale(1.15);
      expect(tp.fontScale, 1.15);
      await tp.setReduceMotion(true);
      expect(tp.reduceMotion, isTrue);
    });

    test('system mode follows platform brightness', () async {
      final tp = ThemeProvider.instance;
      await tp.setThemeMode(ThemeModeKind.system);
      expect(tp.isEffectivelyLight(Brightness.light), isTrue);
      expect(tp.isEffectivelyLight(Brightness.dark), isFalse);
    });
  });

  group('v5.0 history sort', () {
    CompletedMission row(DateTime at, int xp) => CompletedMission(
          missionId: 'm',
          title: 'M',
          emoji: '🎲',
          categoryLabel: 'Test',
          completedAt: at,
          xpEarned: xp,
        );

    test('sorts by newest, oldest, and XP without mutating input', () {
      final rows = [
        row(DateTime(2026, 1, 1), 20),
        row(DateTime(2026, 3, 1), 10),
        row(DateTime(2026, 2, 1), 30),
      ];
      final newest = HistoryFilters.sort(rows, HistorySort.newestFirst);
      expect(newest.first.completedAt, DateTime(2026, 3, 1));
      final oldest = HistoryFilters.sort(rows, HistorySort.oldestFirst);
      expect(oldest.first.completedAt, DateTime(2026, 1, 1));
      final xp = HistoryFilters.sort(rows, HistorySort.xpHighest);
      expect(xp.first.xpEarned, 30);
      expect(rows.first.completedAt, DateTime(2026, 1, 1));
    });
  });

  group('v5.0 chart reveal', () {
    test('reveal participates in repaint so entrance animation redraws', () {
      final base = ActivityBarsPainter(
        counts: const [1, 2, 3],
        active: Colors.blue,
        inactive: Colors.grey,
        empty: Colors.black,
        reveal: 1,
      );
      final animating = ActivityBarsPainter(
        counts: const [1, 2, 3],
        active: Colors.blue,
        inactive: Colors.grey,
        empty: Colors.black,
        reveal: 0.5,
      );
      expect(base.shouldRepaint(animating), isTrue);
    });
  });
}
