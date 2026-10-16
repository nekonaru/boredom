import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boredom/services/storage_service.dart';

void main() {
  group('Onboarding flag', () {
    test('defaults to not seen on fresh installs', () async {
      SharedPreferences.setMockInitialValues({});
      StorageService.instance.clearCache();
      expect(await StorageService.instance.isOnboardingDone(), isFalse);
    });

    test('persists once completed', () async {
      SharedPreferences.setMockInitialValues({});
      StorageService.instance.clearCache();
      await StorageService.instance.setOnboardingDone(true);
      expect(await StorageService.instance.isOnboardingDone(), isTrue);
    });
  });
}
