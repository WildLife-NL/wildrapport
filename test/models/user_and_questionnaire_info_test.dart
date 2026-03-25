import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/models/api_models/my_interaction.dart';
import 'package:wildrapport/models/api_models/user.dart';

void main() {
  group('User', () {
    test('fromJson supports ID/id/userID variants', () {
      expect(User.fromJson({'ID': '1'}).id, '1');
      expect(User.fromJson({'id': '2'}).id, '2');
      expect(User.fromJson({'userID': '3'}).id, '3');
    });

    test('toTermsUpdateJson only includes reportAppTerms when set', () {
      final a = User(id: '1', email: null, reportAppTerms: null);
      final b = User(id: '2', email: null, reportAppTerms: true);

      expect(a.toTermsUpdateJson(), isEmpty);
      expect(b.toTermsUpdateJson(), {'reportAppTerms': true});
    });
  });

  group('QuestionnaireInfo / ExperimentInfo / InteractionTypeInfo', () {
    test('parses nested structures with defaults', () {
      final q = QuestionnaireInfo.fromJson({
        'ID': 'q1',
        'name': 'Questionnaire',
        'identifier': 'waarneming',
        'experiment': {
          'ID': 'e1',
          'name': 'Experiment',
          'description': 'desc',
          'start': '2026-03-25T12:00:00Z',
          'end': '2026-03-26T12:00:00Z',
          'user': {'ID': 'u1', 'name': 'Guus'},
        },
        'interactionType': {'ID': 1, 'name': 'waarneming', 'description': 'd'},
      });

      expect(q.id, 'q1');
      expect(q.experiment.id, 'e1');
      expect(q.experiment.user.id, 'u1');
      expect(q.interactionType.id, 1);

      final json = q.toJson();
      expect(json['experiment'], isA<Map>());
      expect(json['interactionType'], isA<Map>());
    });

    test('handles missing nested maps by falling back to defaults', () {
      final q = QuestionnaireInfo.fromJson({
        'ID': 'q2',
        'name': 'Q',
        'identifier': 'x',
        // experiment missing
        // interactionType missing
      });

      expect(q.experiment.id, '');
      expect(q.interactionType.id, 0);
    });
  });
}

