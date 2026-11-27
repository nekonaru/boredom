import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boredom/providers/boredom_provider.dart';
import 'package:boredom/services/storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    StorageService.instance.clearCache();
  });

  group('Achievement pinning', () {
    test('publishing a pin uses a new set and notifies listeners', () async {
      final p = BoredomProvider();
      final before = p.pinnedAchievements;
      var notifications = 0;
      p.addListener(() => notifications++);

      await p.togglePinned('first');

      expect(p.isPinned('first'), isTrue);
      expect(p.pinnedAchievements, isNot(same(before)));
      expect(notifications, 1);

      await p.togglePinned('first');

      expect(p.isPinned('first'), isFalse);
      expect(p.pinnedAchievements, isNot(same(before)));
      expect(notifications, 2);
    });

    test('a fourth pin is ignored and unpinning frees a slot', () async {
      final p = BoredomProvider();
      for (final id in ['one', 'two', 'three']) {
        await p.togglePinned(id);
      }
      final three = p.pinnedAchievements;
      var notifications = 0;
      p.addListener(() => notifications++);

      await p.togglePinned('four');

      expect(p.pinnedAchievements, equals(three));
      expect(p.pinnedAchievements.length, kMaxPinnedAchievements);
      expect(p.isPinned('four'), isFalse);
      expect(notifications, 0, reason: 'a refused pin must not rebuild the UI');

      await p.togglePinned('two');
      await p.togglePinned('four');

      expect(p.isPinned('two'), isFalse);
      expect(p.isPinned('four'), isTrue);
      expect(p.pinnedAchievements.length, kMaxPinnedAchievements);
    });

    test('pins persist and reload through storage', () async {
      final p = BoredomProvider();
      await p.togglePinned('alpha');
      await p.togglePinned('beta');

      expect(
        await StorageService.instance.loadPinnedAchievements(),
        equals({'alpha', 'beta'}),
      );

      final reloaded = BoredomProvider();
      await reloaded.init();

      expect(reloaded.pinnedAchievements, equals({'alpha', 'beta'}));
      expect(reloaded.isPinned('alpha'), isTrue);
    });

    test('reset clears pins in memory and on disk', () async {
      final p = BoredomProvider();
      await p.togglePinned('alpha');
      await p.resetProgress();

      expect(p.pinnedAchievements, isEmpty);
      expect(await StorageService.instance.loadPinnedAchievements(), isEmpty);
    });

    test('pins survive a backup round trip', () async {
      final p = BoredomProvider();
      await p.togglePinned('alpha');
      await p.togglePinned('beta');

      final fresh = BoredomProvider();
      expect(await fresh.importBackup(await p.exportBackup()), isTrue);

      expect(fresh.pinnedAchievements, equals({'alpha', 'beta'}));
      expect(await StorageService.instance.loadPinnedAchievements(),
          equals({'alpha', 'beta'}));
    });

    test('a v1 backup without pins still imports with an empty default',
        () async {
      final p = BoredomProvider();
      await p.togglePinned('alpha');

      // Stand in for a backup written before pinning existed: same payload
      // shape, no pinned ids, and the old version marker.
      final data = jsonDecode(await p.exportBackup()) as Map<String, dynamic>;
      expect(data['version'], 2);
      data.remove('pinnedAchievements');
      data['version'] = 1;

      final fresh = BoredomProvider();
      expect(await fresh.importBackup(jsonEncode(data)), isTrue);

      expect(fresh.pinnedAchievements, isEmpty);
      expect(await StorageService.instance.loadPinnedAchievements(), isEmpty);
    });
  });
}
