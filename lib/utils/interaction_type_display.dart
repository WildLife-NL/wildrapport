/// Normalized interaction keys used in the app: `waarneming`, `gewasschade`, `verkeersongeval`.
String? normalizeReportTypeKey(
  String? raw, {
  int? typeId,
}) {
  if (typeId != null) {
    switch (typeId) {
      case 1:
        return 'waarneming';
      case 2:
        return 'gewasschade';
      case 3:
        return 'verkeersongeval';
    }
  }

  final value = raw?.trim().toLowerCase();
  if (value == null || value.isEmpty) return null;

  if (value == 'waarneming' ||
      value.contains('sighting') ||
      value == 'observation') {
    return 'waarneming';
  }
  if (value == 'gewasschade' ||
      value.contains('schademelding') ||
      value.contains('crop damage') ||
      value.contains('damage report') ||
      value.contains('gewas')) {
    return 'gewasschade';
  }
  if (value == 'verkeersongeval' ||
      value.contains('dieraanrijding') ||
      value.contains('collision') ||
      value.contains('traffic') ||
      value.contains('aanrijding')) {
    return 'verkeersongeval';
  }

  return value;
}

String? inferReportTypeKey({
  String? typeName,
  int? typeId,
  bool hasReportOfSighting = false,
  bool hasReportOfCollision = false,
  bool hasReportOfDamage = false,
}) {
  final fromName = normalizeReportTypeKey(typeName, typeId: typeId);
  if (fromName != null && fromName.isNotEmpty) return fromName;

  if (hasReportOfDamage) return 'gewasschade';
  if (hasReportOfCollision) return 'verkeersongeval';
  if (hasReportOfSighting) return 'waarneming';

  return normalizeReportTypeKey(null, typeId: typeId);
}

String reportTypeDisplayLabel(String? reportTypeKey) {
  switch (normalizeReportTypeKey(reportTypeKey)) {
    case 'gewasschade':
      return 'Schademelding';
    case 'verkeersongeval':
      return 'Dieraanrijding';
    case 'waarneming':
    default:
      return 'Waarneming';
  }
}

int? _parseTypeId(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

/// Resolves report type from API interaction JSON (vicinity / query).
String? reportTypeFromInteractionJson(Map<String, dynamic> json) {
  final typeNode = json['type'] is Map
      ? Map<String, dynamic>.from(json['type'] as Map)
      : json['interactionType'] is Map
      ? Map<String, dynamic>.from(json['interactionType'] as Map)
      : <String, dynamic>{};

  final typeId = _parseTypeId(
    json['typeID'] ?? typeNode['ID'] ?? typeNode['id'],
  );
  final typeName = (typeNode['name'] ?? typeNode['displayName'])?.toString();

  return inferReportTypeKey(
    typeName: typeName,
    typeId: typeId,
    hasReportOfSighting: json['reportOfSighting'] != null,
    hasReportOfCollision: json['reportOfCollision'] != null,
    hasReportOfDamage: json['reportOfDamage'] != null,
  );
}
