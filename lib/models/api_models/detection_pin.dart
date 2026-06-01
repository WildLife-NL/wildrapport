import 'package:wildrapport/utils/preferred_report_location.dart';

class DetectionPin {
  final String id;

  final String? type;
  final String? deviceType;
  final String? label;
  final double lat;
  final double lon;
  final DateTime detectedAt;
  final double? confidence;

  DetectionPin({
    required this.id,
    required this.lat,
    required this.lon,
    required this.detectedAt,
    this.type,
    this.deviceType,
    this.label,
    this.confidence,
  });

  /// Prefer [type] (vicinity detections); fall back to hardware [deviceType].
  String? get markerStyleHint {
    final kind = type?.trim();
    if (kind != null && kind.isNotEmpty) return kind;
    final device = deviceType?.trim();
    if (device != null && device.isNotEmpty) return device;
    return null;
  }

  factory DetectionPin.fromJson(Map<String, dynamic> j) {
    final loc = PreferredReportLocation.mapForDisplay(j);
    if (loc == null) {
      throw const FormatException('DetectionPin: missing location');
    }

    final lat = _asDouble(loc['latitude'] ?? loc['lat']);
    final lon = _asDouble(loc['longitude'] ?? loc['lon']);
    if (lat == null || lon == null) {
      throw const FormatException('DetectionPin: missing coordinates');
    }

    final id = (j['id'] ??
            j['ID'] ??
            j['sensorID'] ??
            j['deploymentID'])
        ?.toString();
    if (id == null || id.isEmpty) {
      throw const FormatException('DetectionPin: missing id');
    }

    final species = j['species'];
    final speciesMap = species is Map<String, dynamic>
        ? species
        : species is Map
            ? Map<String, dynamic>.from(species)
            : null;

    final ts =
        (j['moment'] ?? j['timestamp'] ?? j['start'] ?? j['end'])?.toString();

    return DetectionPin(
      id: id,
      lat: lat,
      lon: lon,
      detectedAt:
          DateTime.tryParse(ts ?? '')?.toUtc() ?? DateTime.now().toUtc(),
      type: _parseKind(j['type'] ?? j['detectionType']),
      deviceType: _parseKind(
        j['deviceType'] ?? j['sensorType'] ?? j['sensor']?['type'],
      ),
      label: j['label']?.toString() ??
          speciesMap?['commonName']?.toString() ??
          speciesMap?['name']?.toString(),
      confidence: (j['confidence'] as num?)?.toDouble(),
    );
  }

  static double? _asDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  /// String or API object `{ "name": "visual" }`.
  static String? _parseKind(Object? raw) {
    if (raw == null) return null;
    if (raw is String) {
      final trimmed = raw.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (raw is Map) {
      final name = (raw['name'] ?? raw['type'] ?? raw['value'])?.toString();
      final trimmed = name?.trim();
      return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    }
    final trimmed = raw.toString().trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
