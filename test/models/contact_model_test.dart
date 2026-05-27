import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/models/api_models/contact_model.dart';

void main() {
  group('Contact.fromJson', () {
    test('parses animal from borneSensorDeployment and conveyances', () {
      final contact = Contact.fromJson({
        'ID': 'c-1',
        'contactHardwareAddress': 'AA:BB:CC:DD:EE:FF',
        'start': '2025-05-19T10:00:00Z',
        'borneSensorDeployment': {
          'sensorID': 'sensor-42',
          'animal': {
            'ID': 'animal-1',
            'commonName': 'Leeuw',
            'species': 'Panthera leo',
          },
        },
        'conveyances': [
          {
            'ID': 'cv-1',
            'timestamp': '2025-05-19T10:01:00Z',
            'message': {
              'name': 'Let op',
              'text': 'Houd afstand tot het dier.',
              'severity': 2,
            },
            'animal': {'commonName': 'Leeuw'},
          },
        ],
      });

      expect(contact.collarAnimalName, 'Leeuw');
      expect(contact.collarAnimalSpecies, 'Panthera leo');
      expect(contact.sensorId, 'sensor-42');
      expect(contact.hasAnimalInfo, isTrue);
      expect(contact.conveyancesWithMessages, hasLength(1));

      final cv = contact.conveyances.first;
      expect(cv.messageName, 'Let op');
      expect(cv.messageText, 'Houd afstand tot het dier.');
      expect(cv.messageSeverity, 2);
      expect(cv.hasMessageContent, isTrue);
      expect(contact.primaryResearcherMessage, 'Houd afstand tot het dier.');
    });
  });
}
