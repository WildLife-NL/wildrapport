import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/utils/interaction_pin_factory.dart';
import 'package:wildrapport/utils/preferred_report_location.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_sighting_model.dart';
import 'package:wildrapport/models/beta_models/location_model.dart';
import 'package:wildrapport/models/enums/location_source.dart';

void main() {
  group('PreferredReportLocation', () {
    test('prefers place coordinates over location when both present', () {
      final map = PreferredReportLocation.mapForDisplay({
        'location': {'latitude': 52.0, 'longitude': 5.0},
        'place': {'latitude': 52.5, 'longitude': 5.5},
      });

      expect(map?['latitude'], 52.5);
      expect(map?['longitude'], 5.5);
    });

    test('falls back to location when place is missing', () {
      final map = PreferredReportLocation.mapForDisplay({
        'location': {'latitude': 52.1, 'longitude': 5.1},
      });

      expect(map?['latitude'], 52.1);
      expect(map?['longitude'], 5.1);
    });
  });

  group('interactionPinFromSighting', () {
    test('uses manual location before system location', () {
      final sighting = AnimalSightingModel(
        reportType: 'waarneming',
        locations: [
          LocationModel(
            latitude: 52.0,
            longitude: 5.0,
            source: LocationSource.system,
          ),
          LocationModel(
            latitude: 52.9,
            longitude: 5.9,
            source: LocationSource.manual,
          ),
        ],
      );

      final pin = interactionPinFromSighting(sighting, 'int-1');

      expect(pin, isNotNull);
      expect(pin!.lat, 52.9);
      expect(pin.lon, 5.9);
    });
  });
}
