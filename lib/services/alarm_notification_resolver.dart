import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wildrapport/data_managers/alarms_api.dart';
import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildlifenl_alarms_components/wildlifenl_alarms_components.dart';

/// Resolves FCM payloads that only contain an alarm UUID into human-readable text.
class AlarmNotificationResolver {
  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static final RegExp _alarmIdInText = RegExp(
    r'alarmID:\s*([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})',
    caseSensitive: false,
  );

  static bool looksLikeAlarmIdOnly(String text) {
    final t = text.trim();
    if (t.isEmpty) return false;
    if (_alarmIdInText.hasMatch(t)) return true;
    return _uuidPattern.hasMatch(t);
  }

  /// Reads alarm id from FCM [data] and/or notification body.
  static String? extractAlarmId(Map<String, dynamic> data, String body) {
    for (final key in [
      'alarmID',
      'alarmId',
      'alarm_id',
      'alarm',
      'ID',
      'id',
    ]) {
      final value = data[key]?.toString().trim();
      if (value != null && value.isNotEmpty && _uuidPattern.hasMatch(value)) {
        return value;
      }
    }

    final fromBody = _alarmIdInText.firstMatch(body.trim());
    if (fromBody != null) {
      return fromBody.group(1);
    }

    final trimmed = body.trim();
    if (_uuidPattern.hasMatch(trimmed)) {
      return trimmed;
    }

    return null;
  }

  static Future<({String title, String body})?> resolve({
    required Map<String, dynamic> data,
    required String fallbackTitle,
    required String fallbackBody,
  }) async {
    final alarmId = extractAlarmId(data, fallbackBody);
    if (alarmId == null) {
      if (!looksLikeAlarmIdOnly(fallbackBody)) return null;
      debugPrint('[AlarmResolver] Body looks like alarm id but could not parse');
      return null;
    }

    try {
      await _ensureEnvLoaded();
      final baseUrl = (dotenv.env['DEV_BASE_URL'] ?? '').trim();
      if (baseUrl.isEmpty) {
        debugPrint('[AlarmResolver] DEV_BASE_URL missing');
        return null;
      }

      final details = await _fetchAlarmDetails(ApiClient(baseUrl), alarmId);
      if (details == null) {
        debugPrint('[AlarmResolver] Alarm $alarmId not found via API');
        return null;
      }

      final formatted = formatAlarmNotification(
        details.alarm,
        rawJson: details.raw,
      );
      debugPrint(
        '[AlarmResolver] Resolved alarm $alarmId → "${formatted.title}" / '
        '"${formatted.body}"',
      );
      return formatted;
    } catch (e) {
      debugPrint('[AlarmResolver] Failed to resolve alarm $alarmId: $e');
      return null;
    }
  }

  /// Builds notification title/body from alarm + conveyances (`message.name`, `severity`, `text`).
  static ({String title, String body}) formatAlarmNotification(
    Alarm alarm, {
    Map<String, dynamic>? rawJson,
  }) {
    final zoneName = alarm.zone.name?.trim();
    final zoneLabel =
        (zoneName != null && zoneName.isNotEmpty) ? zoneName : 'je zone';

    final conveyanceLines = _conveyanceLinesFromAlarm(alarm, rawJson);
    if (conveyanceLines.isNotEmpty) {
      return (
        title: 'Alarm: $zoneLabel',
        body: conveyanceLines.join('\n'),
      );
    }

    final speciesName = _speciesLabel(alarm);
    String body;
    if (speciesName != null) {
      body = 'Er is een $speciesName gemeld in $zoneLabel.';
    } else if (alarm.detection != null) {
      body = 'Er is een detectie in $zoneLabel.';
    } else if (alarm.interaction != null) {
      body = 'Er is een interactie in $zoneLabel.';
    } else {
      body = 'Er is activiteit in $zoneLabel.';
    }

    return (title: 'Alarm: $zoneLabel', body: body);
  }

  static List<String> _conveyanceLinesFromAlarm(
    Alarm alarm,
    Map<String, dynamic>? rawJson,
  ) {
    if (rawJson != null) {
      final rawList = rawJson['conveyances'];
      if (rawList is List) {
        final lines = <String>[];
        for (final item in rawList) {
          if (item is Map<String, dynamic>) {
            final line = _formatConveyanceFromJson(item);
            if (line.isNotEmpty) lines.add(line);
          } else if (item is Map) {
            final line = _formatConveyanceFromJson(Map<String, dynamic>.from(item));
            if (line.isNotEmpty) lines.add(line);
          }
        }
        if (lines.isNotEmpty) return lines;
      }
    }

    return alarm.conveyances
        .map(_formatConveyanceFromModel)
        .where((line) => line.isNotEmpty)
        .toList();
  }

  /// OpenAPI: `message.name`, `message.severity`, `message.text` (fallback: title/body).
  static String _formatConveyanceFromJson(Map<String, dynamic> conveyance) {
    final message = conveyance['message'];
    if (message is! Map) return '';
    final msg = message is Map<String, dynamic>
        ? message
        : Map<String, dynamic>.from(message);

    final name = _readString(msg, ['name', 'title']);
    final text = _readString(msg, ['text', 'body']);
    final severityLabel = _severityLabelFromValue(msg['severity']);

    return _joinConveyanceParts(name: name, severity: severityLabel, text: text);
  }

  static String _formatConveyanceFromModel(AlarmConveyance conveyance) {
    final msg = conveyance.message;
    final name = msg.title?.trim();
    final text = msg.body?.trim();
    return _joinConveyanceParts(name: name, severity: null, text: text);
  }

  static String _joinConveyanceParts({
    String? name,
    String? severity,
    String? text,
  }) {
    final parts = <String>[];
    if (name != null && name.isNotEmpty) parts.add(name);
    if (severity != null && severity.isNotEmpty) parts.add(severity);
    if (text != null && text.isNotEmpty) parts.add(text);
    return parts.join(' · ');
  }

  static String? _readString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static String? _severityLabelFromValue(Object? severity) {
    if (severity == null) return null;
    final level = severity is num ? severity.toInt() : int.tryParse('$severity');
    if (level == null) return null;
    return switch (level) {
      1 => 'Waarschuwing',
      2 => 'Melding',
      _ => 'Informatie',
    };
  }

  static String? _speciesLabel(Alarm alarm) {
    final species = alarm.animal?.species;
    final name = species?.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    final animalName = alarm.animal?.name.trim();
    if (animalName != null && animalName.isNotEmpty) return animalName;
    return null;
  }

  static Future<void> _ensureEnvLoaded() async {
    if ((dotenv.env['DEV_BASE_URL'] ?? '').trim().isNotEmpty) return;
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('[AlarmResolver] dotenv load failed: $e');
    }
  }

  static Future<({Alarm alarm, Map<String, dynamic> raw})?> _fetchAlarmDetails(
    ApiClient client,
    String alarmId,
  ) async {
    final adapter = AlarmsApiClientAdapter(client);
    final api = AlarmsApi(adapter);

    for (final path in [
      'alarms/$alarmId/',
      'alarms/$alarmId',
      'alarm/$alarmId/',
    ]) {
      try {
        final res = await client.get(path, authenticated: true);
        if (res.statusCode == 200 && res.body.trim().isNotEmpty) {
          final decoded = jsonDecode(res.body);
          if (decoded is Map<String, dynamic>) {
            return (alarm: Alarm.fromJson(decoded), raw: decoded);
          }
          if (decoded is Map) {
            final map = Map<String, dynamic>.from(decoded);
            return (alarm: Alarm.fromJson(map), raw: map);
          }
        }
      } catch (_) {}
    }

    try {
      final mine = await api.getMyAlarms();
      for (final alarm in mine) {
        if (alarm.id == alarmId) {
          return (alarm: alarm, raw: alarm.toJson());
        }
      }
    } catch (e) {
      debugPrint('[AlarmResolver] getMyAlarms failed: $e');
    }

    return null;
  }
}
