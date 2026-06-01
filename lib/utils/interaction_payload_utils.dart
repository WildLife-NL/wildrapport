/// Helpers for `POST /interaction/` payloads (API #166).
library;

/// Reads interaction notes from API JSON (`notes` replaces `description`).
String? parseInteractionNotes(Map<String, dynamic> json) {
  final raw = json['notes'] ?? json['description'];
  if (raw == null) return null;
  final trimmed = raw.toString().trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// Sets optional top-level `notes` on an interaction body; omits legacy `description`.
void applyInteractionNotes(Map<String, dynamic> payload, String? notes) {
  payload.remove('description');
  final trimmed = notes?.trim();
  if (trimmed != null && trimmed.isNotEmpty) {
    payload['notes'] = trimmed;
  } else {
    payload.remove('notes');
  }
}

/// Builds `reportOfDamage` with optional [preventiveMeasuresDescription].
Map<String, dynamic> buildReportOfDamageJson({
  required String belonging,
  required String estimatedLoss,
  required bool preventiveMeasures,
  String? preventiveMeasuresDescription,
  int? estimatedDamage,
  String? impactType,
  int? impactValue,
}) {
  final damage = <String, dynamic>{
    'belonging': belonging,
    'estimatedLoss': estimatedLoss,
    'preventiveMeasures': preventiveMeasures,
  };

  final preventiveDesc = preventiveMeasuresDescription?.trim();
  if (preventiveDesc != null && preventiveDesc.isNotEmpty) {
    damage['preventiveMeasuresDescription'] = preventiveDesc;
  }

  if (estimatedDamage != null) {
    damage['estimatedDamage'] = estimatedDamage;
  }
  if (impactType != null && impactType.isNotEmpty) {
    damage['impactType'] = impactType;
  }
  if (impactValue != null) {
    damage['impactValue'] = impactValue;
  }

  return damage;
}
