import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_sighting_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_model.dart';
import 'package:wildrapport/models/enums/animal_category.dart';

void main() {
  group('AnimalSightingModel', () {
    
    test('should have correct properties', () {
      // Arrange
      final animalModel = AnimalModel(
        animalId: '1',
        animalName: 'Wolf',
        animalImagePath: 'assets/wolf.png',
        genderViewCounts: [],
      );
      
      final sightingModel = AnimalSightingModel(
        animals: [],
        animalSelected: animalModel,
      );
      
      // Assert
      expect(sightingModel.animalSelected, animalModel);
      expect(sightingModel.animals, isEmpty);
      expect(sightingModel.category, null); // Category is null by default
    });
    
    test('should update category', () {
      // Arrange
      final animalModel = AnimalModel(
        animalId: '1',
        animalName: 'Wolf',
        animalImagePath: 'assets/wolf.png',
        genderViewCounts: [],
      );
      
      final sightingModel = AnimalSightingModel(
        animals: [],
        animalSelected: animalModel,
      );
      
      // Act
      final updatedModel = sightingModel.copyWith(category: AnimalCategory.roofdieren);
      
      // Assert
      expect(updatedModel.category, AnimalCategory.roofdieren);
    });
  });
}


