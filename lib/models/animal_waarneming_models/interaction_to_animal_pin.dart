import 'package:wildrapport/models/animal_waarneming_models/animal_pin.dart';
import 'package:wildrapport/models/api_models/interaction_query_result.dart';
import 'package:wildrapport/utils/interaction_type_display.dart';
import 'package:wildrapport/utils/involved_animal_count.dart';
import 'package:wildrapport/utils/interaction_animal_count_store.dart';

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
    reportType: normalizeReportTypeKey(typeName),
  );
}
   
}
