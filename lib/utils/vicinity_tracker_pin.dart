import 'package:wildrapport/utils/interaction_payload_utils.dart';

/// GPS collar / tracker positions in vicinity payloads (not citizen waarnemingen).
bool isTrackerCollarVicinityJson(Map<String, dynamic> json) {
  if (json['borneSensorDeployment'] != null ||
      json['borneSensor'] != null ||
      json['collar'] != null ||
      json['collarID'] != null ||
      json['tracker'] != null ||
      json['trackingDevice'] != null) {
    return true;
  }

  final typeName = _interactionTypeName(json)?.toLowerCase() ?? '';
  if (typeName.contains('collar') ||
      typeName.contains('diergedragen') ||
      typeName.contains('wearable') ||
      typeName.contains('tracker') ||
      typeName.contains('gps')) {
    return true;
  }

  // Collar GPS uses `locationTimestamp`; citizen reports use `moment`.
  if (json['locationTimestamp'] == null) return false;
  return !hasCitizenReportPayload(json);
}

bool reportBlockHasCitizenContent(Object? block) {
  if (block is! Map) return false;
  final map = block is Map<String, dynamic> ? block : Map<String, dynamic>.from(block);
  if (map.isEmpty) return false;
  final animals = map['involvedAnimals'];
  if (animals is List && animals.isNotEmpty) return true;
  final belonging = map['belonging']?.toString().trim();
  return belonging != null && belonging.isNotEmpty;
}

/// True when the JSON looks like a user-submitted interaction (waarneming, etc.).
bool hasCitizenReportPayload(Map<String, dynamic> json) {
  final user = json['user'];
  if (user is Map) {
    final name = (user['name'] ?? user['username'])?.toString().trim();
    if (name != null && name.isNotEmpty) return true;
  }

  final notes = parseInteractionNotes(json);
  if (notes != null && notes.isNotEmpty) return true;

  if (reportBlockHasCitizenContent(json['reportOfSighting'])) return true;
  if (reportBlockHasCitizenContent(json['reportOfCollision'])) return true;
  if (reportBlockHasCitizenContent(json['reportOfDamage'])) return true;

  return false;
}

String? _interactionTypeName(Map<String, dynamic> json) {
  final typeNode = json['type'] is Map
      ? Map<String, dynamic>.from(json['type'] as Map)
      : json['interactionType'] is Map
          ? Map<String, dynamic>.from(json['interactionType'] as Map)
          : null;
  if (typeNode == null) return null;
  return (typeNode['name'] ?? typeNode['displayName'])?.toString();
}
