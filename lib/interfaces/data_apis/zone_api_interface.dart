import 'package:wildrapport/models/api_models/zone.dart';

abstract class ZoneApiInterface {
  /// Create a new Zone of interest.
  Future<Zone> addZone(ZoneCreateRequest request);

  /// Add a species to an existing Zone.
  Future<Zone> addSpeciesToZone(ZoneSpeciesAssignRequest request);
}
