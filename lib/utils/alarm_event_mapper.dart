import 'package:wildrapport/models/api_models/detection_pin.dart';
import 'package:wildrapport/models/api_models/interaction_query_result.dart';
import 'package:wildrapport/models/map_alarm_focus.dart';
import 'package:wildrapport/utils/api_datetime.dart';
import 'package:wildrapport/utils/event_timestamp_extractor.dart';
import 'package:wildrapport/utils/preferred_report_location.dart';
import 'package:wildlifenl_alarms_components/wildlifenl_alarms_components.dart';

/// Builds a map focus target from an [Alarm]'s linked detection or interaction.
MapAlarmFocus? mapAlarmFocusFromAlarm(Alarm alarm) {
  final detectionMap = _asMap(alarm.detection) ?? _asMap(_alarmToMap(alarm)?['detection']);
  if (detectionMap != null) {
    final pin = _detectionPinFromMap(detectionMap);
    if (pin != null) return MapAlarmFocus.detection(pin);
  }

  final interactionMap =
      _asMap(alarm.interaction) ?? _asMap(_alarmToMap(alarm)?['interaction']);
  if (interactionMap != null) {
    final speciesFallback = _speciesLabelFromAlarm(alarm);
    final interaction = _interactionFromMap(
      interactionMap,
      speciesFallback: speciesFallback,
    );
    if (interaction != null) return MapAlarmFocus.interaction(interaction);
  }

  return null;
}

Map<String, dynamic>? _alarmToMap(Alarm alarm) {
  try {
    return Map<String, dynamic>.from(alarm.toJson());
  } catch (_) {}
  return null;
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  try {
    final json = (value as dynamic).toJson();
    if (json is Map<String, dynamic>) return json;
    if (json is Map) return Map<String, dynamic>.from(json);
  } catch (_) {}
  return null;
}

String? _speciesLabelFromAlarm(Alarm alarm) {
  return _speciesFromMap(_asMap(alarm.detection), const {}) ??
      _speciesFromMap(_asMap(alarm.interaction), const {}) ??
      _speciesLabelFromAnimal(alarm);
}

String? _speciesLabelFromAnimal(Alarm alarm) {
  final species = alarm.animal?.species;
  final name = species?.name?.trim();
  if (name != null && name.isNotEmpty) return name;
  final animalName = alarm.animal?.name.trim() ?? '';
  if (animalName.isNotEmpty) return animalName;
  return null;
}

String? _speciesFromMap(Map<String, dynamic>? map, Map<String, String> _) {
  if (map == null) return null;
  final speciesNode = map['species'];
  if (speciesNode is Map) {
    final speciesMap = speciesNode is Map<String, dynamic>
        ? speciesNode
        : Map<String, dynamic>.from(speciesNode);
    for (final key in const ['commonName', 'common_name', 'name', 'label']) {
      final value = speciesMap[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
  }
  for (final key in const ['speciesName', 'label']) {
    final value = map[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}

DetectionPin? _detectionPinFromMap(Map<String, dynamic> map) {
  try {
    return DetectionPin.fromJson(map);
  } catch (_) {
    final id = _firstString(map, const ['id', 'ID', 'detectionID']);
    final loc = PreferredReportLocation.mapForDisplay(map);
    if (id == null || loc == null) return null;
    final lat = _asDouble(loc['latitude'] ?? loc['lat']);
    final lon = _asDouble(loc['longitude'] ?? loc['lon']);
    if (lat == null || lon == null) return null;
    final ts = extractEventTimestampFromMap(map);
    return DetectionPin(
      id: id,
      lat: lat,
      lon: lon,
      detectedAt: parseBackendTimestampToUtc(ts),
      type: map['type']?.toString(),
      deviceType: map['deviceType']?.toString(),
      label: _speciesFromMap(map, const {}),
    );
  }
}

InteractionQueryResult? _interactionFromMap(
  Map<String, dynamic> map, {
  String? speciesFallback,
}) {
  try {
    return InteractionQueryResult.fromJson(map);
  } catch (_) {
    final id = _firstString(map, const ['id', 'ID']);
    final loc = PreferredReportLocation.mapForDisplay(map);
    if (id == null || loc == null) return null;
    final lat = _asDouble(loc['latitude'] ?? loc['lat']);
    final lon = _asDouble(loc['longitude'] ?? loc['lon']);
    if (lat == null || lon == null) return null;
    final momentRaw = extractEventTimestampFromMap(map);
    final speciesNode = _asMap(map['species']);
    final speciesName = speciesFallback ??
        speciesNode?['commonName']?.toString() ??
        speciesNode?['name']?.toString();
    final typeNode = _asMap(map['type']) ?? _asMap(map['interactionType']);
    return InteractionQueryResult(
      id: id,
      lat: lat,
      lon: lon,
      moment: parseBackendTimestampToUtc(momentRaw),
      typeName: typeNode?['name']?.toString(),
      speciesName: speciesName,
      description: map['description']?.toString() ?? map['notes']?.toString(),
    );
  }
}

String? _firstString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}

double? _asDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
