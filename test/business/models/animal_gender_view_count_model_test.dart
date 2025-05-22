import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_gender_view_count_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/view_count_model.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';

void main() {
  group('AnimalGenderViewCount', () {
    test('should have correct properties', () {
      // Arrange
      final viewCount = ViewCountModel(
        volwassenAmount: 2,
        onvolwassenAmount: 1,
        pasGeborenAmount: 0,
        unknownAmount: 0,
      );
      
      final genderViewCount = AnimalGenderViewCount(
        gender: AnimalGender.mannelijk,
        viewCount: viewCount,
      );
      
      // Assert
      expect(genderViewCount.gender, AnimalGender.mannelijk);
      expect(genderViewCount.viewCount, viewCount);
    });
    
    test('should convert to JSON correctly', () {
      // Arrange
      final viewCount = ViewCountModel(
        volwassenAmount: 2,
        onvolwassenAmount: 1,
        pasGeborenAmount: 0,
        unknownAmount: 0,
      );
      
      final genderViewCount = AnimalGenderViewCount(
        gender: AnimalGender.mannelijk,
        viewCount: viewCount,
      );
      
      // Act
      final json = genderViewCount.toJson();
      
      // Assert
      expect(json, isA<Map<String, dynamic>>());
      expect(json['gender'], AnimalGender.mannelijk.toString());
      expect(json['viewCount'], isA<Map<String, dynamic>>());
      expect(json['viewCount']['volwassenAmount'], 2);
      expect(json['viewCount']['onvolwassenAmount'], 1);
    });
    
    test('should create from JSON correctly', () {
      // Arrange
      final Map<String, dynamic> json = {
        'gender': 'AnimalGender.vrouwelijk',
        'viewCount': {
          'volwassenAmount': 3,
          'onvolwassenAmount': 2,
          'pasGeborenAmount': 1,
          'unknownAmount': 0,
        },
      };
      
      // Act
      final genderViewCount = AnimalGenderViewCount.fromJson(json);
      
      // Assert
      expect(genderViewCount.gender, AnimalGender.vrouwelijk);
      expect(genderViewCount.viewCount.volwassenAmount, 3);
      expect(genderViewCount.viewCount.onvolwassenAmount, 2);
      expect(genderViewCount.viewCount.pasGeborenAmount, 1);
      expect(genderViewCount.viewCount.unknownAmount, 0);
    });
    
    test('should handle unknown gender in fromJson', () {
      // Arrange
      final Map<String, dynamic> json = {
        'gender': 'AnimalGender.invalid',
        'viewCount': {
          'volwassenAmount': 1,
          'onvolwassenAmount': 0,
          'pasGeborenAmount': 0,
          'unknownAmount': 0,
        },
      };
      
      // Act
      final genderViewCount = AnimalGenderViewCount.fromJson(json);
      
      // Assert
      expect(genderViewCount.gender, AnimalGender.onbekend); // Should default to unknown
    });
  });
}