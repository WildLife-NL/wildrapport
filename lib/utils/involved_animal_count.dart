import 'package:wildrapport/models/animal_waarneming_models/animal_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_sighting_model.dart';
import 'package:wildrapport/models/api_models/interaction_query_result.dart';
import 'package:wildrapport/models/api_models/my_interaction.dart';
import 'package:wildrapport/utils/interaction_animal_count_store.dart';

int? _parsePositiveInt(Object? value) {
  if (value is int) return value > 0 ? value : null;
  if (value is num) {
    final n = value.toInt();
    return n > 0 ? n : null;
  }
  if (value is String) {
    final n = int.tryParse(value.trim());
    return n != null && n > 0 ? n : null;
  }
  return null;
}

int _countInvolvedAnimalEntries(List<dynamic> animalsList) {
  var total = 0;
  for (final item in animalsList) {
    if (item is! Map) continue;
    final map = item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item);
    final amount = _parsePositiveInt(map['amount'] ?? map['count']) ?? 1;
    total += amount;
  }
  return total;
}

/// Sums age/gender bucket counts on each [AnimalModel] (waarneming telling table).
int countFromAnimalModels(List<AnimalModel>? animals) {
  if (animals == null || animals.isEmpty) return 0;

  var total = 0;
  for (final animal in animals) {
    var batch = 0;
    for (final genderView in animal.genderViewCounts) {
      final viewCount = genderView.viewCount;
      batch += viewCount.pasGeborenAmount +
          viewCount.onvolwassenAmount +
          viewCount.volwassenAmount +
          viewCount.unknownAmount;
    }
    total += batch > 0 ? batch : 1;
  }
  return total;
}

/// Total individuals reported in an in-progress or stored sighting.
int countAnimalsInSighting(AnimalSightingModel sighting) {
  final fromViewCounts = countFromAnimalModels(sighting.animals);
  final fromField = sighting.animalCount ?? 0;

  if (fromViewCounts > 0 || fromField > 0) {
    return fromViewCounts > fromField ? fromViewCounts : fromField;
  }

  final listLength = sighting.animals?.length ?? 0;
  if (listLength > 0) return listLength;
  if (sighting.animalSelected != null) return 1;
  return 0;
}

/// Best count for map/logbook from a vicinity interaction.
int? countFromInteraction(InteractionQueryResult interaction) {
  final listLen = interaction.involvedAnimals?.length ?? 0;
  final field = interaction.animalCount ?? 0;
  if (listLen > 0 || field > 0) {
    return listLen > field ? listLen : field;
  }
  return null;
}

/// Resolves count from API JSON (direct field vs nested involvedAnimals lists).
int? extractAnimalCountFromInteractionJson(
  Map<String, dynamic> json, {
  List<dynamic>? parsedInvolvedAnimals,
}) {
  var best = parsedInvolvedAnimals?.length ?? 0;

  for (final reportKey in [
    'reportOfSighting',
    'reportOfCollision',
    'reportOfDamage',
  ]) {
    final report = json[reportKey];
    if (report is! Map) continue;
    final reportMap =
        report is Map<String, dynamic> ? report : Map<String, dynamic>.from(report);

    for (final field in [
      'animalCount',
      'count',
      'numberOfAnimals',
      'totalCount',
      'total',
      'impactValue',
    ]) {
      final parsed = _parsePositiveInt(reportMap[field]);
      if (parsed != null && parsed > best) best = parsed;
    }

    final animalsList = reportMap['involvedAnimals'];
    if (animalsList is List) {
      final listLen = animalsList.length;
      if (listLen > best) best = listLen;
      final summed = _countInvolvedAnimalEntries(animalsList);
      if (summed > best) best = summed;
    }
  }

  for (final field in ['animalCount', 'count', 'numberOfAnimals']) {
    final parsed = _parsePositiveInt(json[field]);
    if (parsed != null && parsed > best) best = parsed;
  }

  return best > 0 ? best : null;
}

/// Animal count for logbook entries from `GET interactions/me`.
int countFromMyInteraction(MyInteraction interaction) {
  final json = interaction.toJson();
  var best = extractAnimalCountFromInteractionJson(json) ?? 0;

  if (interaction.reportOfDamage != null) {
    final impact = interaction.reportOfDamage!.impactValue;
    if (impact > best) best = impact;
  }

  final cached =
      InteractionAnimalCountStore.peek(interaction.id) ?? 0;
  if (cached > best) best = cached;

  return best > 0 ? best : 1;
}

/// Merges [cachedCount] into an interaction when API/vicinity data is incomplete.
InteractionQueryResult enrichInteractionAnimalCount(
  InteractionQueryResult interaction, {
  int? cachedCount,
}) {
  final resolved = countFromInteraction(interaction);
  final best = [
    resolved ?? 0,
    cachedCount ?? 0,
  ].reduce((a, b) => a > b ? a : b);

  if (best < 1 || best == interaction.animalCount) {
    return interaction;
  }

  return InteractionQueryResult(
    id: interaction.id,
    lat: interaction.lat,
    lon: interaction.lon,
    moment: interaction.moment,
    typeName: interaction.typeName,
    speciesName: interaction.speciesName,
    description: interaction.description,
    userName: interaction.userName,
    placeName: interaction.placeName,
    involvedAnimals: interaction.involvedAnimals,
    animalCount: best,
  );
}
