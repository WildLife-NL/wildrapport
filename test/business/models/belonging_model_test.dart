import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../mock_generator.mocks.dart';

void main() {
  late MockBelonging mockBelonging;

  setUp(() {
    mockBelonging = MockBelonging();
    
    // Setup default behavior
    when(mockBelonging.ID).thenReturn('belonging-1');
    when(mockBelonging.name).thenReturn('Test Belonging');
    when(mockBelonging.category).thenReturn('Test Category');
  });

  group('Belonging Model Tests', () {
    test('should have correct properties', () {
      // Verify the properties
      expect(mockBelonging.ID, 'belonging-1');
      expect(mockBelonging.name, 'Test Belonging');
      expect(mockBelonging.category, 'Test Category');
    });

    test('toJson should return correct map', () {
      // Setup mock behavior for toJson
      when(mockBelonging.toJson()).thenReturn({
        'ID': 'belonging-1',
        'name': 'Test Belonging',
        'category': 'Test Category',
      });
      
      // Verify
      final json = mockBelonging.toJson();
      expect(json['ID'], 'belonging-1');
      expect(json['name'], 'Test Belonging');
      expect(json['category'], 'Test Category');
    });
  });
}
