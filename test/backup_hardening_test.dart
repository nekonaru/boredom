import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boredom/models/mission.dart';
import 'package:boredom/providers/boredom_provider.dart';
import 'package:boredom/services/mission_catalog.dart';
import 'package:boredom/services/storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    StorageService.instance.clearCache();
  });

  group('Backup round trip', () {
    test('survives control characters in custom mission text', () async {
      final p = BoredomProvider();
      await p.addCustomMission('Tab\there', 'line1\r\nline2\tend', 30);

      final backup = await p.exportBackup();
      // The export must be valid JSON: no raw control characters.
      expect(backup.contains('\t'), isFalse);
      expect(backup.contains('\r'), isFalse);

      final fresh = BoredomProvider();
      expect(await fresh.importBackup(backup), isTrue);
      expect(fresh.customMissions.single.title, 'Tab\there');
      expect(fresh.customMissions.single.description, 'line1\r\nline2\tend');
    });

    test('survives quotes and backslashes in mission text', () async {
      final p = BoredomProvider();
      await p.addCustomMission('He said "hi"', r'path\to\file "x"', 25);
      final backup = await p.exportBackup();

      final fresh = BoredomProvider();
      expect(await fresh.importBackup(backup), isTrue);
      expect(fresh.customMissions.single.title, 'He said "hi"');
      expect(fresh.customMissions.single.description, r'path\to\file "x"');
    });

    test('round trips inbox, muted categories, and dislikes', () async {
      final p = BoredomProvider();
      await p.saveForLater('home_01');
      await p.toggleCategoryMuted(MissionCategory.gaming);
      await p.toggleDislike('code_01');
      p.currentMission = MissionInstance(
        mission: MissionCatalog.all.first,
        missionNumber: 1,
      );
      await p.completeMission();

      final fresh = BoredomProvider();
      expect(await fresh.importBackup(await p.exportBackup()), isTrue);
      expect(fresh.savedMissions.length, 1);
      expect(fresh.isCategoryMuted(MissionCategory.gaming.name), isTrue);
      expect(fresh.isDisliked('code_01'), isTrue);
      expect(fresh.history.length, 1);
      expect(fresh.progress.totalXp, greaterThan(0));
    });
  });

  group('Backup rejects hostile input', () {
    test('rejects deep nesting instead of blowing the stack', () async {
      final p = BoredomProvider();
      final deep = '{"a":${'[' * 5000}${']' * 5000}}';
      expect(await p.importBackup(deep), isFalse);
    });

    test('rejects an oversized payload', () async {
      final p = BoredomProvider();
      final huge = '{"app":"boredom","pad":"${'x' * (3 * 1024 * 1024)}"}';
      expect(await p.importBackup(huge), isFalse);
    });

    test('rejects garbage and wrong app without mutating state', () async {
      final p = BoredomProvider();
      p.currentMission = MissionInstance(
        mission: MissionCatalog.all.first,
        missionNumber: 1,
      );
      await p.completeMission();
      final xpBefore = p.progress.totalXp;

      expect(await p.importBackup('not json at all'), isFalse);
      expect(await p.importBackup('{"app":"other"}'), isFalse);
      // Failed import must leave everything exactly as it was.
      expect(p.progress.totalXp, xpBefore);
      expect(p.history.length, 1);
    });

    test('rejects a truncated escape and a bad number', () async {
      final p = BoredomProvider();
      expect(await p.importBackup('{"app":"boredom","a":"\\uZZZZ"}'), isFalse);
      expect(await p.importBackup('{"app":"boredom","a":1.2.3}'), isFalse);
    });
  });

  group('Inbox restore does not clobber an active mission', () {
    test('refuses and keeps the inbox entry', () async {
      final p = BoredomProvider();
      await p.saveForLater('home_01');
      p.currentMission = MissionInstance(
        mission: MissionCatalog.all.first,
        missionNumber: 1,
      );
      final active = p.currentMission;

      expect(await p.restoreSavedMission('home_01'), isNull);
      expect(identical(p.currentMission, active), isTrue);
      expect(p.isSavedForLater('home_01'), isTrue,
          reason: 'nothing may be lost when the restore is refused');
    });
  });

  group('Milestone bonus for non-mission rewards', () {
    test('now actually pays on a daily challenge crossing level 10', () {
      // 450 XP is the threshold for level 10; a 150 XP challenge from just
      // below it must cross it and pay.
      final justBelow = 449;
      expect(
        BoredomProvider.milestoneXpFor(
          justBelow,
          150,
          DateTime(2026, 1, 5),
        ),
        30,
      );
    });

    test('returns zero when no boundary is crossed', () {
      expect(
        BoredomProvider.milestoneXpFor(100, 20, DateTime(2026, 1, 5)),
        0,
      );
    });

    test('a zero-value reward can never claim a milestone', () {
      expect(BoredomProvider.milestoneXpFor(449, 0, DateTime(2026, 1, 5)), 0);
    });
  });
}