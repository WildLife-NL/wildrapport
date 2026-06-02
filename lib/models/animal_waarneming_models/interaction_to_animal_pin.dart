import 'package:wildrapport/models/animal_waarneming_models/animal_pin.dart';
import 'package:wildrapport/models/api_models/interaction_query_result.dart';
import 'package:wildrapport/utils/interaction_type_display.dart';
import 'package:wildrapport/utils/involved_animal_count.dart';
import 'package:wildrapport/utils/interaction_animal_count_store.dart';

String buildGroupSummary(List<AnimalInfo>? animals, int fallbackCount) {
  if (animals == null || animals.isEmpty) {
    return '$fallbackCount ${fallbackCount == 1 ? 'dier' : 'dieren'}';
  }

  final counts = <String, int>{};

  for (final animal in animals) {
    final parts = <String>[];

    if (animal.condition == 'healthy') parts.add('gezond');
    if (animal.lifeStage == 'adult') parts.add('volwassen');
    if (animal.lifeStage == 'infant') parts.add('jong');

    if (animal.sex == 'male') {
      parts.add('mannetje');
    } else if (animal.sex == 'female') {
      parts.add('vrouwtje');
    } else {
      parts.add('onbekend');
    }

    final key = parts.join(' ');
    counts[key] = (counts[key] ?? 0) + 1;
  }

  return counts.entries
      .map((e) => '${e.value} ${e.key}${e.value > 1 ? 's' : ''}')
      .join(', ');
}
extension InteractionToAnimalPin on InteractionQueryResult {
  AnimalPin toAnimalPin() {
  print('TO ANIMAL PIN -> common=$speciesName latin=$speciesLatinName');

  final enriched = enrichInteractionAnimalCount(
    this,
    cachedCount: InteractionAnimalCountStore.peek(id),
  );

  return AnimalPin(
    id: id,
    lat: lat,
    lon: lon,
    seenAt: moment,
    speciesName: speciesName,
    speciesLatinName: speciesLatinName,
    animalCount: countFromInteraction(enriched),
    reportedByName: userName,
    reportType: normalizeReportTypeKey(typeName),
    groupSummary: buildGroupSummary(
      involvedAnimals,
      countFromInteraction(enriched) ?? 1,
    ),
  );
}
   
}
