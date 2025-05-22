import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../mock_generator.mocks.dart';

void main() {
  late MockPossesion mockPossesion;

  setUp(() {
    mockPossesion = MockPossesion();
    
    // Setup default behavior
    when(mockPossesion.possesionID).thenReturn('possesion-1');
    when(mockPossesion.possesionName).thenReturn('Test Possesion');
    when(mockPossesion.category).thenReturn('crop');
  });

  group('Possesion Model Tests', () {
    test('should have correct properties', () {
      // Verify the properties
      expect(mockPossesion.possesionID, 'possesion-1');
      expect(mockPossesion.possesionName, 'Test Possesion');
      expect(mockPossesion.category, 'crop');
    });

    test('toJson should return correct map', () {
      // Setup mock behavior for toJson
      when(mockPossesion.toJson()).thenReturn({
        'ID': 'possesion-1',
        'name': 'Test Possesion',
        'category': 'crop',
      });
      
      // Verify
      final json = mockPossesion.toJson();
      expect(json['ID'], 'possesion-1');
      expect(json['name'], 'Test Possesion');
      expect(json['category'], 'crop');
    });
  });
}


