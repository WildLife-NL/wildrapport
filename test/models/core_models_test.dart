import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/models/api_models/experiment.dart';
import 'package:wildrapport/models/api_models/living_labs.dart';
import 'package:wildrapport/models/api_models/location.dart';
import 'package:wildrapport/models/api_models/my_interaction.dart';

void main() {
  group('Location', () {
    test('fromJson/toJson roundtrip', () {
      final loc = Location.fromJson({'latitude': 52.1, 'longitude': 5.1});
      expect(loc.latitude, 52.1);
      expect(loc.longitude, 5.1);
      expect(loc.toJson(), {'latitude': 52.1, 'longitude': 5.1});
    });
  });

  group('LivingLabs', () {
    test('parses definition list when present', () {
      final ll = LivingLabs.fromJson({
        'ID': 'lab-1',
        'definition': [
          {'latitude': 52.0, 'longitude': 5.0},
          {'latitude': 52.1, 'longitude': 5.1},
        ],
        'name': 'Living Lab',
        'commonName': 'Lab',
      });

      expect(ll.id, 'lab-1');
      expect(ll.definition, isNotNull);
      expect(ll.definition!.length, 2);
      expect(ll.toJson()['ID'], 'lab-1');
    });

    test('allows null definition', () {
      final ll = LivingLabs.fromJson({
        'ID': 'lab-2',
        'definition': null,
        'name': 'Living Lab',
        'commonName': 'Lab',
      });
      expect(ll.definition, isNull);
      expect(ll.toJson()['definition'], isNull);
    });
  });

  group('Experiment', () {
    test('parses with minimal fields and user fallback', () {
      final exp = Experiment.fromJson({
        'ID': 'exp-1',
        'description': 'desc',
        'name': 'name',
        'start': '2026-03-25T12:00:00Z',
        'user': null, // triggers fallback
      });

      expect(exp.id, 'exp-1');
      expect(exp.user.id, isNotEmpty);
      expect(exp.toJson()['ID'], 'exp-1');
    });

    test('does not crash on invalid dates', () {
      final exp = Experiment.fromJson({
        'ID': 'exp-2',
        'description': 'desc',
        'name': 'name',
        'start': 'invalid',
        'end': 'invalid',
        'user': {'ID': 'u1', 'email': 'a@b.com'},
      });

      expect(exp.id, 'exp-2');
      expect(exp.start, isA<DateTime>());
      // end may be null
      expect(exp.user.id, 'u1');
    });
  });

  group('MyInteraction submodels', () {
    test('InvolvedAnimal defaults', () {
      final ia = InvolvedAnimal.fromJson({});
      expect(ia.sex, 'unknown');
      expect(ia.lifeStage, 'unknown');
      expect(ia.condition, 'other');
      expect(ia.toJson(), contains('sex'));
    });

    test('ReportOfCollision parses involved animals list', () {
      final roc = ReportOfCollision.fromJson({
        'involvedAnimals': [
          {'sex': 'male', 'lifeStage': 'adult', 'condition': 'unknown'},
        ],
        'estimatedDamage': 10,
        'intensity': 'high',
        'urgency': 'low',
      });

      expect(roc.involvedAnimals.length, 1);
      expect(roc.estimatedDamage, 10);
      expect(roc.toJson()['involvedAnimals'], isA<List>());
    });

    test('ReportOfCollision falls back severity from urgency/intensity', () {
      final fromUrgency = ReportOfCollision.fromJson({
        'involvedAnimals': const [],
        'estimatedDamage': 0,
        'urgency': 'critical',
      });
      final fromIntensity = ReportOfCollision.fromJson({
        'involvedAnimals': const [],
        'estimatedDamage': 0,
        'intensity': 'high',
      });

      expect(fromUrgency.severity, 'critical');
      expect(fromIntensity.severity, 'high');
    });

    test('ReportOfCollision prefers severity when all fields exist', () {
      final roc = ReportOfCollision.fromJson({
        'involvedAnimals': const [],
        'estimatedDamage': 0,
        'severity': 'explicit',
        'urgency': 'ignored',
        'intensity': 'ignored',
      });

      expect(roc.severity, 'explicit');
      expect(roc.intensity, 'explicit');
      expect(roc.urgency, 'explicit');
    });

    test('ReportOfDamage parses numeric fields from string and num', () {
      final rod = ReportOfDamage.fromJson({
        'belonging': 'akker',
        'estimatedLoss': '2500',
        'preventiveMeasures': true,
        'preventiveMeasuresDescription': 'hek geplaatst',
        'impactType': 'hectare',
        'impactValue': '12',
        'estimatedDamage': 99.9,
      });

      expect(rod.impactValue, 12);
      expect(rod.estimatedDamage, 99);
      expect(rod.preventiveMeasures, isTrue);
      expect(rod.toJson()['impactType'], 'hectare');
    });

    test('ReportOfDamage falls back to safe numeric defaults', () {
      final rod = ReportOfDamage.fromJson({
        'belonging': 'grasland',
        'impactValue': 'not-a-number',
        'estimatedDamage': null,
      });

      expect(rod.impactValue, 0);
      expect(rod.estimatedDamage, 0);
    });

    test('MyInteractionLocation falls back to 0.0 coordinates', () {
      final loc = MyInteractionLocation.fromJson(const {});
      expect(loc.latitude, 0.0);
      expect(loc.longitude, 0.0);
      expect(loc.toJson(), {'latitude': 0.0, 'longitude': 0.0});
    });

    test('ReportOfSighting handles missing involvedAnimals', () {
      final ros = ReportOfSighting.fromJson(const {});
      expect(ros.involvedAnimals, isEmpty);
      expect(ros.toJson()['involvedAnimals'], isA<List>());
    });

    test('InteractionTypeInfo defaults when fields are missing', () {
      final info = InteractionTypeInfo.fromJson(const {});
      expect(info.id, 0);
      expect(info.name, isEmpty);
      expect(info.description, isEmpty);
    });

    test('InteractionSpecies keeps optional text fields in toJson', () {
      final species = InteractionSpecies.fromJson({
        'ID': 'sp-1',
        'name': 'Canis lupus',
        'commonName': 'Wolf',
        'category': 'Roofdieren',
        'advice': 'afstand houden',
        'roleInNature': 'predator',
        'description': 'desc',
        'behaviour': 'nachtactief',
      });

      final json = species.toJson();
      expect(json['ID'], 'sp-1');
      expect(json['advice'], 'afstand houden');
      expect(json['roleInNature'], 'predator');
      expect(json['behaviour'], 'nachtactief');
    });
  });
}

