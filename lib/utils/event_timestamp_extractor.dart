import 'package:wildrapport/utils/api_datetime.dart';
import 'package:wildlifenl_alarms_components/wildlifenl_alarms_components.dart';

const _timestampKeys = [
  'moment',
  'detectedAt',
  'detected_at',
  'timestamp',
  'time',
  'created',
  'createdAt',
  'created_at',
  'dateTime',
  'datetime',
  'occurredAt',
  'occurred_at',
  'eventTime',
  'event_time',
  'readingTime',
  'reading_time',
];

const _nestedContainers = [
  'reportOfSighting',
  'reportOfCollision',
  'reportOfDamage',
  'detection',
  'interaction',
  'animal',
  'location',
  'place',
  'event',
  'trigger',
  'reading',
];

/// Best-effort event time for an alarm (when the detection/interaction happened).
String? extractEventTimestampFromAlarm(Alarm alarm) {
  final candidates = <String>[];

  void addCandidate(String? raw) {
    if (raw == null || raw.isEmpty) return;
    if (tryParseBackendTimestampToUtc(raw) == null) return;
    if (!candidates.contains(raw)) candidates.add(raw);
  }

  addCandidate(extractEventTimestampFromMap(alarm.detection));
  addCandidate(extractEventTimestampFromMap(alarm.interaction));

  final alarmTs = alarm.timestamp.trim();
  if (alarmTs.isNotEmpty) addCandidate(alarmTs);

  addCandidate(extractEventTimestampRaw(alarm.animal?.locationTimestamp));

  return candidates.isEmpty ? null : candidates.first;
}

/// Reads an event time from a detection/interaction map on an alarm.
String? extractEventTimestampFromMap(Map<dynamic, dynamic>? map) {
  if (map == null) return null;
  return _walkMap(Map<String, dynamic>.from(map), depth: 0);
}

/// Reads a timestamp from any JSON value (string, map, epoch number).
String? extractEventTimestampRaw(Object? raw, {int depth = 0}) {
  if (raw == null || depth > 6) return null;

  if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    final goTime = map['Time'] ?? map['time'];
    if (goTime != null) {
      final fromGo = extractEventTimestampRaw(goTime, depth: depth + 1);
      if (fromGo != null) return fromGo;
    }
    return _walkMap(map, depth: depth);
  }

  if (raw is List) {
    for (final item in raw) {
      final found = extractEventTimestampRaw(item, depth: depth + 1);
      if (found != null) return found;
    }
    return null;
  }

  if (raw is num) {
    return _epochNumToIso(raw);
  }

  final text = raw.toString().trim();
  if (text.isEmpty) return null;
  if (text.startsWith('{') || text.startsWith('Instance of')) return null;
  if (!_looksLikeTimestampString(text)) return null;
  if (tryParseBackendTimestampToUtc(text) == null) return null;
  return text;
}

String? _walkMap(Map<String, dynamic> map, {required int depth}) {
  if (depth > 6) return null;

  for (final key in _timestampKeys) {
    final found = _valueForKeyIgnoreCase(map, key);
    if (found != null) {
      final ts = extractEventTimestampRaw(found, depth: depth + 1);
      if (ts != null) return ts;
    }
  }

  for (final key in _nestedContainers) {
    final nested = _valueForKeyIgnoreCase(map, key);
    if (nested is Map) {
      final found = _walkMap(
        Map<String, dynamic>.from(nested),
        depth: depth + 1,
      );
      if (found != null) return found;
    }
  }

  for (final entry in map.entries) {
    final key = entry.key.toString();
    if (_isIdLikeKey(key)) continue;
    final found = extractEventTimestampRaw(entry.value, depth: depth + 1);
    if (found != null) return found;
  }

  return null;
}

Object? _valueForKeyIgnoreCase(Map<String, dynamic> map, String wanted) {
  final lower = wanted.toLowerCase();
  for (final entry in map.entries) {
    if (entry.key.toString().toLowerCase() == lower) return entry.value;
  }
  return null;
}

bool _isIdLikeKey(String key) {
  final lower = key.toLowerCase();
  if (lower == 'id' || lower.endsWith('id')) return true;
  if (lower.contains('uuid')) return true;
  return false;
}

String? _epochNumToIso(num value) {
  final n = value.toDouble();
  if (n < 1000000000) return null;
  final ms = n > 9999999999 ? n.toInt() : (n * 1000).toInt();
  return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toIso8601String();
}

bool _looksLikeTimestampString(String value) {
  if (RegExp(r'^\d{10,}$').hasMatch(value)) return true;
  if (!RegExp(r'\d{4}').hasMatch(value)) return false;
  return value.contains('T') ||
      value.contains('-') ||
      value.contains(':') ||
      value.contains(' ');
}
