import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/models/api_models/interaction_query_result.dart';

void main() {
  group('InteractionQueryResult', () {
    test('parses valid payload with optional fields', () {
      final json = {
        'ID': 'itx-1',
        'location': {'latitude': 52.1, 'longitude': 5.1},
        'moment': '2026-03-25T10:30:00Z',
        'type': {'name': 'Sighting'},
        'species': {'commonName': 'Vos'},
        'description': 'Seen near forest',
        'user': {'name': 'Guus'},
        'place': {'name': 'Utrecht'},
      };

      final result = InteractionQueryResult.fromJson(json);

      expect(result.id, 'itx-1');
      expect(result.lat, 52.1);
      expect(result.lon, 5.1);
      expect(result.typeName, 'Sighting');
      expect(result.speciesName, 'Vos');
      expect(result.description, 'Seen near forest');
      expect(result.userName, 'Guus');
      expect(result.placeName, 'Utrecht');
    });

    test('throws FormatException when id is missing', () {
      final json = {
        'location': {'latitude': 52.1, 'longitude': 5.1},
      };

      expect(
        () => InteractionQueryResult.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when coordinates are missing', () {
      final json = {'ID': 'itx-2', 'location': <String, dynamic>{}};

      expect(
        () => InteractionQueryResult.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('toJson keeps required shape', () {
      final result = InteractionQueryResult(
        id: 'itx-3',
        lat: 51.9,
        lon: 4.5,
        moment: DateTime.parse('2026-03-25T12:00:00Z'),
        speciesName: 'Wolf',
      );

      final json = result.toJson();

      expect(json['id'], 'itx-3');
      expect(json['location']['latitude'], 51.9);
      expect(json['location']['longitude'], 4.5);
      expect(json['species']['commonName'], 'Wolf');
    });
  });
}
