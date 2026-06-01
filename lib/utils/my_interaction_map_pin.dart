import 'package:wildrapport/models/api_models/interaction_query_result.dart';
import 'package:wildrapport/models/api_models/my_interaction.dart';
import 'package:wildrapport/utils/interaction_type_display.dart';

/// Map pin from logbook `interactions/me` (logbook only, not used on kaart).
InteractionQueryResult? mapPinFromMyInteraction(MyInteraction interaction) {
  if (interaction.id.isEmpty) return null;

  final place = interaction.place;
  final device = interaction.location;
  final placeValid =
      (place.latitude != 0.0 || place.longitude != 0.0);
  final lat = placeValid ? place.latitude : device.latitude;
  final lon = placeValid ? place.longitude : device.longitude;
  if (lat == 0.0 && lon == 0.0) return null;

  List<AnimalInfo>? involvedAnimals;
  int? animalCount;
  final sighting = interaction.reportOfSighting;
  if (sighting != null && sighting.involvedAnimals.isNotEmpty) {
    involvedAnimals = sighting.involvedAnimals
        .map(
          (a) => AnimalInfo(
            sex: a.sex,
            lifeStage: a.lifeStage,
            condition: a.condition,
          ),
        )
        .toList();
    animalCount = involvedAnimals.length;
  }
  final collision = interaction.reportOfCollision;
  if (animalCount == null && collision != null) {
    animalCount = collision.involvedAnimals.length;
  }

  final speciesName = interaction.species.commonName.isNotEmpty
      ? interaction.species.commonName
      : interaction.species.name;

  final reportType = inferReportTypeKey(
    typeName: interaction.type.name,
    typeId: interaction.type.id,
    hasReportOfSighting: interaction.reportOfSighting != null,
    hasReportOfCollision: interaction.reportOfCollision != null,
    hasReportOfDamage: interaction.reportOfDamage != null,
  );

  return InteractionQueryResult(
    id: interaction.id,
    lat: lat,
    lon: lon,
    moment: interaction.moment.toUtc(),
    typeName: reportType ?? interaction.type.name,
    speciesName: speciesName.isNotEmpty ? speciesName : null,
    description: interaction.description.isNotEmpty ? interaction.description : null,
    userName: interaction.user.name.isNotEmpty ? interaction.user.name : null,
    involvedAnimals: involvedAnimals,
    animalCount: animalCount,
  );
}
