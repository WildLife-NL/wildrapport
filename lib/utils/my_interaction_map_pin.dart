import 'package:wildrapport/models/api_models/interaction_query_result.dart';
import 'package:wildrapport/models/api_models/my_interaction.dart';
import 'package:wildrapport/utils/interaction_type_display.dart';

/// Map pin from logbook `interactions/me` (logbook only, not used on kaart).
InteractionQueryResult? mapPinFromMyInteraction(MyInteraction interaction) {
  if (interaction.id.isEmpty) return null;

  var lat = interaction.location.latitude;
  var lon = interaction.location.longitude;
  if (lat == 0.0 && lon == 0.0) {
    lat = interaction.place.latitude;
    lon = interaction.place.longitude;
  }
  if (lat == 0.0 && lon == 0.0) return null;

  List<AnimalInfo>? involvedAnimals;
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
  );
}
