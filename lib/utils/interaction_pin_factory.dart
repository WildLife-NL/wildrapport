import 'package:wildrapport/models/animal_waarneming_models/animal_sighting_model.dart';
import 'package:wildrapport/models/api_models/interaction_query_result.dart';
import 'package:wildrapport/models/beta_models/location_model.dart';
import 'package:wildrapport/models/enums/location_source.dart';
import 'package:wildrapport/utils/interaction_type_display.dart';
import 'package:wildrapport/utils/api_datetime.dart';

/// Builds a map pin from a just-submitted sighting (until next tracking-reading refresh).
InteractionQueryResult? interactionPinFromSighting(
  AnimalSightingModel sighting,
  String interactionId,
) {
  if (interactionId.trim().isEmpty) return null;

  final locations = sighting.locations;
  if (locations == null || locations.isEmpty) return null;

  final displayLocation = _displayLocation(locations);
  if (displayLocation == null) return null;
  final lat = displayLocation.latitude;
  final lon = displayLocation.longitude;
  if (lat == null || lon == null) return null;

  final moment = sighting.dateTime?.dateTime ?? DateTime.now();

  return InteractionQueryResult(
    id: interactionId,
    lat: lat,
    lon: lon,
    moment: parseApiMomentToUtc(moment.toIso8601String()),
    typeName: normalizeReportTypeKey(sighting.reportType) ?? 'waarneming',
    speciesName: sighting.animalSelected?.animalName,
    description: sighting.description,
  );
}

/// User-chosen point on the map, not device GPS at submit time.
LocationModel? _displayLocation(List<LocationModel> locations) {
  for (final loc in locations) {
    if (loc.source == LocationSource.manual &&
        loc.latitude != null &&
        loc.longitude != null) {
      return loc;
    }
  }
  for (final loc in locations) {
    if (loc.latitude != null && loc.longitude != null) {
      return loc;
    }
  }
  return null;
}
