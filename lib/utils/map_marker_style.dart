import 'package:wildrapport/utils/interaction_type_display.dart';

/// Resolves map pin ring/icon styling (legenda + markers).
String? mapMarkerStyleKey(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;

  final type = raw.toLowerCase();

  // Sensor / detection kinds (API: `visual` = camera trap). Check before
  // [normalizeReportTypeKey], which would return `visual` unchanged and skip
  // the camera icon branch.
  if (type.contains('visual') ||
      type.contains('camera') ||
      type.contains('foto') ||
      type.contains('camer')) {
    return 'camera';
  }
  if (type.contains('acoustic') || type.contains('geluid')) {
    return 'acoustic';
  }
  if (type.contains('collar')) return 'collar';

  final reportType = normalizeReportTypeKey(raw);
  if (reportType != null) return reportType;

  return type;
}

bool mapMarkerUsesCameraIcon(String? raw) => mapMarkerStyleKey(raw) == 'camera';

bool mapMarkerUsesAcousticIcon(String? raw) => mapMarkerStyleKey(raw) == 'acoustic';
