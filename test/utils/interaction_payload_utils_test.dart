import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/utils/interaction_payload_utils.dart';

void main() {
  group('parseInteractionNotes', () {
    test('reads notes with fallback to description', () {
      expect(
        parseInteractionNotes({'notes': '  hello  '}),
        'hello',
      );
      expect(
        parseInteractionNotes({'description': 'legacy'}),
        'legacy',
      );
      expect(parseInteractionNotes({'notes': 'new', 'description': 'old'}), 'new');
    });

    test('returns null for missing or blank values', () {
      expect(parseInteractionNotes({}), isNull);
      expect(parseInteractionNotes({'notes': ''}), isNull);
      expect(parseInteractionNotes({'notes': '   '}), isNull);
    });
  });

  group('applyInteractionNotes', () {
    test('sets notes and removes description', () {
      final payload = {'description': 'old', 'typeID': 1};
      applyInteractionNotes(payload, '  my note  ');
      expect(payload['notes'], 'my note');
      expect(payload.containsKey('description'), isFalse);
      expect(payload['typeID'], 1);
    });

    test('omits notes when empty', () {
      final payload = {'description': 'old'};
      applyInteractionNotes(payload, null);
      expect(payload.containsKey('notes'), isFalse);
      expect(payload.containsKey('description'), isFalse);
    });
  });

  group('buildReportOfDamageJson', () {
    test('omits preventiveMeasuresDescription when empty', () {
      final json = buildReportOfDamageJson(
        belonging: 'Maïs',
        estimatedLoss: 'low',
        preventiveMeasures: true,
        preventiveMeasuresDescription: '  ',
      );
      expect(json.containsKey('preventiveMeasuresDescription'), isFalse);
      expect(json['preventiveMeasures'], isTrue);
    });

    test('includes preventiveMeasuresDescription when set', () {
      final json = buildReportOfDamageJson(
        belonging: 'Maïs',
        estimatedLoss: 'low',
        preventiveMeasures: true,
        preventiveMeasuresDescription: 'hek',
      );
      expect(json['preventiveMeasuresDescription'], 'hek');
    });
  });
}
