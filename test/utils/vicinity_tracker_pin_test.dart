import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/models/api_models/vicinity.dart';
import 'package:wildrapport/utils/interaction_type_display.dart';
import 'package:wildrapport/utils/vicinity_tracker_pin.dart';

void main() {
  group('isTrackerCollarVicinityJson', () {
    test('detects GPS collar shape via locationTimestamp', () {
      expect(
        isTrackerCollarVicinityJson({
          'ID': 'collar-1',
          'location': {'latitude': 52.0, 'longitude': 5.0},
          'locationTimestamp': '2026-03-25T12:00:00Z',
          'species': {'commonName': 'Bever'},
        }),
        isTrue,
      );
    });

    test('does not classify citizen waarneming with moment', () {
      expect(
        isTrackerCollarVicinityJson({
          'ID': 'interaction-1',
          'location': {'latitude': 52.0, 'longitude': 5.0},
          'moment': '2026-03-25T10:00:00Z',
          'type': {'ID': 1, 'name': 'waarneming'},
          'reportOfSighting': {
            'involvedAnimals': [
              {'sex': 'unknown', 'lifeStage': 'adult', 'condition': 'healthy'},
            ],
          },
          'user': {'name': 'Tester'},
        }),
        isFalse,
      );
    });

    test('detects borneSensorDeployment', () {
      expect(
        isTrackerCollarVicinityJson({
          'ID': 'c-1',
          'location': {'latitude': 52.0, 'longitude': 5.0},
          'moment': '2026-03-25T12:00:00Z',
          'borneSensorDeployment': {'sensorID': 's1'},
        }),
        isTrue,
      );
    });
  });

  group('reportTypeFromInteractionJson', () {
    test('returns collar for mislabeled tracker interaction', () {
      expect(
        reportTypeFromInteractionJson({
          'ID': 'x-1',
          'location': {'latitude': 52.0, 'longitude': 5.0},
          'locationTimestamp': '2026-03-25T12:00:00Z',
          'type': {'ID': 1, 'name': 'waarneming'},
          'reportOfSighting': {},
        }),
        'collar',
      );
    });
  });

  group('Vicinity.fromJson', () {
    test('moves tracker items from interactions to animals', () {
      final vicinity = Vicinity.fromJson({
        'animals': [],
        'detections': [],
        'interactions': [
          {
            'ID': 'tracker-in-interactions',
            'location': {'latitude': 52.1, 'longitude': 5.1},
            'locationTimestamp': '2026-03-25T14:00:00Z',
            'species': {'commonName': 'Wolf'},
            'type': {'ID': 1, 'name': 'waarneming'},
          },
        ],
      });

      expect(vicinity.animals.length, 1);
      expect(vicinity.interactions.length, 0);
      expect(vicinity.animals.first.reportType, 'collar');
      expect(vicinity.animals.first.speciesName, 'Wolf');
    });
  });
}
