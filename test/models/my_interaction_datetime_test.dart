import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/models/api_models/my_interaction.dart';

Map<String, dynamic> _baseInteractionJson({
  required String moment,
  required String timestamp,
}) {
  return {
    'ID': 'i-1',
    'description': 'test',
    'location': {'latitude': 52.0, 'longitude': 5.0},
    'moment': moment,
    'place': {'latitude': 52.1, 'longitude': 5.1},
    'timestamp': timestamp,
    'species': {
      'ID': 'sp-1',
      'name': 'Canis lupus',
      'commonName': 'Wolf',
      'category': 'Roofdieren',
    },
    'user': {'ID': 'u-1', 'name': 'Tester'},
    'type': {'ID': 1, 'name': 'waarneming', 'description': 'desc'},
  };
}

void main() {
  group('MyInteraction datetime parsing', () {
    test('keeps timezone-less moment as local wall-clock time', () {
      final interaction = MyInteraction.fromJson(
        _baseInteractionJson(
          moment: '2026-03-25T12:00:00',
          timestamp: '2026-03-25T12:05:00',
        ),
      );

      expect(interaction.moment.isUtc, isFalse);
      expect(interaction.moment.hour, 12);
      expect(interaction.moment.minute, 0);
    });

    test('converts explicit UTC timestamps to local DateTime', () {
      final interaction = MyInteraction.fromJson(
        _baseInteractionJson(
          moment: '2026-03-25T12:00:00Z',
          timestamp: '2026-03-25T12:05:00Z',
        ),
      );

      expect(interaction.moment.isUtc, isFalse);
      expect(interaction.moment.toUtc().hour, 12);
      expect(interaction.timestamp.toUtc().hour, 12);
      expect(interaction.timestamp.toUtc().minute, 5);
    });

    test('preserves absolute time when timezone offset is provided', () {
      final interaction = MyInteraction.fromJson(
        _baseInteractionJson(
          moment: '2026-03-25T12:00:00+01:00',
          timestamp: '2026-03-25T12:05:00+01:00',
        ),
      );

      expect(interaction.moment.toUtc().hour, 11);
      expect(interaction.timestamp.toUtc().hour, 11);
      expect(interaction.timestamp.toUtc().minute, 5);
    });

    test('falls back safely on invalid datetime strings', () {
      final before = DateTime.now();
      final interaction = MyInteraction.fromJson(
        _baseInteractionJson(
          moment: 'not-a-date',
          timestamp: 'also-invalid',
        ),
      );
      final after = DateTime.now();

      expect(
        interaction.moment.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        interaction.moment.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        interaction.timestamp.isAfter(
          before.subtract(const Duration(seconds: 1)),
        ),
        isTrue,
      );
      expect(
        interaction.timestamp.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('keeps explicit local offsets distinct from naive local values', () {
      final withOffset = MyInteraction.fromJson(
        _baseInteractionJson(
          moment: '2026-03-25T12:00:00+02:00',
          timestamp: '2026-03-25T12:00:00+02:00',
        ),
      );
      final naive = MyInteraction.fromJson(
        _baseInteractionJson(
          moment: '2026-03-25T12:00:00',
          timestamp: '2026-03-25T12:00:00',
        ),
      );

      // Both are local DateTimes, but UTC instants should differ by timezone handling.
      expect(withOffset.moment.isUtc, isFalse);
      expect(naive.moment.isUtc, isFalse);
      expect(withOffset.moment.toUtc(), isNot(equals(naive.moment.toUtc())));
    });
  });

  group('MyInteraction model defaults', () {
    test('parses minimal payload with safe defaults', () {
      final interaction = MyInteraction.fromJson({
        'ID': 'i-min',
        'moment': '2026-03-25T12:00:00',
        'timestamp': '2026-03-25T12:00:00',
      });

      expect(interaction.id, 'i-min');
      expect(interaction.description, isEmpty);
      expect(interaction.location.latitude, 0.0);
      expect(interaction.place.longitude, 0.0);
      expect(interaction.species.id, isEmpty);
      expect(interaction.user.id, isEmpty);
      expect(interaction.type.id, 0);
      expect(interaction.reportOfCollision, isNull);
      expect(interaction.reportOfDamage, isNull);
      expect(interaction.reportOfSighting, isNull);
      expect(interaction.questionnaire, isNull);
    });

    test('parses optional report and questionnaire blocks when present', () {
      final interaction = MyInteraction.fromJson({
        'ID': 'i-full',
        'description': 'desc',
        'location': {'latitude': 52.0, 'longitude': 5.0},
        'moment': '2026-03-25T12:00:00Z',
        'place': {'latitude': 52.1, 'longitude': 5.1},
        'timestamp': '2026-03-25T12:05:00Z',
        'reportOfSighting': {
          'involvedAnimals': [
            {'sex': 'female', 'lifeStage': 'adult', 'condition': 'healthy'},
          ],
        },
        'species': {'ID': 'sp-1', 'name': 'Canis lupus', 'commonName': 'Wolf'},
        'user': {'ID': 'u-1', 'name': 'Tester'},
        'type': {'ID': 1, 'name': 'waarneming', 'description': 'd'},
        'questionnaire': {
          'ID': 'q-1',
          'name': 'Q',
          'identifier': 'q',
          'experiment': {
            'ID': 'e-1',
            'name': 'E',
            'user': {'ID': 'u-1', 'name': 'Tester'},
          },
          'interactionType': {'ID': 1, 'name': 'waarneming', 'description': 'd'},
        },
      });

      expect(interaction.reportOfSighting, isNotNull);
      expect(interaction.reportOfSighting!.involvedAnimals.length, 1);
      expect(interaction.questionnaire, isNotNull);
      expect(interaction.questionnaire!.experiment.id, 'e-1');
      expect(interaction.toJson()['questionnaire'], isA<Map<String, dynamic>>());
    });

    test('includes only present optional report blocks in toJson', () {
      final withDamage = MyInteraction.fromJson({
        'ID': 'i-damage',
        'moment': '2026-03-25T12:00:00',
        'timestamp': '2026-03-25T12:00:00',
        'reportOfDamage': {
          'belonging': 'akker',
          'estimatedLoss': '100',
          'preventiveMeasures': false,
          'preventiveMeasuresDescription': '',
        },
      });

      final json = withDamage.toJson();
      expect(json.containsKey('reportOfDamage'), isTrue);
      expect(json.containsKey('reportOfCollision'), isFalse);
      expect(json.containsKey('reportOfSighting'), isFalse);
    });

    test('roundtrips id and datetime keys in toJson', () {
      final interaction = MyInteraction.fromJson({
        'ID': 'i-roundtrip',
        'moment': '2026-03-25T12:34:56',
        'timestamp': '2026-03-25T12:35:00',
      });

      final json = interaction.toJson();
      expect(json['ID'], 'i-roundtrip');
      expect(json['moment'], isA<String>());
      expect(json['timestamp'], isA<String>());
    });
  });
}
