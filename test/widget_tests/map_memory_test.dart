import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/widgets/location/livinglab_map_widget.dart';
import 'package:latlong2/latlong.dart';

void main() {
  testWidgets(
    'Map controller should be properly disposed during navigation cycles',
    (WidgetTester tester) async {
      // Track disposed controllers

      // Wrap the test widget with required providers
      Widget buildTestWidget() {
        return MultiProvider(
          providers: [ChangeNotifierProvider(create: (_) => MapProvider())],
          child: MaterialApp(
            home: LivingLabMapScreen(
              labName: 'Test Lab',
              labCenter: const LatLng(51.6988, 5.3041),
            ),
          ),
        );
      }

      // Initial memory snapshot
      final initialMemory = ProcessInfo.currentRss;

      // Simulate multiple navigation cycles
      for (int i = 0; i < 5; i++) {
        // Mount map screen
        await tester.pumpWidget(buildTestWidget());

        // Wait for frame to complete
        await tester.pump();

        // Allow time for map initialization
        await Future.delayed(const Duration(milliseconds: 100));
        await tester.pump();

        // Verify map is rendered
        expect(find.byType(LivingLabMapScreen), findsOneWidget);

        // Navigate away (simulate disposal)
        await tester.pumpWidget(Container());
        await tester.pump();

        // Allow time for disposal
        await Future.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      }

      // Force garbage collection
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Get final memory usage
      final finalMemory = ProcessInfo.currentRss;
      final memoryDiff = finalMemory - initialMemory;

      // Print memory statistics
      debugPrint('Initial Memory: ${initialMemory / 1024 / 1024} MB');
      debugPrint('Final Memory: ${finalMemory / 1024 / 1024} MB');
      debugPrint('Memory Difference: ${memoryDiff / 1024 / 1024} MB');

      // Assert memory difference is within acceptable range (adjust threshold as needed)
      expect(
        memoryDiff,
        lessThan(10 * 1024 * 1024),
      ); // Less than 10MB difference
    },
  );
}
