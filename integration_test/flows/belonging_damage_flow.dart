import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wildrapport/screens/overzicht_screen.dart';
import 'package:wildrapport/main.dart' as app;

void runTests() {
  group('End-to-end tests for Gewasschade reporting flow', () {
    testWidgets('User can navigate and complete the Gewasschade reporting flow', (WidgetTester tester) async {
      // Ensure environment is loaded
      await dotenv.load(fileName: '.env');

      // Verify bearer token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('bearer_token');
      expect(token, isNotNull, reason: 'Bearer token must be set for API authentication');
      
      app.main();

      // Wait for the app to settle (main.dart has run)
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Debug widget tree
      print(tester.allWidgets.map((w) => w.toString()).toList());

      // Verify OverzichtScreen is displayed
      expect(find.byType(OverzichtScreen), findsOneWidget, reason: 'OverzichtScreen should be displayed after login or app start');

      // Step 1: Verify and tap 'Rapporteren'
      expect(find.byKey(const Key('rapporteren_button')), findsOneWidget, reason: 'Rapporteren button should be visible');
      await tester.tap(find.byKey(const Key('rapporteren_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 2: Verify Rapporteren screen and tap 'Gewasschade'
      expect(find.text('Rapporteren'), findsOneWidget);
      await tester.tap(find.text('Gewasschade'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 3: Verify BelongingDamagesScreen with BelongingCropsDetails
      expect(find.byKey(const Key('impacted-crop')), findsOneWidget);

      // Step 4: Select 'Granen' from 'impacted-crop' dropdown
      await tester.tap(find.byKey(const Key('impacted-crop')));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.text('Granen').last);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Step 5: Select 'm2' from 'impacted-area-type' dropdown
      await tester.tap(find.byKey(const Key('impacted-area-type')));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.text('m2').last);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Step 6: Enter '1250' into 'area-value' text field
      await tester.enterText(find.byKey(const Key('area-value')), '1250');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Step 7: Set 'estimated-damage' slider to 2500
      final damageSlider = find.byKey(const Key('estimated-damage'));
      final damageSliderBox = tester.getRect(damageSlider);
      final damageDragOffset = (2500 / 10000) * damageSliderBox.width;
      final tapPositionDamage = damageSliderBox.topLeft + Offset(damageDragOffset, damageSliderBox.height / 2);
      await tester.tapAt(tapPositionDamage);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Step 8: Set 'estimated-future-damage' slider to 3350
      final futureDamageSlider = find.byKey(const Key('estimated-future-damage'));
      final futureDamageSliderBox = tester.getRect(futureDamageSlider);
      final futureDamageDragOffset = (3350 / 10000) * futureDamageSliderBox.width;
      final tapPositionFutureDamage = futureDamageSliderBox.topLeft + Offset(futureDamageDragOffset, futureDamageSliderBox.height / 2);
      await tester.tapAt(tapPositionFutureDamage);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Step 9: Tap 'Volgende' button
      await tester.tap(find.text('Volgende'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Step 10: Verify SuspectedAnimal screen and tap 'Evenhoevigen'
      expect(find.text('Evenhoevigen'), findsOneWidget);
      await tester.tap(find.text('Evenhoevigen'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Step 11: Verify Wisent is displayed and tap on it
      expect(find.text('Wisent'), findsOneWidget);
      await tester.tap(find.text('Wisent'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 12: Verify Huidige locatie is displayed and tap on it
      expect(find.text('Huidige locatie'), findsOneWidget);
      await tester.tap(find.text('Huidige locatie'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Step 13: Verify Zuid-Kennemerland is displayed and tap on it
      expect(find.text('Zuid-Kennemerland'), findsOneWidget);
      await tester.tap(find.text('Zuid-Kennemerland'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 14: tap on center of the screen to select location
      final screenSize = tester.view.physicalSize / tester.view.devicePixelRatio;
      final center = Offset(screenSize.width / 2, screenSize.height / 2);
      await tester.tapAt(center);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 15: Verify Bevestig is displayed and tap on it
      expect(find.text('Bevestig'), findsOneWidget);
      await tester.tap(find.text('Bevestig'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Step 16: Verify Volgende is displayed and tap on it
      expect(find.text('Volgende'), findsOneWidget);
      await tester.tap(find.text('Volgende'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Step 17: Verify Overslaan is displayed and tap on it
      expect(find.text('Overslaan'), findsOneWidget);
      await tester.tap(find.text('Overslaan'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 18: Test completed
      expect(true, isTrue, reason: 'Test completed successfully despite overflow');
    });
  });
}