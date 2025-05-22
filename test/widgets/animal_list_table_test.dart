import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_gender_view_count_model.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/animal_waarneming_models/view_count_model.dart';
import 'package:wildrapport/widgets/animals/animal_list_table.dart';

void main() {
  final AnimalModel testAnimal = AnimalModel(
    animalId: '1',
    animalName: 'Wolf',
    animalImagePath: 'assets/wolf.png',
    genderViewCounts: [
      AnimalGenderViewCount(
        gender: AnimalGender.mannelijk,
        viewCount: ViewCountModel(
          volwassenAmount: 2,
          onvolwassenAmount: 1,
          pasGeborenAmount: 0,
          unknownAmount: 0,
        ),
      ),
      AnimalGenderViewCount(
        gender: AnimalGender.vrouwelijk,
        viewCount: ViewCountModel(
          volwassenAmount: 1,
          onvolwassenAmount: 0,
          pasGeborenAmount: 0,
          unknownAmount: 0,
        ),
      ),
    ],
  );

  group('AnimalListTable Widget Tests', () {
    testWidgets('should display animal name', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnimalListTable(
            animals: [testAnimal],
            onRemove: (_) {},
          ),
        ),
      ));
      
      expect(find.text('Wolf'), findsOneWidget);
    });

    testWidgets('should display correct count totals', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnimalListTable(
            animals: [testAnimal],
            onRemove: (_) {},
          ),
        ),
      ));
      
      // Total count should be 2 + 1 + 1 = 4
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('should call onRemove when delete button is pressed', (WidgetTester tester) async {
      AnimalModel? removedAnimal;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnimalListTable(
            animals: [testAnimal],
            onRemove: (animal) => removedAnimal = animal,
          ),
        ),
      ));
      
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();
      
      expect(removedAnimal, equals(testAnimal));
    });

    testWidgets('should handle empty animal list', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnimalListTable(
            animals: [],
            onRemove: (_) {},
          ),
        ),
      ));
      
      // Table should be empty but not crash
      expect(find.byType(Table), findsOneWidget);
      expect(find.byType(TableRow), findsNothing);
    });
  });
}