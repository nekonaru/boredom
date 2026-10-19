import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boredom/models/mission.dart';
import 'package:boredom/models/user_progress.dart';
import 'package:boredom/providers/boredom_provider.dart';
import 'package:boredom/services/mission_catalog.dart';
import 'package:boredom/services/storage_service.dart';
import 'package:boredom/utils/date_format.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    StorageService.instance.clearCache();
  });

  /// Seeds reminder state without going through [BoredomProvider.setReminder]:
  /// that asks the notification plugin for permission, which a unit test
  /// cannot grant, so the switch would always stay off. What is under test
  /// here is the export and import of the values, not the permission flow.
  Future<void> seedReminder(
    BoredomProvider p, {
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    p.reminderEnabled = enabled;
    p.reminderHour = hour;
    p.reminderMinute = minute;
    await StorageService.instance.saveReminder(
      enabled: enabled,
      hour: hour,
      minute: minute,
    );
  }

  MissionInstance armed(BoredomProvider p) {
    p.currentMission = MissionInstance(
      mission: MissionCatalog.all.first,
      missionNumber: 1,
    );
    return p.currentMission!;
  }

  group('Backup round trips the reminder settings', () {
    test('a restore brings the schedule back instead of dropping it',
        () async {
      final source = BoredomProvider();
      await seedReminder(source, enabled: true, hour: 7, minute: 45);

      final fresh = BoredomProvider();
      expect(await fresh.importBackup(await source.exportBackup()), isTrue);

      // Previously the import unconditionally switched reminders off and
      // reset the time, so restoring on a new phone silently lost them.
      expect(fresh.reminderEnabled, isTrue);
      expect(fresh.reminderHour, 7);
      expect(fresh.reminderMinute, 45);
    });

    test('a backup with reminders off restores as off', () async {
      final source = BoredomProvider();
      await seedReminder(source, enabled: false, hour: 9, minute: 0);

      final fresh = BoredomProvider();
      await fresh.importBackup(await source.exportBackup());
      expect(fresh.reminderEnabled, isFalse);
      expect(fresh.reminderHour, 9);
    });

    test('an old backup with no reminder block still clears the schedule',
        () async {
      final source = BoredomProvider();
      armed(source);
      await source.completeMission();
      // A payload written before v2.8.0.
      final stripped = (await source.exportBackup()).replaceFirst(
            RegExp(r'"reminder":\{[^}]*\}'),
            '"reminder":null',
          );

      final fresh = BoredomProvider();
      await seedReminder(fresh, enabled: true, hour: 6, minute: 0);

      expect(await fresh.importBackup(stripped), isTrue);
      expect(fresh.reminderEnabled, isFalse,
          reason: 'a legacy restore must not leave an invisible schedule');
    });

    test('an out-of-range hour is clamped, not trusted', () async {
      final source = BoredomProvider();
      await seedReminder(source, enabled: true, hour: 8, minute: 0);
      final tampered = (await source.exportBackup()).replaceFirst(
            '"hour":8',
            '"hour":99',
          );

      final fresh = BoredomProvider();
      expect(await fresh.importBackup(tampered), isTrue);
      expect(fresh.reminderHour, inInclusiveRange(0, 23));
    });
  });

  group('History cap', () {
    test('the cap is far above a plausible history and is a constant',
        () async {
      expect(StorageService.kMaxHistoryEntries, greaterThanOrEqualTo(500));
    });

    test('saveHistory keeps the newest rows, not the oldest', () async {
      final storage = StorageService.instance;
      final rows = List.generate(
        StorageService.kMaxHistoryEntries + 50,
        (i) => CompletedMission(
          missionId: 'm$i',
          title: 'T$i',
          emoji: '🎯',
          categoryLabel: 'Gaming',
          xpEarned: 10,
          completedAt: DateTime(2026, 1, 1).add(Duration(minutes: i)),
        ),
      );
      // Newest-first, as the provider keeps it.
      final newestFirst = rows.reversed.toList();
      await storage.saveHistory(newestFirst);

      final loaded = await storage.loadHistory();
      expect(loaded.length, StorageService.kMaxHistoryEntries);
      // The survivors must be the newest ones.
      final newest = rows.last;
      expect(
        loaded.map((e) => e.missionId),
        contains(newest.missionId),
      );
    });
  });

  group('Orphan favorites', () {
    test('are counted, pruned, and persisted', () async {
      final p = BoredomProvider();
      await p.toggleFavorite(MissionCatalog.all.first.id);
      // Simulate a favorite whose mission was dropped from the catalog.
      await StorageService.instance.saveFavorites({
        ...p.favoriteIds,
        'removed_mission_xyz',
      });

      final reloaded = BoredomProvider();
      await reloaded.init();
      expect(reloaded.isFavorite('removed_mission_xyz'), isTrue);
      // Invisible in the UI: missionById returns null.
      expect(reloaded.missionById('removed_mission_xyz'), isNull);

      final removed = await reloaded.pruneOrphanFavorites();
      expect(removed, 1);
      expect(reloaded.isFavorite('removed_mission_xyz'), isFalse);
      expect(
        reloaded.isFavorite(MissionCatalog.all.first.id),
        isTrue,
        reason: 'valid favorites must survive the cleanup',
      );

      final after = BoredomProvider();
      await after.init();
      expect(after.isFavorite('removed_mission_xyz'), isFalse);
    });

    test('pruning nothing changes nothing', () async {
      final p = BoredomProvider();
      await p.toggleFavorite(MissionCatalog.all.first.id);
      expect(await p.pruneOrphanFavorites(), 0);
      expect(p.favoriteIds.length, 1);
    });
  });

  group('History dates', () {
    test('omit the year for the current year and include it otherwise', () {
      final now = DateTime.now();
      final thisYear = formatHistoryDate(
        DateTime(now.year, 3, 4, 21, 14),
      );
      expect(thisYear, '4 Mar, 21:14');
      expect(thisYear, isNot(contains('${now.year}')));

      final lastYear = formatHistoryDate(DateTime(now.year - 1, 12, 31, 8, 5));
      expect(lastYear, contains('${now.year - 1}'));
    });

    test('follow the active language for month names', () {
      final now = DateTime.now();
      final dt = DateTime(now.year, 5, 1, 12, 0);
      expect(formatHistoryDate(dt, code: 'en'), '1 May, 12:00');
      expect(formatHistoryDate(dt, code: 'id'), '1 Mei, 12:00');
    });
  });
}
