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
      expect(pin.reportType, 'collar');
    });

    test('prefers place over location for map display', () {
      final json = {
        'ID': 'a-3',
        'location': {'latitude': 52.0, 'longitude': 5.0},
        'place': {'latitude': 52.7, 'longitude': 5.7},
        'moment': '2026-03-25T12:00:00Z',
      };

      final pin = AnimalPin.fromJson(json);

      expect(pin.lat, 52.7);
      expect(pin.lon, 5.7);
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
      expect(pin.markerStyleHint, 'camera');
    });

    test('parses visual type for camera detections', () {
      final json = {
        'ID': 'd-visual',
        'location': {'latitude': 52.0, 'longitude': 5.0},
        'moment': '2026-03-25T13:15:00Z',
        'type': 'visual',
        'species': {'commonName': 'Vos'},
      };

      final pin = DetectionPin.fromJson(json);

      expect(pin.type, 'visual');
      expect(pin.label, 'Vos');
      expect(pin.markerStyleHint, 'visual');
    });

    test('parses nested type object from API', () {
      final pin = DetectionPin.fromJson({
        'ID': 'd-nested',
        'location': {'latitude': 52.0, 'longitude': 5.0},
        'moment': '2026-03-25T13:15:00Z',
        'type': {'name': 'visual'},
      });

      expect(pin.type, 'visual');
      expect(pin.markerStyleHint, 'visual');
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

    test('parses reporter name from nested reportedBy object', () {
      final pin = DetectionPin.fromJson({
        'id': 'd-reporter-1',
        'location': {'latitude': 52.0, 'longitude': 5.0},
        'moment': '2026-03-25T13:15:00Z',
        'deviceType': 'acoustic',
        'reportedBy': {
          'displayName': 'Animal Simulator',
        },
      });

      expect(pin.reportedByName, 'Animal Simulator');
    });

    test('parses animal sex and life stage from backend animal object', () {
      final pin = DetectionPin.fromJson({
        'id': 'd-animal-meta-1',
        'location': {'latitude': 52.0, 'longitude': 5.0},
        'moment': '2026-03-25T13:15:00Z',
        'type': 'visual',
        'animal': {
          'sex': 'female',
          'lifeStage': 'adult',
        },
      });

      expect(pin.animalSex, 'female');
      expect(pin.animalLifeStage, 'adult');
    });

    test('parses animal count from animals array', () {
      final pin = DetectionPin.fromJson({
        'id': 'd-animal-count-1',
        'location': {'latitude': 52.0, 'longitude': 5.0},
        'moment': '2026-03-25T13:15:00Z',
        'type': 'visual',
        'animals': [
          {'sex': 'female'},
          {'sex': 'male'},
        ],
      });

      expect(pin.animalCount, 2);
    });

    test('parses animal sex and life stage from animals array schema', () {
      final pin = DetectionPin.fromJson({
        'ID': 'd-animals-array-1',
        'location': {'latitude': 52.0, 'longitude': 5.0},
        'start': '2026-03-25T13:15:00Z',
        'sensorType': 'visual',
        'animals': [
          {
            'sex': 'female',
            'lifeStage': 'infant',
            'condition': 'healthy',
          },
        ],
      });

      expect(pin.animalSex, 'female');
      expect(pin.animalLifeStage, 'infant');
    });

    test('falls back to sensor name when reporter fields are absent', () {
      final pin = DetectionPin.fromJson({
        'id': 'd-reporter-2',
        'location': {'latitude': 52.0, 'longitude': 5.0},
        'moment': '2026-03-25T13:15:00Z',
        'type': 'visual',
        'sensor': {
          'name': 'Animal Simulator',
        },
      });

      expect(pin.reportedByName, 'Animal Simulator');
    });
  });
}
