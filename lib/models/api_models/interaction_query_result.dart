import 'package:wildrapport/utils/interaction_type_display.dart';
import 'package:wildrapport/utils/api_datetime.dart';
import 'package:wildrapport/utils/preferred_report_location.dart';
import 'package:wildrapport/utils/involved_animal_count.dart';
import 'package:wildrapport/utils/interaction_payload_utils.dart';

class AnimalInfo {
  final String? sex;
  final String? lifeStage;
  final String? condition;

  AnimalInfo({this.sex, this.lifeStage, this.condition});

  factory AnimalInfo.fromJson(Map<String, dynamic> json) {
    return AnimalInfo(
      sex: json['sex']?.toString(),
      lifeStage: json['lifeStage']?.toString(),
      condition: json['condition']?.toString(),
    );
  }
}

class InteractionQueryResult {
  final String id;
  final double lat;
  final double lon;
  final DateTime moment;
  final String? typeName; // e.g., "Sighting"
  final String? speciesName; // e.g., "Vos"
  final String? description; // optional
  final String? userName; // User who reported
  final String? placeName; // Reverse geocoded place name
  final List<AnimalInfo>? involvedAnimals; // Animal details
  final int? animalCount;

  InteractionQueryResult({
    required this.id,
    required this.lat,
    required this.lon,
    required this.moment,
    this.typeName,
    this.speciesName,
    this.description,
    this.userName,
    this.placeName,
    this.involvedAnimals,
    this.animalCount,
  });

  factory InteractionQueryResult.fromJson(Map<String, dynamic> json) {
    final rawId = (json['id'] ?? json['ID'])?.toString();
    if (rawId == null || rawId.isEmpty) {
      throw const FormatException('InteractionQueryResult: missing id');
    }

    final locNode = PreferredReportLocation.mapForDisplay(json);
    if (locNode == null) {
      throw const FormatException(
        'InteractionQueryResult: missing location',
      );
    }

    final lat = _asDouble(locNode['latitude'] ?? locNode['lat']);
    final lon = _asDouble(locNode['longitude'] ?? locNode['lon']);

    if (lat == null || lon == null) {
      throw const FormatException(
        'InteractionQueryResult: missing coordinates',
      );
    }

    final rawMoment = json['moment']?.toString();

    // optional fields
    final typeNode =
        json['type'] as Map<String, dynamic>? ??
        json['interactionType'] as Map<String, dynamic>? ??
        const {};
    final speciesNode = json['species'] as Map<String, dynamic>? ?? const {};
    final userNode = json['user'] as Map<String, dynamic>? ?? const {};
    final placeNode = json['place'] as Map<String, dynamic>? ?? const {};

    // Parse involved animals from reportOfSighting, reportOfCollision, or reportOfDamage
    List<AnimalInfo>? animals;
    final reportOfSighting = json['reportOfSighting'] as Map<String, dynamic>?;
    final reportOfCollision =
        json['reportOfCollision'] as Map<String, dynamic>?;
    final reportOfDamage = json['reportOfDamage'] as Map<String, dynamic>?;

    if (reportOfSighting != null &&
        reportOfSighting['involvedAnimals'] != null) {
      final animalsList = reportOfSighting['involvedAnimals'] as List;
      animals =
          animalsList
              .whereType<Map<String, dynamic>>()
              .map((a) => AnimalInfo.fromJson(a))
              .toList();
    } else if (reportOfCollision != null &&
        reportOfCollision['involvedAnimals'] != null) {
      final animalsList = reportOfCollision['involvedAnimals'] as List;
      animals =
          animalsList
              .whereType<Map<String, dynamic>>()
              .map((a) => AnimalInfo.fromJson(a))
              .toList();
    } else if (reportOfDamage != null &&
        reportOfDamage['involvedAnimals'] != null) {
      final animalsList = reportOfDamage['involvedAnimals'] as List;
      animals =
          animalsList
              .whereType<Map<String, dynamic>>()
              .map((a) => AnimalInfo.fromJson(a))
              .toList();
    }

    final typeId = _parseTypeId(
      json['typeID'] ?? typeNode['ID'] ?? typeNode['id'],
    );
    final rawTypeName =
        (typeNode['name'] ?? typeNode['displayName'])?.toString();
    final resolvedTypeName = inferReportTypeKey(
      typeName: rawTypeName,
      typeId: typeId,
      hasReportOfSighting: reportOfSighting != null,
      hasReportOfCollision: reportOfCollision != null,
      hasReportOfDamage: reportOfDamage != null,
    );

    return InteractionQueryResult(
      id: rawId,
      lat: lat,
      lon: lon,
      moment: parseApiMomentToUtc(rawMoment),
      typeName: resolvedTypeName ?? rawTypeName,
      speciesName:
          (speciesNode['commonName'] ?? speciesNode['name'])?.toString(),
      description: parseInteractionNotes(json),
      userName: (userNode['name'] ?? userNode['username'])?.toString(),
      placeName: placeNode['name']?.toString(),
      involvedAnimals: animals,
      animalCount: extractAnimalCountFromInteractionJson(
        json,
        parsedInvolvedAnimals: animals,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'location': {'latitude': lat, 'longitude': lon},
    'moment': moment.toIso8601String(),
    if (typeName != null) 'type': {'name': typeName},
    if (speciesName != null) 'species': {'commonName': speciesName},
    if (description != null) 'notes': description,
    if (userName != null) 'user': {'name': userName},
    if (placeName != null) 'place': {'name': placeName},
    if (animalCount != null) 'animalCount': animalCount,
  };

  static double? _asDouble(Object? v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _parseTypeId(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

}
