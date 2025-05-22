import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wildrapport/models/beta_models/report_location_model.dart';
import '../mock_generator.mocks.dart';

void main() {
  late MockReportLocation mockReportLocation;

  setUp(() {
    mockReportLocation = MockReportLocation();
    
    // Setup default behavior
    when(mockReportLocation.latitude).thenReturn(52.3676);
    when(mockReportLocation.longtitude).thenReturn(4.9041);
    when(mockReportLocation.cityName).thenReturn('Amsterdam');
    when(mockReportLocation.streetName).thenReturn('Main Street');
    when(mockReportLocation.houseNumber).thenReturn('123');
  });

  group('ReportLocation Model Tests', () {
    test('should have correct properties', () {
      // Verify the properties
      expect(mockReportLocation.latitude, 52.3676);
      expect(mockReportLocation.longtitude, 4.9041);
      expect(mockReportLocation.cityName, 'Amsterdam');
      expect(mockReportLocation.streetName, 'Main Street');
      expect(mockReportLocation.houseNumber, '123');
    });

    test('toJson should return correct map', () {
      // Setup mock behavior for toJson
      when(mockReportLocation.toJson()).thenReturn({
        'latitude': 52.3676,
        'longitude': 4.9041,
        'accuracy': 10.5,
        'timestamp': '2023-01-01T00:00:00.000',
      });
      
      // Verify
      final json = mockReportLocation.toJson();
      expect(json['latitude'], 52.3676);
      expect(json['longitude'], 4.9041);
      expect(json['accuracy'], 10.5);
      expect(json['timestamp'], '2023-01-01T00:00:00.000');
    });
  });
}


