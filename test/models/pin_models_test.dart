import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_pin.dart';
import 'package:wildrapport/models/api_models/detection_pin.dart';

void main() {
  group('AnimalPin.fromJson', () {
    test('parses location and species fields', () {
      final json = {
        'ID': 'a-1',
        'location': {'latitude': 52.2, 'longitude': 5.2},
        'seenAt': '2026-03-25T12:00:00Z',
        'species': {'commonName': 'Ree'},
      };

      final pin = AnimalPin.fromJson(json);

      expect(pin.id, 'a-1');
      expect(pin.lat, 52.2);
      expect(pin.lon, 5.2);
      expect(pin.speciesName, 'Ree');
    });

    test('falls back to now when timestamp invalid', () {
      final json = {
        'ID': 'a-2',
        'location': {'latitude': 52.2, 'longitude': 5.2},
        'seenAt': 'invalid',
      };

      final before = DateTime.now().toUtc().subtract(const Duration(seconds: 1));
      final pin = AnimalPin.fromJson(json);
      final after = DateTime.now().toUtc().add(const Duration(seconds: 1));

      expect(pin.seenAt.isAfter(before), isTrue);
      expect(pin.seenAt.isBefore(after), isTrue);
    });
  });

  group('DetectionPin.fromJson', () {
    test('parses required and optional fields', () {
      final json = {
        'id': 'd-1',
        'location': {'lat': 51.9, 'lon': 4.5},
        'moment': '2026-03-25T13:15:00Z',
        'deviceType': 'camera',
        'label': 'Vos',
        'confidence': 0.89,
      };

      final pin = DetectionPin.fromJson(json);

      expect(pin.id, 'd-1');
      expect(pin.lat, 51.9);
      expect(pin.lon, 4.5);
      expect(pin.deviceType, 'camera');
      expect(pin.label, 'Vos');
      expect(pin.confidence, 0.89);
    });

    test('falls back to now when detectedAt invalid', () {
      final json = {
        'id': 'd-2',
        'location': {'latitude': 51.9, 'longitude': 4.5},
        'timestamp': 'nope',
      };

      final before = DateTime.now().toUtc().subtract(const Duration(seconds: 1));
      final pin = DetectionPin.fromJson(json);
      final after = DateTime.now().toUtc().add(const Duration(seconds: 1));

      expect(pin.detectedAt.isAfter(before), isTrue);
      expect(pin.detectedAt.isBefore(after), isTrue);
    });
  });
}
