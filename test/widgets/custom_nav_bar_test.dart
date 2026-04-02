import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/models/enums/nav_tab.dart';
import 'package:wildrapport/widgets/navigation/custom_nav_bar.dart';

void main() {
  Widget _wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      ),
    );
  }

  group('CustomNavBar', () {
    testWidgets('renders all navigation labels', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CustomNavBar(
            currentTab: NavTab.kaart,
            onTabSelected: (_) {},
          ),
        ),
      );

      expect(find.text("Zone's"), findsOneWidget);
      expect(find.text('Rapporten'), findsOneWidget);
      expect(find.text('Kaart'), findsOneWidget);
      expect(find.text('LogBoek'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('calls callback when side tab tapped', (tester) async {
      NavTab? selected;

      await tester.pumpWidget(
        _wrap(
          CustomNavBar(
            currentTab: NavTab.kaart,
            onTabSelected: (tab) => selected = tab,
          ),
        ),
      );

      await tester.tap(find.text('Rapporten'));
      await tester.pump();

      expect(selected, NavTab.rapporten);
    });

    testWidgets('calls callback when center button tapped', (tester) async {
      NavTab? selected;

      await tester.pumpWidget(
        _wrap(
          CustomNavBar(
            currentTab: NavTab.zones,
            onTabSelected: (tab) => selected = tab,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.map));
      await tester.pump();

      expect(selected, NavTab.kaart);
    });
  });

  group('NavBarCurvePainter', () {
    test('shouldRepaint reacts to meaningful changes', () {
      const a = NavBarCurvePainter(
        backgroundColor: Colors.white,
        bumpRadius: 30,
        bumpShoulder: 13,
      );
      const b = NavBarCurvePainter(
        backgroundColor: Colors.white,
        bumpRadius: 30,
        bumpShoulder: 13,
      );
      const c = NavBarCurvePainter(
        backgroundColor: Colors.green,
        bumpRadius: 30,
        bumpShoulder: 13,
      );

      expect(a.shouldRepaint(b), isFalse);
      expect(a.shouldRepaint(c), isTrue);
    });
  });
}
