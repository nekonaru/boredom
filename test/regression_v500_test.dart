import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boredom/providers/boredom_provider.dart';
import 'package:boredom/providers/language_provider.dart';
import 'package:boredom/providers/theme_provider.dart';
import 'package:boredom/screens/onboarding_screen.dart';
import 'package:boredom/l10n/app_strings.dart';
import 'package:boredom/models/boredom_rank.dart';
import 'package:boredom/models/mission.dart';
import 'package:boredom/models/user_progress.dart';
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

  group('v5.0 ranks', () {
    test('thresholds and next target are monotonic and cap at mythic', () {
      expect(BoredomRanks.forXp(0).id, BoredomRank.bronze);
      expect(BoredomRanks.forXp(499).id, BoredomRank.bronze);
      expect(BoredomRanks.forXp(500).id, BoredomRank.silver);
      expect(BoredomRanks.forXp(2000).id, BoredomRank.gold);
      expect(BoredomRanks.forXp(6000).id, BoredomRank.diamond);
      expect(BoredomRanks.forXp(15000).id, BoredomRank.mythic);
      expect(BoredomRanks.xpToNext(0), 500);
      expect(BoredomRanks.xpToNext(15000), isNull);
      expect(BoredomRanks.title(0, code: 'id'), 'Perunggu');
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

  group('v5.0 interactive onboarding', () {
    testWidgets('five steps, mood is tappable and a mission can be rolled',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      StorageService.instance.clearCache();
      final provider = BoredomProvider()..init();
      await pumpAndSettleSafe(tester);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<BoredomProvider>.value(value: provider),
            ChangeNotifierProvider<LanguageProvider>.value(
                value: LanguageProvider.instance),
            ChangeNotifierProvider<ThemeProvider>.value(
                value: ThemeProvider.instance),
          ],
          child: const MaterialApp(home: OnboardingScreen()),
        ),
      );
      await pumpAndSettleSafe(tester);

      // Step 1: welcome. Next is enabled.
      expect(find.text('Boredom, meet the real world'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await pumpAndSettleSafe(tester);

      // Step 2: mood chips change real provider state.
      expect(find.text('How do you feel?'), findsOneWidget);
      final s = AppStrings('en');
      final moodLabel = s.moodLabel(Mood.energetic);
      await tester.ensureVisible(find.text(moodLabel));
      await pumpAndSettleSafe(tester);
      await tester.tap(find.text(moodLabel));
      await pumpAndSettleSafe(tester);
      expect(provider.selectedMood, Mood.energetic);

      // Step 3: roll a preview mission.
      await tester.tap(find.text('Next'));
      await pumpAndSettleSafe(tester);
      expect(find.text('Meet your first mission'), findsOneWidget);
      await tester.tap(find.text('Roll a mission'));
      await pumpAndSettleSafe(tester);
      expect(find.text('Your mission:'), findsOneWidget);
    });
  });
}

Future<void> pumpAndSettleSafe(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}
