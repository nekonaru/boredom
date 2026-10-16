import 'package:flutter_test/flutter_test.dart';
import 'package:boredom/l10n/app_strings.dart';
import 'package:boredom/services/achievement_catalog.dart';
import 'package:boredom/services/daily_challenge_catalog.dart';
import 'package:boredom/services/mission_catalog.dart';
import 'package:boredom/services/quest_chain_catalog.dart';

void main() {
  group('Localization', () {
    test('every chrome string is non-empty in both languages', () {
      for (final code in ['en', 'id']) {
        final s = AppStrings(code);
        expect(s.navHome, isNotEmpty);
        expect(s.headline, isNotEmpty);
        expect(s.subhead, isNotEmpty);
        expect(s.chaosDesc, isNotEmpty);
        expect(s.rerollsLeft(2), isNotEmpty);
        expect(s.historyEmpty, isNotEmpty);
        expect(s.aboutBody, isNotEmpty);
        expect(s.resetBody, isNotEmpty);
        expect(s.searchHint, isNotEmpty);
        expect(s.backupDesc, isNotEmpty);
        expect(s.weekTitle, isNotEmpty);
      }
    });

    test('English is the default and Indonesian differs somewhere', () {
      final en = const AppStrings('en');
      final id = const AppStrings('id');
      expect(en.headline, isNot(id.headline));
      expect(en.rerollsLeft(2), isNot(id.rerollsLeft(2)));
    });

    test('localizedTitle falls back to English when Indonesian is missing', () {
      expect(
        localizedTitle(en: 'Hello', id: null, code: 'id'),
        'Hello',
      );
      expect(
        localizedTitle(en: 'Hello', id: '', code: 'id'),
        'Hello',
      );
      expect(
        localizedTitle(en: 'Hello', id: 'Halo', code: 'id'),
        'Halo',
      );
    });

    test('catalog ids are unique', () {
      final missionIds = MissionCatalog.all.map((m) => m.id).toList();
      expect(missionIds.toSet().length, missionIds.length);

      final achIds = AchievementCatalog.all.map((a) => a.id).toList();
      expect(achIds.toSet().length, achIds.length);

      final dcIds = DailyChallengeCatalog.all.map((c) => c.id).toList();
      expect(dcIds.toSet().length, dcIds.length);
    });

    test('every catalog mission has a non-empty English description', () {
      for (final m in MissionCatalog.all) {
        expect(m.title, isNotEmpty);
        expect(m.description, isNotEmpty);
        expect(m.baseXp, greaterThan(0));
      }
    });

    test('daily challenge lookup is deterministic per date', () {
      final date = DateTime(2026, 5, 17);
      expect(
        DailyChallengeCatalog.forDate(date).id,
        DailyChallengeCatalog.forDate(date).id,
      );
    });

    test('quest chains have at least 2 steps and positive rewards', () {
      for (final chain in QuestChainCatalog.all) {
        expect(chain.steps.length, greaterThanOrEqualTo(2));
        expect(chain.rewardXp, greaterThan(0));
      }
    });
  });
}
