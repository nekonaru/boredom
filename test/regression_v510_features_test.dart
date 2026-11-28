import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boredom/models/journal_entry.dart';
import 'package:boredom/providers/boredom_provider.dart';
import 'package:boredom/services/mission_catalog.dart';
import 'package:boredom/services/storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    StorageService.instance.clearCache();
  });

  BoredomProvider freshProvider() => BoredomProvider()..init();

  group('v5.1 journal', () {
    test('write replaces the note for the same mission and persists', () async {
      final provider = freshProvider();
      await provider.writeJournal('m1', 'first', JournalMood.great);
      await provider.writeJournal('m1', 'second', JournalMood.meh);
      expect(provider.journal.length, 1);
      expect(provider.journal.single.note, 'second');
      expect(provider.journal.single.mood, JournalMood.meh);

      final reloaded = freshProvider();
      await reloaded.init();
      expect(reloaded.journalFor('m1')?.note, 'second');
    });

    test('journal survives a backup round trip and old backups default empty',
        () async {
      final provider = freshProvider();
      await provider.writeJournal('m2', 'felt good', JournalMood.great);
      final backup = await provider.exportBackup();
      final restored = freshProvider();
      final ok = await restored.importBackup(backup);
      expect(ok, isTrue);
      expect(restored.journalFor('m2')?.note, 'felt good');
    });
  });

  group('v5.1 replay', () {
    test('replay creates a mission only when none is active', () async {
      final provider = freshProvider();
      final id = MissionCatalog.all.first.id;
      expect(await provider.replayMission(id), isTrue);
      expect(provider.currentMission?.mission.id, id);
      expect(await provider.replayMission(id), isFalse);
    });
  });

  group('v5.1 favorites-only roll', () {
    test('toggle publishes immediately and rolls from favorites when set', () {
      final provider = freshProvider();
      provider.favoriteIds = {MissionCatalog.all.first.id};
      provider.setFavoritesOnly(true);
      expect(provider.favoritesOnly, isTrue);
      provider.rollMission();
      expect(provider.currentMission?.mission.id, MissionCatalog.all.first.id);
    });
  });
}
