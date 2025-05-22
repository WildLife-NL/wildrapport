import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/widgets/overlay/error_overlay.dart';

void main() {
  group('ErrorOverlay Widget Tests', () {
    testWidgets('should display error message', (WidgetTester tester) async {
      const errorMessage = 'Test error message';
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ErrorOverlay(
            errorMessage: errorMessage,
            onRetry: null,
          ),
        ),
      ));
      
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('should show retry button when onRetry is provided', (WidgetTester tester) async {
      bool retryPressed = false;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ErrorOverlay(
            errorMessage: 'Error',
            onRetry: () => retryPressed = true,
          ),
        ),
      ));
      
      expect(find.byType(ElevatedButton), findsOneWidget);
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(retryPressed, true);
    });

    testWidgets('should not show retry button when onRetry is null', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ErrorOverlay(
            errorMessage: 'Error',
            onRetry: null,
          ),
        ),
      ));
      
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}