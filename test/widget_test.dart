// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wildrapport/screens/login_screen.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/managers/navigation_state_manager.dart';
import 'package:wildrapport/interfaces/login_interface.dart';
import 'package:wildrapport/managers/login_manager.dart';
import 'package:wildrapport/interfaces/permission_interface.dart';
import 'package:wildrapport/managers/permission_manager.dart';
import 'package:wildrapport/widgets/brown_button.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/providers/possesion_damage_report_provider.dart';
import 'package:wildrapport/interfaces/api/auth_api_interface.dart';
import 'package:wildrapport/widgets/verification_code_input.dart';
import 'mocks.mocks.dart';  // Import the generated mocks
import './mocks/mock_app_config.dart';

void main() {
  setUp(() {
    // Setup mock AppConfig before each test
    MockAppConfig.setupMock();
  });

  group('Login Screen Tests', () {
    late SharedPreferences prefs;
    late LoginManager loginManager;
    late PermissionManager permissionManager;
    late MockAuthApiInterface mockAuthApi;
    late MockNavigationStateInterface mockNavigation;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      mockAuthApi = MockAuthApiInterface();
      mockNavigation = MockNavigationStateInterface();
      loginManager = LoginManager(mockAuthApi);
      permissionManager = PermissionManager(prefs);

      // Default mock behavior
      when(mockAuthApi.authenticate(any, any))
          .thenAnswer((_) async => {'status': 'success'});
    });

    Widget buildTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AppStateProvider>(
            create: (_) => AppStateProvider(),
          ),
          ChangeNotifierProvider<PossesionDamageFormProvider>(
            create: (_) => PossesionDamageFormProvider(),
          ),
          ChangeNotifierProvider<MapProvider>(
            create: (_) => MapProvider(),
          ),
          Provider<NavigationStateInterface>(
            create: (_) => mockNavigation,
          ),
          Provider<LoginInterface>(
            create: (_) => loginManager,
          ),
          Provider<PermissionInterface>(
            create: (_) => permissionManager,
          ),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      );
    }

    testWidgets('Login screen shows all initial components', 
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify basic UI elements
      expect(find.byType(TextField), findsOneWidget); // Email field
      expect(find.byType(BrownButton), findsOneWidget); // Login button
      expect(find.byType(VerificationCodeInput), findsNothing); // Verification should not be visible initially
    });

    testWidgets('Shows verification input after valid email submission', 
        (WidgetTester tester) async {
      // Create mocks
      final mockAuthApi = MockAuthApiInterface();
      final loginManager = LoginManager(mockAuthApi);
      final mockPermissionManager = MockPermissionInterface();

      // Setup mock behaviors
      when(mockAuthApi.authenticate(any, any))
          .thenAnswer((_) async => {'status': 'success'});
      when(mockPermissionManager.handleInitialPermissions(any))
          .thenAnswer((_) async => true);

      // Build test widget
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              Provider<LoginInterface>(
                create: (_) => loginManager,
              ),
              Provider<PermissionInterface>(
                create: (_) => mockPermissionManager,
              ),
            ],
            child: const LoginScreen(),
          ),
        ),
      );

      debugPrint('Before button press');

      // Enter email and tap login button
      await tester.enterText(
        find.byType(TextField), 
        'test@example.com'
      );
      await tester.pump();

      final loginButton = find.byType(BrownButton);
      await tester.tap(loginButton);
      debugPrint('After button press, before pump');
      
      // Wait for animations and state changes
      await tester.pump();
      debugPrint('After first pump');
      await tester.pumpAndSettle();
      debugPrint('After pumpAndSettle');

      // Verify verification widget is shown
      expect(
        find.byType(VerificationCodeInput), 
        findsOneWidget,
        reason: 'Verification input should be visible after login button press'
      );
    });

    testWidgets('Shows error on invalid email format', 
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      
      await tester.enterText(find.byType(TextField), 'invalid-email');
      await tester.pump();

      final loginButton = find.byType(BrownButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      verifyNever(mockAuthApi.authenticate(any, any));
      expect(find.byType(VerificationCodeInput), findsNothing);
      
      expect(
        find.text('Voer een geldig e-mailadres in'), 
        findsOneWidget,
        reason: 'Error message for invalid email should be visible'
      );
    });

    testWidgets('Handles API error gracefully', 
        (WidgetTester tester) async {
      // Setup API to return error
      when(mockAuthApi.authenticate(any, any))
          .thenThrow(Exception('Login failed: Exception: API Error'));

      await tester.pumpWidget(buildTestWidget());
      
      await tester.enterText(find.byType(TextField), 'test@example.com');
      await tester.pump();

      // Tap the login button
      await tester.tap(find.byType(BrownButton));
      
      // Wait for async operations
      await tester.pump(); // Process the tap
      await tester.pump(const Duration(milliseconds: 100)); // Wait for error state
      await tester.pumpAndSettle(); // Wait for any animations
      
      // Verify verification input is not shown
      expect(find.byType(VerificationCodeInput), findsNothing);
      
      // Check if either error message is present
      final hasLoginFailedError = find.textContaining('Login failed').evaluate().isNotEmpty;
      final hasApiError = find.textContaining('API Error').evaluate().isNotEmpty;
      
      expect(
        hasLoginFailedError || hasApiError,
        true,
        reason: 'Either "Login failed" or "API Error" message should be visible'
      );
    });
  });
}
