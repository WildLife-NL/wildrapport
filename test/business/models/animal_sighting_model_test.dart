import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_sighting_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_model.dart';
import 'package:wildrapport/models/enums/animal_category.dart';
import 'package:wildrapport/models/beta_models/location_model.dart';
import 'package:wildrapport/models/ui_models/image_list_model.dart';
import 'package:wildrapport/models/ui_models/date_time_model.dart';
import 'package:wildrapport/models/enums/location_source.dart';

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

    test('should update description', () {
      // Arrange
      final sightingModel = AnimalSightingModel(
        animals: [],
        description: 'Initial description',
      );
      
      // Act
      final updatedModel = sightingModel.copyWith(description: 'Updated description');
      
      // Assert
      expect(updatedModel.description, 'Updated description');
    });

    test('should update locations', () {
      // Arrange
      final sightingModel = AnimalSightingModel(
        animals: [],
        locations: [],
      );
      
      final newLocations = [
        LocationModel(
          latitude: 52.3676,
          longitude: 4.9041,
          source: LocationSource.system,
        )
      ];
      
      // Act
      final updatedModel = sightingModel.copyWith(locations: newLocations);
      
      // Assert
      expect(updatedModel.locations, newLocations);
    });

    test('should update dateTime', () {
      // Arrange
      final sightingModel = AnimalSightingModel(
        animals: [],
      );
      
      final dateTime = DateTimeModel(
        dateTime: DateTime.now(),
      );
      
      // Act
      final updatedModel = sightingModel.copyWith(dateTime: dateTime);
      
      // Assert
      expect(updatedModel.dateTime, dateTime);
    });

    test('should update images', () {
      // Arrange
      final sightingModel = AnimalSightingModel(
        animals: [],
      );
      
      final images = ImageListModel(
        imagePaths: ['path/to/image1.jpg', 'path/to/image2.jpg'],
      );
      
      // Act
      final updatedModel = sightingModel.copyWith(images: images);
      
      // Assert
      expect(updatedModel.images, images);
    });

    test('should convert to JSON correctly', () {
      // Arrange
      final animalModel = AnimalModel(
        animalId: '1',
        animalName: 'Wolf',
        animalImagePath: 'assets/wolf.png',
        genderViewCounts: [],
      );
      
      final sightingModel = AnimalSightingModel(
        animals: [animalModel],
        animalSelected: animalModel,
        category: AnimalCategory.roofdieren,
        description: 'Test description',
      );
      
      // Act
      final json = sightingModel.toJson();
      
      // Assert
      expect(json, isA<Map<String, dynamic>>());
      expect(json['category'], AnimalCategory.roofdieren.toString());
      expect(json['description'], 'Test description');
      expect(json['animals'], isA<List>());
      expect(json['animals']?.length, 1);
      expect(json['animals']?[0]['animalId'], '1');
      expect(json['animals']?[0]['animalName'], 'Wolf');
    });

    test('should create from JSON correctly', () {
      // Arrange
      final Map<String, dynamic> json = {
        'animals': [
          {
            'animalId': '1',
            'animalName': 'Wolf',
            'animalImagePath': 'assets/wolf.png',
            'genderViewCounts': [],
          }
        ],
        'category': 'AnimalCategory.roofdieren',
        'description': 'Test description',
      };
      
      // Act
      final sightingModel = AnimalSightingModel.fromJson(json);
      
      // Assert
      expect(sightingModel.animals?.length, 1);
      expect(sightingModel.animals?[0].animalId, '1');
      expect(sightingModel.animals?[0].animalName, 'Wolf');
      expect(sightingModel.category, AnimalCategory.roofdieren);
      expect(sightingModel.description, 'Test description');
    });
  });
}




