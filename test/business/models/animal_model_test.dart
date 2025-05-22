import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_gender_view_count_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/view_count_model.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';

void main() {
  group('AnimalModel', () {
    
    setUp(() {
    });
    
    test('should have correct properties', () {
      // Arrange
      final animalModel = AnimalModel(
        animalId: '1',
        animalName: 'Wolf',
        animalImagePath: 'assets/wolf.png',
        genderViewCounts: [],
      );
      
      // Assert
      expect(animalModel.animalId, '1');
      expect(animalModel.animalName, 'Wolf');
      expect(animalModel.animalImagePath, 'assets/wolf.png');
      expect(animalModel.genderViewCounts, isEmpty);
    });
    
    test('should add gender view count', () {
      // Arrange
      final animalModel = AnimalModel(
        animalId: '1',
        animalName: 'Wolf',
        animalImagePath: 'assets/wolf.png',
        genderViewCounts: [],
      );
      
      final genderViewCount = AnimalGenderViewCount(
        gender: AnimalGender.mannelijk,
        viewCount: ViewCountModel(
          volwassenAmount: 1,
          onvolwassenAmount: 0,
          pasGeborenAmount: 0,
          unknownAmount: 0,
        ),
      );
      
      // Act
      animalModel.genderViewCounts.add(genderViewCount);
      
      // Assert
      expect(animalModel.genderViewCounts.length, 1);
      expect(animalModel.genderViewCounts.first.gender, AnimalGender.mannelijk);
    });
  });
}