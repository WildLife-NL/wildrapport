import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:ntp_dart/ntp_dart.dart';
import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/interfaces/data_apis/tracking_api_interface.dart';
import 'package:wildrapport/models/api_models/vicinity.dart';
import 'package:wildrapport/utils/tracking_vicinity_parser.dart';

class TrackingApi implements TrackingApiInterface {
  TrackingApi(this.client);

  final ApiClient client;

  static const Duration _mapVicinityMaxReadingAge = Duration(hours: 48);

  Future<DateTime> _nowUtc() async {
    try {
      return await AccurateTime.now(isUtc: true).timeout(
        const Duration(seconds: 3),
        onTimeout: () => DateTime.now().toUtc(),
      );
    } catch (_) {
      return DateTime.now().toUtc();
    }
  }

  @override
  Future<TrackingNotice?> addTrackingReading({
    required double lat,
    required double lon,
    required DateTime timestampUtc,
  }) async {
    var ts = timestampUtc.toUtc();
    final nowUtc = await _nowUtc();
    if (!ts.isBefore(nowUtc)) {
      ts = nowUtc.subtract(const Duration(seconds: 30));
      debugPrint(
        '[TrackingApi] Clamped timestamp to avoid "must be before now" '
        '(was ${timestampUtc.toUtc().toIso8601String()})',
      );
    }

    final body = {
      'location': {'latitude': lat, 'longitude': lon},
      'timestamp': ts.toIso8601String(),
    };

    final res = await client.post(
      '/tracking-reading/',
      body,
      authenticated: true,
    );

    TrackingVicinityParser.logHttpResponse(
      tag: 'TrackingApi',
      endpoint: 'POST /tracking-reading/',
      statusCode: res.statusCode,
      body: res.body,
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      debugPrint('[TrackingApi] ERROR - Status ${res.statusCode}: ${res.body}');
      throw Exception('[TrackingApi] Failed (${res.statusCode}): ${res.body}');
    }

    try {
      final Map<String, dynamic> decoded = jsonDecode(res.body);
      final vicinity = TrackingVicinityParser.vicinityFromReadingJson(decoded);

      final conv = decoded['conveyance'];
      final msgObj = conv is Map ? conv['message'] : null;

      final msgText1 = (msgObj is Map ? msgObj['text'] : null)?.toString();
      final sev1 =
          msgObj is Map && msgObj['severity'] is num
              ? (msgObj['severity'] as num).toInt()
              : null;

      if ((msgText1 != null && msgText1.isNotEmpty) || vicinity != null) {
        debugPrint('[TrackingApi] Message received: "$msgText1"');
        return TrackingNotice(
          msgText1 ?? '',
          severity: sev1,
          vicinity: vicinity,
        );
      }
    } catch (e) {
      debugPrint('[TrackingApi] Error parsing POST response: $e');
    }

    return null;
  }

  @override
  Future<List<TrackingReadingResponse>> getMyTrackingReadings() async {
    final res = await client.get('/tracking-readings/me/', authenticated: true);

    TrackingVicinityParser.logHttpResponse(
      tag: 'TrackingApi',
      endpoint: 'GET /tracking-readings/me/',
      statusCode: res.statusCode,
      body: res.body,
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('[TrackingApi] Failed (${res.statusCode}): ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! List) {
      throw FormatException(
        'Expected JSON array from /tracking-readings/me/, got ${decoded.runtimeType}',
      );
    }

    return decoded
        .whereType<Map>()
        .map((e) => TrackingReadingResponse.fromJson(
              Map<String, dynamic>.from(e),
            ))
        .toList();
  }

  @override
  Future<Vicinity> getMergedVicinityFromMyTrackingReadings() async {
    final readings = await getMyTrackingReadings();
    if (readings.isEmpty) {
      return TrackingVicinityParser.empty();
    }

    final cutoff = DateTime.now().toUtc().subtract(_mapVicinityMaxReadingAge);
    final parts = readings
        .where((r) => !r.timestamp.isBefore(cutoff))
        .map((r) => r.vicinity)
        .whereType<Vicinity>()
        .where(
          (v) =>
              v.animals.isNotEmpty ||
              v.detections.isNotEmpty ||
              v.interactions.isNotEmpty,
        );

    final merged = TrackingVicinityParser.mergeVicinities(parts);
    debugPrint(
      '[TrackingApi] Map vicinity merged from ${parts.length} reading(s): '
      '${merged.animals.length} animals, '
      '${merged.detections.length} detections, '
      '${merged.interactions.length} interactions',
    );
    return merged;
  }
}
