import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boredom/models/mission.dart';
import 'package:boredom/models/mission_catalog.dart';
import 'package:boredom/models/user_progress.dart';
import 'package:boredom/providers/boredom_provider.dart';
import 'package:boredom/services/storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    StorageService.instance.clearCache();
  });

  MissionInstance armed(BoredomProvider p) {
    p.currentMission = MissionInstance(
      mission: MissionCatalog.all.first,
      missionNumber: 1,
    );
    return p.currentMission!;
  }

  group('Undo after saveForLater restores counter and list together', () {
    test('undoing a completion then saving to inbox then undoing restores both', () async {
      final p = BoredomProvider();
      armed(p);
      await p.completeMission();
      expect(p.progress.missionsSaved, 0);
      expect(p.savedMissions, isEmpty);

      // Save to inbox AFTER the undo snapshot was taken.
      await p.saveForLater('home_01');
      expect(p.progress.missionsSaved, 1);
      expect(p.savedMissions.length, 1);

      expect(await p.undoLastAction(), isTrue);

      // Both the counter and the list must be restored together.
      expect(p.progress.missionsSaved, 0);
      expect(p.savedMissions, isEmpty);
    });

    test('saving to inbox then undoing restores both', () async {
      final p = BoredomProvider();
      armed(p);
      await p.completeMission();
      expect(p.progress.missionsSaved, 0);

      await p.saveForLater('home_01');
      expect(p.progress.missionsSaved, 1);
      expect(p.savedMissions.length, 1);

      expect(await p.undoLastAction(), isTrue);
      expect(p.progress.missionsSaved, 0);
      expect(p.savedMissions, isEmpty);
    });
  });
}
