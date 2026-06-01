import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_gender_view_count_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_sighting_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/view_count_model.dart';
import 'package:wildrapport/models/api_models/interaction_query_result.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/utils/involved_animal_count.dart';

void main() {
  group('countAnimalsInSighting', () {
    test('sums gender/age buckets instead of animals list length', () {
      final sighting = AnimalSightingModel(
        animalCount: 1,
        animals: [
          AnimalModel(
            animalName: 'Vos',
            genderViewCounts: [
              AnimalGenderViewCount(
                gender: AnimalGender.onbekend,
                viewCount: ViewCountModel(unknownAmount: 20),
              ),
            ],
          ),
        ],
      );

      expect(countAnimalsInSighting(sighting), 20);
    });

    test('uses animalCount when higher than single list entry', () {
      final sighting = AnimalSightingModel(
        animalCount: 20,
        animals: [
          AnimalModel(animalName: 'Vos', genderViewCounts: []),
        ],
      );

      expect(countAnimalsInSighting(sighting), 20);
    });
  });

  group('extractAnimalCountFromInteractionJson', () {
    test('prefers involvedAnimals length over wrong animalCount field', () {
      final json = {
        'animalCount': 1,
        'reportOfSighting': {
          'involvedAnimals': List.generate(20, (_) => {'sex': 'unknown'}),
        },
      };

      expect(extractAnimalCountFromInteractionJson(json), 20);
    });
  });

  group('countFromInteraction', () {
    test('uses max of list and field', () {
      final interaction = InteractionQueryResult(
        id: 'x',
        lat: 1,
        lon: 2,
        moment: DateTime.utc(2026),
        animalCount: 1,
        involvedAnimals: List.generate(
          4,
          (_) => AnimalInfo(sex: 'unknown'),
        ),
      );

      expect(countFromInteraction(interaction), 4);
    });
  });
}
