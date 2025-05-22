import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wildrapport/interfaces/reporting/interaction_interface.dart';
import 'package:wildrapport/models/beta_models/interaction_model.dart';
import 'package:wildrapport/models/enums/interaction_type.dart';
import '../mock_generator.mocks.dart';
import '../helpers/interaction_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late InteractionInterface interactionManager;
  late MockInteractionApiInterface mockInteractionApi;
  late MockConnectivity mockConnectivity;
  late MockReportable mockReport;

  setUp(() async {
    // Setup environment
    await InteractionHelpers.setupEnvironment();

    // Initialize mocks
    mockInteractionApi = InteractionHelpers.getMockInteractionApi();
    mockConnectivity = MockConnectivity();
    mockReport = InteractionHelpers.getMockReportable();

    // Setup connectivity mock using the helper methods
    InteractionHelpers.setupOnlineConnectivity(mockConnectivity);

    // Create the manager with mocked dependencies
    interactionManager = InteractionHelpers.getInteractionManager(
      interactionApi: mockInteractionApi,
      connectivity: mockConnectivity,
    );
  });

  group('InteractionManager', () {
    test('should post interaction successfully when online', () async {
      // Arrange
      InteractionHelpers.setupSuccessfulInteractionResponse(mockInteractionApi);
      InteractionHelpers.setupOnlineConnectivity(mockConnectivity);

      // Act
      final result = await interactionManager.postInteraction(
        mockReport,
        InteractionType.waarneming,
      );

      // Assert
      expect(result, isNotNull);
      expect(result!.interactionID, equals('int-123'));
      verify(mockInteractionApi.sendInteraction(any)).called(1);
    });

    test('should throw exception when user is not logged in', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      InteractionHelpers.setupOnlineConnectivity(mockConnectivity);
      
      // Act & Assert
      expect(
        () => interactionManager.postInteraction(
          mockReport,
          InteractionType.waarneming,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains("User Profile Wasn't Loaded"),
        )),
      );
      
      verifyNever(mockInteractionApi.sendInteraction(any));
    });

    test('should cache interaction when offline', () async {
      // Arrange
      InteractionHelpers.setupOfflineConnectivity(mockConnectivity);
      
      // Act
      final result = await interactionManager.postInteraction(
        mockReport,
        InteractionType.waarneming,
      );
      
      // Assert
      expect(result, isNull);
      verifyNever(mockInteractionApi.sendInteraction(any));
    });

    test('should handle API errors gracefully', () async {
      // Arrange
      InteractionHelpers.setupFailedInteractionResponse(mockInteractionApi);
      InteractionHelpers.setupOnlineConnectivity(mockConnectivity);
      
      // Act & Assert
      expect(
        () => interactionManager.postInteraction(
          mockReport,
          InteractionType.waarneming,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should create correct interaction object', () async {
      // Arrange
      InteractionHelpers.setupSuccessfulInteractionResponse(mockInteractionApi);
      InteractionHelpers.setupOnlineConnectivity(mockConnectivity);
      
      // Act
      await interactionManager.postInteraction(
        mockReport,
        InteractionType.waarneming,
      );
      
      // Assert - Verify the interaction was created correctly
      verify(mockInteractionApi.sendInteraction(
        argThat(
          predicate<Interaction>((interaction) =>
            interaction.interactionType == InteractionType.waarneming &&
            interaction.userID == 'test-user-123' &&
            interaction.report == mockReport
          ),
        ),
      )).called(1);
    });
  });
}







