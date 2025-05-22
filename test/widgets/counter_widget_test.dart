import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/widgets/animals/counter_widget.dart';

void main() {
  group('CounterWidget Tests', () {
    testWidgets('should display initial count', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CounterWidget(
            count: 5,
            onIncrement: (_) {},
            onDecrement: (_) {},
          ),
        ),
      ));
      
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('should call onIncrement when + button is pressed', (WidgetTester tester) async {
      int newCount = 0;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CounterWidget(
            count: 5,
            onIncrement: (count) => newCount = count,
            onDecrement: (_) {},
          ),
        ),
      ));
      
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      
      expect(newCount, 6);
    });

    testWidgets('should call onDecrement when - button is pressed', (WidgetTester tester) async {
      int newCount = 0;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CounterWidget(
            count: 5,
            onIncrement: (_) {},
            onDecrement: (count) => newCount = count,
          ),
        ),
      ));
      
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      
      expect(newCount, 4);
    });

    testWidgets('should not allow decrement below 0', (WidgetTester tester) async {
      int newCount = -1;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CounterWidget(
            count: 0,
            onIncrement: (_) {},
            onDecrement: (count) => newCount = count,
          ),
        ),
      ));
      
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      
      // Should still be 0, not -1
      expect(newCount, 0);
    });
  });
}