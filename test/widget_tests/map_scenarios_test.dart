import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/managers/navigation_state_manager.dart';
import 'package:wildrapport/widgets/location/livinglab_map_widget.dart';
import '../helpers/memory_test_helper.dart';

void main() {
  group('Map Memory Tests', () {
    testWidgets('Normal navigation flow memory test', (
      WidgetTester tester,
    ) async {
      final memoryDiff = await MemoryTestHelper.measureMemoryUsage(
        tester: tester,
        cycles: 5,
        testName: 'Normal Navigation',
        buildWidget:
            () => MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => MapProvider()),
                Provider<NavigationStateInterface>(
                  create: (_) => NavigationStateManager(),
                ),
              ],
              child: MaterialApp(
                home: LivingLabMapScreen(
                  labName: 'Test Lab',
                  labCenter: const LatLng(51.6988, 5.3041),
                ),
              ),
            ),
      );

      expect(memoryDiff, lessThan(10 * 1024 * 1024));
    });

    testWidgets('Rapid navigation memory test', (WidgetTester tester) async {
      final memoryDiff = await MemoryTestHelper.measureMemoryUsage(
        tester: tester,
        cycles: 20, // More cycles for stress testing
        testName: 'Rapid Navigation',
        buildWidget:
            () => MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => MapProvider()),
                Provider<NavigationStateInterface>(
                  create: (_) => NavigationStateManager(),
                ),
              ],
              child: MaterialApp(
                home: LivingLabMapScreen(
                  labName: 'Test Lab',
                  labCenter: const LatLng(51.6988, 5.3041),
                ),
              ),
            ),
      );

      expect(memoryDiff, lessThan(15 * 1024 * 1024));
    });
  });
}
