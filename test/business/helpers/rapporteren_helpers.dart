import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_sighting_model.dart';
import 'package:wildrapport/models/api_models/interaction_type.dart';
import 'package:wildrapport/managers/api_managers/interaction_types_manager.dart';
import '../mock_generator.mocks.dart';

class MockInteractionTypesManager extends Mock
  implements InteractionTypesManager {}

class RapporterenHelpers {
  static Future<void> setupEnvironment() async {
    // Initialize any environment setup needed for tests
    WidgetsFlutterBinding.ensureInitialized();
  }

  static MockNavigationStateInterface getMockNavigationManager() {
    final mockNavigationManager = MockNavigationStateInterface();
    return mockNavigationManager;
  }

  static MockAnimalSightingReportingInterface getMockAnimalSightingManager() {
    final mockAnimalSightingManager = MockAnimalSightingReportingInterface();
    when(mockAnimalSightingManager.createanimalSighting()).thenReturn(AnimalSightingModel());
    when(mockAnimalSightingManager.getCurrentanimalSighting()).thenReturn(null);
    return mockAnimalSightingManager;
  }

  static MockMapProvider getMockMapProvider() {
    final mockMapProvider = MockMapProvider();

    // Important: Configure all properties and methods used in the Rapporteren screen
    when(mockMapProvider.isInitialized).thenReturn(false);
    when(mockMapProvider.initialize()).thenAnswer((_) => Future.value());

    return mockMapProvider;
  }

  static MockInteractionTypesManager getMockInteractionTypesManager() {
    final mockInteractionTypesManager = MockInteractionTypesManager();

    final mockTypes = [
      InteractionType(id: 1, name: 'Waarneming', description: 'Animal sighting'),
      InteractionType(id: 2, name: 'Gewasschade', description: 'Crop damage'),
      InteractionType(id: 3, name: 'Diergezondheid', description: 'Animal health'),
      InteractionType(id: 4, name: 'Verkeersongeval', description: 'Traffic accident'),
    ];

    when(mockInteractionTypesManager.ensureFetched()).thenAnswer((_) async => mockTypes);
    return mockInteractionTypesManager;
  }

  static void setupSuccessfulNavigation(
    MockNavigationStateInterface mockNavigationManager,
  ) {
    when(
      mockNavigationManager.pushForward(any, any),
    ).thenAnswer((_) => Future.value(true));
    when(
      mockNavigationManager.pushReplacementForward(any, any),
    ).thenAnswer((_) => Future.value(true));
    when(
      mockNavigationManager.pushAndRemoveUntil(any, any),
    ).thenAnswer((_) => Future.value(true));
  }

  static void setupFailedNavigation(
    MockNavigationStateInterface mockNavigationManager,
  ) {
    when(
      mockNavigationManager.pushForward(any, any),
    ).thenThrow(Exception('Navigation error'));
    when(
      mockNavigationManager.pushReplacementForward(any, any),
    ).thenThrow(Exception('Navigation error'));
    when(
      mockNavigationManager.pushAndRemoveUntil(any, any),
    ).thenThrow(Exception('Navigation error'));
  }
}
