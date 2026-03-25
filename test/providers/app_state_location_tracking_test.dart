import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wildrapport/providers/app_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppStateProvider location tracking preference', () {
    test('loads saved location tracking preference from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'location_tracking_enabled': true,
      });

      final provider = AppStateProvider();
      await provider.loadLocationTrackingPreference();

      expect(provider.isLocationTrackingEnabled, isTrue);
    });

    test('setLocationTrackingEnabled persists and updates flag', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = AppStateProvider();

      await provider.setLocationTrackingEnabled(true);
      expect(provider.isLocationTrackingEnabled, isTrue);

      await provider.setLocationTrackingEnabled(false);
      expect(provider.isLocationTrackingEnabled, isFalse);
    });
  });
}
