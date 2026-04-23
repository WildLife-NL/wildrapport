import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_gender_view_count_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_sighting_model.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/enums/report_type.dart';
import 'package:wildrapport/models/animal_waarneming_models/view_count_model.dart';

import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/screens/waarneming/animal_counting_screen.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/bottom_app_bar.dart';
import '../mock_generator.mocks.dart';

void main() {
  late MockNavigationStateInterface mockNavigationManager;
  late MockAnimalSightingReportingInterface mockAnimalSightingManager;
  late MockAppStateProvider mockAppStateProvider;

  setUp(() {
    // Initialize mocks
    mockNavigationManager = MockNavigationStateInterface();
    mockAnimalSightingManager = MockAnimalSightingReportingInterface();
    mockAppStateProvider = MockAppStateProvider();

    // Reset interactions
    reset(mockNavigationManager);
    reset(mockAnimalSightingManager);
    reset(mockAppStateProvider);

    // Setup test data
    when(
      mockAppStateProvider.currentReportType,
    ).thenReturn(ReportType.waarneming);

    // Setup animal sighting data
    final testAnimalSighting = AnimalSightingModel(
      animals: [],
      animalSelected: AnimalModel(
        animalId: '1',
        animalName: 'Wolf',
        animalImagePath: 'assets/wolf.png',
        genderViewCounts: [],
      ),
    );

    when(
      mockAnimalSightingManager.getCurrentanimalSighting(),
    ).thenReturn(testAnimalSighting);

    // Setup navigation
    when(
      mockNavigationManager.pushForward(any, any),
    ).thenAnswer((_) => Future.value(true));
    when(
      mockNavigationManager.pushReplacementForward(any, any),
    ).thenAnswer((_) => Future.value(true));
  });

  Widget createAnimalCountingScreen() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<NavigationStateInterface>.value(
            value: mockNavigationManager,
          ),
          Provider<AnimalSightingReportingInterface>.value(
            value: mockAnimalSightingManager,
          ),
          ChangeNotifierProvider<AppStateProvider>.value(
            value: mockAppStateProvider,
          ),
        ],
        child: const Scaffold(body: AnimalCountingScreen()),
      ),
    );
  }

  group('AnimalCountingScreen UI Tests', () {
    testWidgets('renders screen title and bottom navigation', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      // Act
      await tester.pumpWidget(createAnimalCountingScreen());
      await tester.pumpAndSettle();

      // Assert - current screen layout
      expect(find.text('Hoeveel van deze dieren heb je gezien?'), findsOneWidget);
      expect(find.text('Vorige'), findsWidgets);
      expect(find.text('Volgende'), findsWidgets);

      // Cleanup
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('next button in bottom app bar is hidden by default', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createAnimalCountingScreen());
      await tester.pumpAndSettle();

      // Assert - only inner widget has "Volgende" by default
      expect(find.text('Volgende'), findsOneWidget);

      // Cleanup
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('default layout does not show add-to-list button', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createAnimalCountingScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Voeg toe aan de lijst'), findsNothing);

      // Cleanup
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('navigation occurs when adding animal to list', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      // Create a GenderViewCount with a non-zero count to trigger _hasAddedItems
      final genderViewCount = AnimalGenderViewCount(
        gender: AnimalGender.mannelijk,
        viewCount: ViewCountModel(
          volwassenAmount: 1, // Set a non-zero count
          onvolwassenAmount: 0,
          pasGeborenAmount: 0,
          unknownAmount: 0,
        ),
      );

      // Create an animal with the gender view count
      final animalWithCount = AnimalModel(
        animalId: '1',
        animalName: 'Wolf',
        animalImagePath: 'assets/wolf.png',
        genderViewCounts: [genderViewCount],
      );

      // Mock that an animal has been added to the list with counts
      when(mockAnimalSightingManager.getCurrentanimalSighting()).thenReturn(
        AnimalSightingModel(
          animals: [animalWithCount],
          animalSelected: animalWithCount,
        ),
      );

      // Act
      await tester.pumpWidget(createAnimalCountingScreen());
      await tester.pumpAndSettle();

      // The next button should now also be visible in the CustomBottomAppBar
      // so there are two "Volgende" labels.
      expect(find.text('Volgende'), findsNWidgets(2));

      // Tap the next button by finding the row containing "Volgende"
      final nextInBottomBar = find.descendant(
        of: find.byType(CustomBottomAppBar),
        matching: find.text('Volgende'),
      );
      await tester.tap(nextInBottomBar);
      await tester.pumpAndSettle();

      // Verify navigation was called
      verify(mockNavigationManager.pushReplacementForward(any, any)).called(1);

      // Cleanup
      addTearDown(() => tester.view.resetPhysicalSize());
    });
  });
}
