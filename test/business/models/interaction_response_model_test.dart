import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/models/beta_models/interaction_response_model.dart';

void main() {
  group('InteractionResponse', () {
    test('empty() returns response with given interactionID', () {
      final response = InteractionResponse.empty(interactionID: 'int-abc-123');

      expect(response.interactionID, 'int-abc-123');
      expect(response.questionnaire, isNotNull);
      expect(response.questionnaire.id, 'N/A');
      expect(response.questionnaire.name, 'No questionnaire');
    });

    test('empty() has zero questions so app shows hoofdpagina', () {
      final response = InteractionResponse.empty(interactionID: 'int-xyz');

      expect(response.questionnaire.questions, isNotNull);
      expect(response.questionnaire.questions!.length, 0);
    });

    test('empty() with empty string interactionID', () {
      final response = InteractionResponse.empty(interactionID: '');

      expect(response.interactionID, '');
      expect(response.questionnaire.name, 'No questionnaire');
    });

    test('fromJson and toJson round-trip when questionnaire has id and interactionID', () {
      final json = {
        'interactionID': 'response-id-456',
        'questionnaire': {
          'ID': 'q-id',
          'name': 'Test',
          'experiment': {
            'ID': 'exp-1',
            'description': 'd',
            'name': 'n',
            'start': '2023-01-01T00:00:00.000',
            'user': {'ID': 'u1', 'name': 'User'},
          },
          'interactionType': {'ID': 1, 'name': 'Waarneming', 'description': 'd'},
          'questions': [],
        },
      };

      final response = InteractionResponse.fromJson(json);
      expect(response.interactionID, 'response-id-456');
      expect(response.questionnaire.id, 'q-id');
      expect(response.questionnaire.questions, isEmpty);

      final back = response.toJson();
      expect(back['interactionID'], 'response-id-456');
      expect(back['questionnaire'], isNotNull);
    });
  });
}
