import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wildrapport/models/animal_waarneming_models/view_count_model.dart';
import '../mock_generator.mocks.dart';

void main() {
  group('ViewCountModel', () {
    test('should have correct properties', () {
      // Arrange
      final viewCount = ViewCountModel(
        volwassenAmount: 2,
        onvolwassenAmount: 1,
        pasGeborenAmount: 3,
        unknownAmount: 0,
      );
      
      // Assert
      expect(viewCount.volwassenAmount, 2);
      expect(viewCount.onvolwassenAmount, 1);
      expect(viewCount.pasGeborenAmount, 3);
      expect(viewCount.unknownAmount, 0);
    });
    
    test('should calculate total correctly', () {
      // Arrange
      final viewCount = ViewCountModel(
        volwassenAmount: 2,
        onvolwassenAmount: 1,
        pasGeborenAmount: 3,
        unknownAmount: 4,
      );
      
      // Assert
      expect(viewCount.volwassenAmount + viewCount.onvolwassenAmount + viewCount.pasGeborenAmount + viewCount.unknownAmount, 10);
    });
    
    test('should convert to JSON correctly', () {
      // Arrange
      final viewCount = ViewCountModel(
        volwassenAmount: 2,
        onvolwassenAmount: 1,
        pasGeborenAmount: 3,
        unknownAmount: 4,
      );
      
      // Act
      final json = viewCount.toJson();
      
      // Assert
      expect(json, isA<Map<String, dynamic>>());
      expect(json['volwassenAmount'], 2);
      expect(json['onvolwassenAmount'], 1);
      expect(json['pasGeborenAmount'], 3);
      expect(json['unknownAmount'], 4);
    });
    
    test('should create from JSON correctly', () {
      // Arrange
      final Map<String, dynamic> json = {
        'volwassenAmount': 5,
        'onvolwassenAmount': 3,
        'pasGeborenAmount': 2,
        'unknownAmount': 1,
      };
      
      // Act
      final viewCount = ViewCountModel.fromJson(json);
      
      // Assert
      expect(viewCount.volwassenAmount, 5);
      expect(viewCount.onvolwassenAmount, 3);
      expect(viewCount.pasGeborenAmount, 2);
      expect(viewCount.unknownAmount, 1);
      
      // Calculate total manually
      final total = viewCount.volwassenAmount + viewCount.onvolwassenAmount + 
                    viewCount.pasGeborenAmount + viewCount.unknownAmount;
      expect(total, 11);
    });
    
    test('should handle missing values in JSON', () {
      // Arrange
      final Map<String, dynamic> json = {
        'volwassenAmount': 5,
        // Missing other fields
      };
      
      // Act
      final viewCount = ViewCountModel.fromJson(json);
      
      // Assert
      expect(viewCount.volwassenAmount, 5);
      expect(viewCount.onvolwassenAmount, 0); // Should default to 0
      expect(viewCount.pasGeborenAmount, 0); // Should default to 0
      expect(viewCount.unknownAmount, 0); // Should default to 0
    });
    
    test('should work with mocks', () {
      // Arrange
      final mockViewCount = MockViewCountModel();
      
      // Setup mock behavior
      when(mockViewCount.volwassenAmount).thenReturn(2);
      when(mockViewCount.onvolwassenAmount).thenReturn(1);
      when(mockViewCount.pasGeborenAmount).thenReturn(3);
      when(mockViewCount.unknownAmount).thenReturn(4);
      
      // Act & Assert
      expect(mockViewCount.volwassenAmount, 2);
      expect(mockViewCount.onvolwassenAmount, 1);
      expect(mockViewCount.pasGeborenAmount, 3);
      expect(mockViewCount.unknownAmount, 4);
      
      // Verify the mock was called
      verify(mockViewCount.volwassenAmount).called(1);
      verify(mockViewCount.onvolwassenAmount).called(1);
      verify(mockViewCount.pasGeborenAmount).called(1);
      verify(mockViewCount.unknownAmount).called(1);
    });

    test('should initialize with default values', () {
      // Arrange & Act
      final viewCount = ViewCountModel();
      
      // Assert
      expect(viewCount.volwassenAmount, 0);
      expect(viewCount.onvolwassenAmount, 0);
      expect(viewCount.pasGeborenAmount, 0);
      expect(viewCount.unknownAmount, 0);
    });

    test('should handle null values in fromJson', () {
      // Arrange
      final Map<String, dynamic> json = {
        'volwassenAmount': null,
        'onvolwassenAmount': 3,
        'pasGeborenAmount': null,
        'unknownAmount': 1,
      };
      
      // Act
      final viewCount = ViewCountModel.fromJson(json);
      
      // Assert
      expect(viewCount.volwassenAmount, 0); // Should default to 0
      expect(viewCount.onvolwassenAmount, 3);
      expect(viewCount.pasGeborenAmount, 0); // Should default to 0
      expect(viewCount.unknownAmount, 1);
    });

    test('should handle missing keys in fromJson', () {
      // Arrange
      final Map<String, dynamic> json = {
        'volwassenAmount': 5,
        // Missing onvolwassenAmount
        'pasGeborenAmount': 2,
        // Missing unknownAmount
      };
      
      // Act
      final viewCount = ViewCountModel.fromJson(json);
      
      // Assert
      expect(viewCount.volwassenAmount, 5);
      expect(viewCount.onvolwassenAmount, 0); // Should default to 0
      expect(viewCount.pasGeborenAmount, 2);
      expect(viewCount.unknownAmount, 0); // Should default to 0
    });

    test('should handle negative values', () {
      // Arrange
      final viewCount = ViewCountModel(
        volwassenAmount: -1,
        onvolwassenAmount: -2,
        pasGeborenAmount: -3,
        unknownAmount: -4,
      );
      
      // Assert
      expect(viewCount.volwassenAmount, -1);
      expect(viewCount.onvolwassenAmount, -2);
      expect(viewCount.pasGeborenAmount, -3);
      expect(viewCount.unknownAmount, -4);
      
      // Calculate total with negative values
      final total = viewCount.volwassenAmount + viewCount.onvolwassenAmount + 
                    viewCount.pasGeborenAmount + viewCount.unknownAmount;
      expect(total, -10);
    });
    
    test('should handle large values', () {
      // Arrange
      final viewCount = ViewCountModel(
        volwassenAmount: 999999,
        onvolwassenAmount: 888888,
        pasGeborenAmount: 777777,
        unknownAmount: 666666,
      );
      
      // Act
      final json = viewCount.toJson();
      
      // Assert
      expect(json['volwassenAmount'], 999999);
      expect(json['onvolwassenAmount'], 888888);
      expect(json['pasGeborenAmount'], 777777);
      expect(json['unknownAmount'], 666666);
      
      // Recreate from JSON and verify
      final recreated = ViewCountModel.fromJson(json);
      expect(recreated.volwassenAmount, 999999);
      expect(recreated.onvolwassenAmount, 888888);
      expect(recreated.pasGeborenAmount, 777777);
      expect(recreated.unknownAmount, 666666);
    });
    
    test('should handle empty JSON', () {
      // Arrange
      final Map<String, dynamic> json = {};
      
      // Act
      final viewCount = ViewCountModel.fromJson(json);
      
      // Assert
      expect(viewCount.volwassenAmount, 0);
      expect(viewCount.onvolwassenAmount, 0);
      expect(viewCount.pasGeborenAmount, 0);
      expect(viewCount.unknownAmount, 0);
    });
  });
}



