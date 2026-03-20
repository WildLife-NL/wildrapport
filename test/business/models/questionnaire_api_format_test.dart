import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';

void main() {
  group('Questionnaire.fromJson (API format)', () {
    test('accepts ID (capital) and questions array', () {
      final json = {
        'ID': '3892eb50-4697-4c72-aadc-32b766bce3c0',
        'name': 'Vragenlijst waarneming',
        'identifier': 'v1',
        'experiment': {
          'ID': 'exp-uuid',
          'description': 'Test',
          'name': 'Experiment',
          'start': '2023-01-01T12:00:00.000',
          'user': {'ID': 'user-1', 'name': 'Test User'},
        },
        'interactionType': {'ID': 1, 'name': 'Waarneming', 'description': 'Een levend wild dier gezien.'},
        'questions': [
          {
            'ID': 'q1',
            'text': 'Hoeveel dieren zag u?',
            'description': '',
            'index': 1,
            'allowMultipleResponse': false,
            'allowOpenResponse': false,
            'answers': [
              {'ID': 'a1', 'index': 0, 'text': 'Eén'},
              {'ID': 'a2', 'index': 1, 'text': 'Meerdere'},
            ],
          },
        ],
      };

      final q = Questionnaire.fromJson(json);

      expect(q.id, '3892eb50-4697-4c72-aadc-32b766bce3c0');
      expect(q.name, 'Vragenlijst waarneming');
      expect(q.questions, isNotNull);
      expect(q.questions!.length, 1);
      expect(q.questions!.first.text, 'Hoeveel dieren zag u?');
      expect(q.questions!.first.answers, isNotNull);
      expect(q.questions!.first.answers!.length, 2);
    });

    test('accepts id (lowercase) and Questions (capital)', () {
      final json = {
        'id': 'questionnaire-id',
        'name': 'Test',
        'experiment': {
          'id': 'exp-1',
          'description': '',
          'name': 'E',
          'start': '2020-06-01T00:00:00.000',
          'user': {'id': 'u1'},
        },
        'interactionType': {'id': 1, 'name': 'W', 'description': 'd'},
        'Questions': [
          {
            'id': 'q1',
            'text': 'Vraag?',
            'description': '',
            'index': 1,
            'allowMultipleResponse': false,
            'allowOpenResponse': false,
            'answers': [
              {'id': 'a1', 'index': 0, 'text': 'Ja'},
            ],
          },
        ],
      };

      final q = Questionnaire.fromJson(json);

      expect(q.id, 'questionnaire-id');
      expect(q.questions, isNotNull);
      expect(q.questions!.length, 1);
      expect(q.questions!.first.id, 'q1');
      expect(q.questions!.first.answers!.first.text, 'Ja');
    });

    test('handles null or empty questions', () {
      final json = {
        'ID': 'q-id',
        'name': 'Lege vragenlijst',
        'experiment': {
          'ID': 'e1',
          'description': '',
          'name': 'E',
          'start': '2020-01-01T00:00:00.000',
          'user': {'ID': 'u1'},
        },
        'interactionType': {'ID': 1, 'name': 'W', 'description': 'd'},
        'questions': [],
      };

      final q = Questionnaire.fromJson(json);

      expect(q.questions, isNotNull);
      expect(q.questions!.length, 0);
    });
  });
}
