import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/data_managers/sighting_report_schema_loader.dart';
import 'package:wildrapport/constants/sighting_report_activities.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_sighting_model.dart';
import 'package:wildrapport/utils/sighting_report_payload.dart';

void main() {
  group('SightingReportSchema', () {
    test('parses enum values from schema JSON', () {
      final schema = SightingReportSchema.fromJson({
        'properties': {
          'humanActivity': {
            'enum': [
              'unknown',
              'walking',
              'other...',
            ],
          },
          'perceivedAnimalActivity': {
            'enum': [
              'unknown',
              'walking',
              'eating',
              'looking around',
              'fleeing',
              'resting',
              'other...',
            ],
          },
        },
      });

      expect(schema.humanActivityValues, contains('walking'));
      expect(schema.perceivedAnimalActivityValues, contains('eating'));
      expect(schema.perceivedAnimalActivityValues, contains('other...'));
    });

    test('catalog uses researcher Dutch labels for animal activity', () {
      SightingReportActivityCatalog.loadFromSchemaForTest(
        SightingReportSchema(
          humanActivityValues: const ['unknown', 'walking'],
          perceivedAnimalActivityValues: const [
            'walking',
            'eating',
            'other...',
          ],
        ),
      );

      expect(
        SightingReportActivityCatalog.labelNlForPerceivedAnimal('walking'),
        'Lopen',
      );
      expect(
        SightingReportActivityCatalog.labelNlForPerceivedAnimal('eating'),
        'Eten of drinken',
      );
      expect(
        SightingReportActivityCatalog.labelNlForPerceivedAnimal('other...'),
        'Anders, namelijk ...',
      );
    });

    test('payload includes other fields when other... selected', () {
      SightingReportActivityCatalog.loadFromSchemaForTest(
        SightingReportSchema(
          humanActivityValues: const ['unknown', 'other...'],
          perceivedAnimalActivityValues: const ['unknown', 'other...'],
        ),
      );

      final report = AnimalSightingModel(
        humanActivity: 'other...',
        humanActivityOther: 'Fotografie met drone',
        perceivedAnimalActivity: 'other...',
        perceivedAnimalActivityOther: 'Spelend jong',
      );

      final payload = <String, dynamic>{};
      SightingReportPayload.applyToReportOfSighting(payload, report);

      expect(payload['humanActivity'], 'other...');
      expect(payload['humanActivityOther'], 'Fotografie met drone');
      expect(payload['perceivedAnimalActivity'], 'other...');
      expect(payload['perceivedAnimalActivityOther'], 'Spelend jong');
    });
  });
}
