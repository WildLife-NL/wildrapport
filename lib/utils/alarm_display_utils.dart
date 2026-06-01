import 'package:wildrapport/utils/api_datetime.dart';
import 'package:wildrapport/utils/event_timestamp_extractor.dart';
import 'package:wildlifenl_alarms_components/wildlifenl_alarms_components.dart';

/// When the underlying detection/interaction happened.
String? alarmEventTimestampRaw(Alarm alarm) => extractEventTimestampFromAlarm(alarm);

String formatAlarmTimestamp(String timestamp) {
  final dt = tryParseBackendTimestampToUtc(timestamp);
  if (dt == null) return '—';
  final local = toLocalWallClock(dt);
  return _formatLocalDateTime(local);
}

String formatAlarmEventTime(Alarm alarm) {
  final raw = alarmEventTimestampRaw(alarm);
  if (raw == null || raw.isEmpty) return '—';
  return formatAlarmTimestamp(raw);
}

String _formatLocalDateTime(DateTime local) {
  const weekdays = ['ma', 'di', 'wo', 'do', 'vr', 'za', 'zo'];
  final weekday = weekdays[local.weekday - 1];
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  return '$weekday $day-$month-${local.year}, $h:$m';
}

String? speciesDisplayName(
  Alarm alarm,
  Map<String, String> speciesCommonNames,
) {
  final fromAnimal = _speciesFromAnimal(alarm, speciesCommonNames);
  if (fromAnimal != null) return fromAnimal;

  final fromDetection = _speciesFromMap(alarm.detection, speciesCommonNames);
  if (fromDetection != null) return fromDetection;

  final fromInteraction = _speciesFromMap(alarm.interaction, speciesCommonNames);
  if (fromInteraction != null) return fromInteraction;

  final animalName = alarm.animal?.name.trim();
  if (animalName != null && animalName.isNotEmpty) return animalName;

  return null;
}

String? _speciesFromAnimal(
  Alarm alarm,
  Map<String, String> speciesCommonNames,
) {
  final species = alarm.animal?.species;
  if (species == null) return null;

  final id = species.id?.trim();
  if (id != null && id.isNotEmpty) {
    final common = speciesCommonNames[id];
    if (common != null && common.isNotEmpty) return common;
  }

  final name = species.name?.trim();
  if (name != null && name.isNotEmpty) return name;
  return null;
}

String? _speciesFromMap(
  Map<dynamic, dynamic>? map,
  Map<String, String> speciesCommonNames,
) {
  if (map == null) return null;

  final speciesNode = map['species'];
  if (speciesNode is Map) {
    final speciesMap = Map<String, dynamic>.from(speciesNode);
    final id = (speciesMap['ID'] ?? speciesMap['id'])?.toString().trim();
    if (id != null && id.isNotEmpty) {
      final common = speciesCommonNames[id];
      if (common != null && common.isNotEmpty) return common;
    }
    for (final key in const ['commonName', 'common_name', 'name', 'label']) {
      final value = speciesMap[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
  }

  for (final key in const ['speciesName', 'speciesLabel', 'label']) {
    final value = map[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }

  return null;
}

String defaultAlarmSummary(
  Alarm alarm,
  Map<String, String> speciesCommonNames,
) {
  final zoneName = alarm.zone.name ?? 'je zone';
  final speciesName = speciesDisplayName(alarm, speciesCommonNames);
  if (speciesName != null) {
    return 'Er is een $speciesName in je $zoneName.';
  }
  if (alarm.detection != null) return 'Er is een detectie in je $zoneName.';
  if (alarm.interaction != null) return 'Er is een interactie in je $zoneName.';
  return 'Er is activiteit in je $zoneName.';
}

String eventTypeLabel(Alarm alarm) {
  final parts = <String>[];
  if (alarm.detection != null) parts.add('Detectie');
  if (alarm.interaction != null) parts.add('Interactie');
  if (parts.isEmpty) return '—';
  return parts.join(', ');
}

bool conveyanceHasText(AlarmConveyance conveyance) {
  final title = conveyance.message.title?.trim();
  final body = conveyance.message.body?.trim();
  return (title != null && title.isNotEmpty) ||
      (body != null && body.isNotEmpty);
}

List<AlarmConveyance> conveyancesWithText(Alarm alarm) {
  return alarm.conveyances.where(conveyanceHasText).toList();
}
