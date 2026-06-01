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
      expect(result.typeName, 'waarneming');
      expect(result.speciesName, 'Vos');
      expect(result.description, 'Seen near forest');
      expect(result.userName, 'Guus');
      expect(result.placeName, 'Utrecht');
    });

    test('prefers place coordinates over location when both present', () {
      final json = {
        'ID': 'itx-place',
        'location': {'latitude': 52.0, 'longitude': 5.0},
        'place': {'latitude': 52.8, 'longitude': 5.8},
        'moment': '2026-03-25T10:30:00Z',
      };

      final result = InteractionQueryResult.fromJson(json);

      expect(result.lat, 52.8);
      expect(result.lon, 5.8);
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

    test('prefers involvedAnimals length over incorrect animalCount', () {
      final json = {
        'ID': 'itx-sighting',
        'location': {'latitude': 52.1, 'longitude': 5.1},
        'moment': '2026-03-25T10:30:00Z',
        'animalCount': 1,
        'reportOfSighting': {
          'involvedAnimals': List.generate(
            20,
            (_) => {'sex': 'unknown', 'lifeStage': 'adult'},
          ),
        },
      };

      final result = InteractionQueryResult.fromJson(json);

      expect(result.animalCount, 20);
      expect(result.involvedAnimals!.length, 20);
    });

    test('derives animalCount from collision involvedAnimals', () {
      final json = {
        'ID': 'itx-4',
        'location': {'latitude': 52.1, 'longitude': 5.1},
        'moment': '2026-03-25T10:30:00Z',
        'reportOfCollision': {
          'involvedAnimals': [
            {'sex': 'female'},
            {'sex': 'male'},
            {'sex': 'male'},
            {'sex': 'unknown'},
          ],
        },
      };

      final result = InteractionQueryResult.fromJson(json);

      expect(result.animalCount, 4);
      expect(result.involvedAnimals, isNotNull);
      expect(result.involvedAnimals!.length, 4);
    });
  });
}
