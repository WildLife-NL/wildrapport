import 'package:wildrapport/utils/api_datetime.dart';
import 'package:wildrapport/utils/event_timestamp_extractor.dart';
import 'package:wildrapport/utils/preferred_report_location.dart';

class DetectionPin {
  final String id;

  final String? type;
  final String? deviceType;
  final String? label;
  final String? speciesLatinName;
  final String? animalSex;
  final String? animalLifeStage;
  final int? animalCount;
  final String? reportedByName;
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
    this.speciesLatinName,
    this.animalSex,
    this.animalLifeStage,
    this.animalCount,
    this.reportedByName,
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

    final species =
      j['species'] ?? j['animal'] ?? j['detectedAnimal'] ?? j['capture']?['species'];
    final speciesMap = species is Map<String, dynamic>
        ? species
        : species is Map
            ? Map<String, dynamic>.from(species)
            : null;
    final firstAnimal = _firstMapFromList(j['animals']);
    final animals = j['animals'];
    final animalCount = animals is List ? animals.length : null;

    final ts = extractEventTimestampFromMap(j);

    return DetectionPin(
      id: id,
      lat: lat,
      lon: lon,
      detectedAt: parseBackendTimestampToUtc(ts),
      type: _parseKind(j['type'] ?? j['detectionType']),
      deviceType: _parseKind(
        j['deviceType'] ?? j['sensorType'] ?? j['sensor']?['type'],
      ),
      label: j['label']?.toString() ??
          speciesMap?['commonName']?.toString() ??
          speciesMap?['name']?.toString(),
      speciesLatinName: _readNestedString(j, const [
        'species.scientificName',
        'species.latinName',
        'species.name',
        'animal.scientificName',
        'animal.latinName',
        'animal.name',
        'detectedAnimal.scientificName',
        'detectedAnimal.latinName',
        'detectedAnimal.name',
        'capture.species.scientificName',
        'capture.species.latinName',
        'capture.species.name',
      ]) ??
          speciesMap?['scientificName']?.toString() ??
          speciesMap?['latinName']?.toString() ??
          speciesMap?['name']?.toString(),
      animalSex: _readNestedString(firstAnimal, const [
            'sex',
            'gender',
          ]) ??
          _readNestedString(j, const [
            'sex',
            'geslacht',
            'gender',
          ]),
      animalLifeStage: _readNestedString(firstAnimal, const [
            'lifeStage',
          ]) ??
          _readNestedString(j, const [
            'animal.lifeStage',
            'detectedAnimal.lifeStage',
            'capture.species.lifeStage',
            'species.lifeStage',
            'lifeStage',
          ]),
      animalCount: animalCount,
      reportedByName: _readNestedString(j, const [
        'reportedByName',
        'reportedBy.name',
        'reportedBy.fullName',
        'reportedBy.displayName',
        'reportedBy.username',
        'reportedBy.userName',
        'reportedBy.profile.name',
        'reportedBy.profile.displayName',
        'reportedBy.name',
        'reportedBy',
        'reportingUser.name',
        'reportingUser.fullName',
        'reportingUser.displayName',
        'createdBy.name',
        'createdBy.fullName',
        'createdBy.displayName',
        'createdBy.username',
        'createdByUser.name',
        'submittedBy.name',
        'submittedBy.fullName',
        'submittedBy.displayName',
        'user.name',
        'user.fullName',
        'user.displayName',
        'user.username',
        'profile.name',
        'profile.fullName',
        'profile.displayName',
        'owner.name',
        'owner.fullName',
        'owner.displayName',
        'owner',
        'device.owner',
        'device.owner.name',
        'device.owner.fullName',
        'device.owner.displayName',
        'device.name',
        'sensor.owner',
        'sensor.owner.name',
        'sensor.owner.fullName',
        'sensor.owner.displayName',
        'sensor.reportedBy',
        'sensor.reportedBy.name',
        'sensor.reporter',
        'sensor.name',
        'deployment.reportedBy',
        'deployment.reportedBy.name',
        'deployment.owner',
        'deployment.owner.name',
        'deployment.owner.fullName',
        'deployment.name',
        'source.reportedBy',
        'source.reportedBy.name',
        'source.owner',
        'source.owner.name',
        'source.name',
        'camera.owner',
        'camera.owner.name',
        'camera.owner.fullName',
        'camera.owner.displayName',
        'camera.reportedBy',
        'camera.reportedBy.name',
        'camera.name',
        'site.reportedBy',
        'site.reportedBy.name',
        'site.owner',
        'site.owner.name',
        'site.name',
        'reporter',
        'reported_by',
      ]),
      confidence: (j['confidence'] as num?)?.toDouble(),
    );
  }

  static String? _readNestedString(Object? value, List<String> paths) {
    if (value == null || value is! Map) return null;

    for (final path in paths) {
      Object? node = value;
      for (final seg in path.split('.')) {
        if (node is! Map) {
          node = null;
          break;
        }
        node = node[seg];
      }

      final text = _extractStringValue(node);
      if (text != null && text.isNotEmpty) return text;
    }

    return null;
  }

  static Map<String, dynamic>? _firstMapFromList(Object? value) {
    if (value is! List) return null;

    for (final item in value) {
      if (item is Map<String, dynamic>) return item;
      if (item is Map) return Map<String, dynamic>.from(item);
    }

    return null;
  }

  static String? _extractStringValue(Object? value) {
    if (value == null) return null;

    if (value is String) {
      final text = value.trim();
      return text.isEmpty ? null : text;
    }

    if (value is Map) {
      for (final key in const [
        'name',
        'fullName',
        'displayName',
        'username',
        'userName',
        'title',
        'label',
      ]) {
        final candidate = _extractStringValue(value[key]);
        if (candidate != null && candidate.isNotEmpty) return candidate;
      }
      return null;
    }

    final text = value.toString().trim();
    return text.isEmpty ? null : text;
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
