import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/other/login_interface.dart';
import 'package:wildrapport/interfaces/other/permission_interface.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/screens/login/login_screen.dart';
import '../mock_generator.mocks.dart';

void main() {
  late MockLoginInterface mockLoginInterface;
  late MockPermissionInterface mockPermissionInterface;
  late MockAppStateProvider mockAppStateProvider;

  setUpAll(() async {
    // ✅ Load environment variables for widget tests
    await dotenv.load(fileName: ".env");
  });

  setUp(() {
    mockLoginInterface = MockLoginInterface();
    mockPermissionInterface = MockPermissionInterface();
    mockAppStateProvider = MockAppStateProvider();

    // Add stub for isPermissionGranted method
    when(
      mockPermissionInterface.isPermissionGranted(any),
    ).thenAnswer((_) async => true);

    // Setup necessary methods on the AppStateProvider mock
    when(mockAppStateProvider.updateLocationCache()).thenAnswer((_) async {});
    when(mockAppStateProvider.startLocationUpdates()).thenReturn(null);
    when(
      mockAppStateProvider.getScreenState<dynamic>(any, any),
    ).thenReturn(null);
    when(mockAppStateProvider.setScreenState(any, any, any)).thenReturn(null);
  });

  Widget createLoginScreen() {
    return MultiProvider(
      providers: [
        Provider<LoginInterface>.value(value: mockLoginInterface),
        Provider<PermissionInterface>.value(value: mockPermissionInterface),
        ChangeNotifierProvider<AppStateProvider>.value(
          value: mockAppStateProvider,
        ),
      ],
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  testWidgets('should render login form', (WidgetTester tester) async {
    await tester.pumpWidget(createLoginScreen());

    // Verify email field and login button are rendered
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Aanmelden'), findsOneWidget);
  });

  testWidgets('should validate email and show error for invalid email', (
    WidgetTester tester,
  ) async {
    when(
      mockLoginInterface.validateEmail(any),
    ).thenReturn('Ongeldig e-mailadres');

    await tester.pumpWidget(createLoginScreen());

    // Enter invalid email and tap login button
    await tester.enterText(find.byType(TextField), 'invalid-email');
    await tester.tap(find.text('Aanmelden'));
    await tester.pump();
    await tester.pumpAndSettle(); // Wait for dialog

    // Verify error dialog is shown
    expect(find.text('Ongeldig e-mailadres'), findsOneWidget);
  });
}
