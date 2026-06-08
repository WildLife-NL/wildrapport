import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wildrapport/data_managers/alarms_api.dart';
import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/utils/alarm_display_utils.dart';
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

    return (
      title: 'Alarm: $zoneLabel',
      body: defaultAlarmSummary(alarm, const {}),
    );
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
