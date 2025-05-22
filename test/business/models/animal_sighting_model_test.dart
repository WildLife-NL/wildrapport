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

    test('should add animal to list', () {
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
      
      final newAnimal = AnimalModel(
        animalId: '2',
        animalName: 'Fox',
        animalImagePath: 'assets/fox.png',
        genderViewCounts: [],
      );
      
      // Act
      sightingModel.animals?.add(newAnimal);
      
      // Assert
      expect(sightingModel.animals?.length, 1);
      expect(sightingModel.animals?[0].animalId, '2');
      expect(sightingModel.animals?[0].animalName, 'Fox');
    });

    test('should update location correctly', () {
      // Arrange
      final sightingModel = AnimalSightingModel(
        animals: [],
        animalSelected: null,
      );
      
      final location = LocationModel(
        latitude: 52.3676,
        longitude: 4.9041,
        source: LocationSource.system,
      );
      
      // Act
      final updatedModel = sightingModel.copyWith(locations: [location]);
      
      // Assert
      expect(updatedModel.locations?.first, location);
      expect(updatedModel.locations?.first.latitude, 52.3676);
      expect(updatedModel.locations?.first.longitude, 4.9041);
      expect(updatedModel.locations?.first.source, LocationSource.system);
    });

    test('should update dateTime correctly', () {
      // Arrange
      final sightingModel = AnimalSightingModel(
        animals: [],
        animalSelected: null,
      );
      
      final dateTime = DateTimeModel(
        dateTime: DateTime(2023, 5, 15, 14, 30),
      );
      
      // Act
      final updatedModel = sightingModel.copyWith(dateTime: dateTime);
      
      // Assert
      expect(updatedModel.dateTime, dateTime);
      expect(updatedModel.dateTime?.dateTime?.year, 2023);
      expect(updatedModel.dateTime?.dateTime?.month, 5);
      expect(updatedModel.dateTime?.dateTime?.day, 15);
      expect(updatedModel.dateTime?.dateTime?.hour, 14);
      expect(updatedModel.dateTime?.dateTime?.minute, 30);
    });

    test('should update images correctly', () {
      // Arrange
      final sightingModel = AnimalSightingModel(
        animals: [],
        animalSelected: null,
      );
      
      final images = ImageListModel(
        imagePaths: ['image1.jpg', 'image2.jpg'],
      );
      
      // Act
      final updatedModel = sightingModel.copyWith(images: images);
      
      // Assert
      expect(updatedModel.images, images);
      expect(updatedModel.images?.imagePaths.length, 2);
      expect(updatedModel.images?.imagePaths[0], 'image1.jpg');
      expect(updatedModel.images?.imagePaths[1], 'image2.jpg');
    });

    test('should handle null values in toJson', () {
      // Arrange
      final sightingModel = AnimalSightingModel(
        animals: null,
        animalSelected: null,
      );
      
      // Act
      final json = sightingModel.toJson();
      
      // Assert
      expect(json, isA<Map<String, dynamic>>());
      expect(json['animals'], isNull);
      expect(json['category'], isNull);
      expect(json['description'], isNull);
      expect(json['locations'], isNull);
      expect(json['dateTime'], isNull);
      expect(json['images'], isNull);
    });

    test('should handle empty list in toJson', () {
      // Arrange
      final sightingModel = AnimalSightingModel(
        animals: [],
        animalSelected: null,
      );
      
      // Act
      final json = sightingModel.toJson();
      
      // Assert
      expect(json, isA<Map<String, dynamic>>());
      expect(json['animals'], isEmpty);
    });
  });
}






