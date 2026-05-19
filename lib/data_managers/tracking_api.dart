import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ntp_dart/ntp_dart.dart';
import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/interfaces/data_apis/tracking_api_interface.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_pin.dart';
import 'package:wildrapport/models/api_models/detection_pin.dart';
import 'package:wildrapport/models/api_models/interaction_query_result.dart';
import 'package:wildrapport/models/api_models/vicinity.dart';

class TrackingApi implements TrackingApiInterface {
  final ApiClient client;
  TrackingApi(this.client);

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

  static Vicinity? _vicinityFromTrackingJson(Map<String, dynamic> decoded) {
    if (decoded['vicinity'] is Map<String, dynamic>) {
      return Vicinity.fromJson(decoded['vicinity'] as Map<String, dynamic>);
    }
    if (decoded['animals'] != null ||
        decoded['detections'] != null ||
        decoded['interactions'] != null) {
      return Vicinity.fromJson(decoded);
    }
    return null;
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

    if (res.statusCode < 200 || res.statusCode >= 300) {
      debugPrint('[TrackingApi] Response status: ${res.statusCode}');
      debugPrint('[TrackingApi] ERROR - Status ${res.statusCode}: ${res.body}');
      throw Exception('[TrackingApi] Failed (${res.statusCode}): ${res.body}');
    }

    try {
      final Map<String, dynamic> decoded = jsonDecode(res.body);
      final vicinity = _vicinityFromTrackingJson(decoded);

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

    debugPrint(
      '[TrackingApi] GET /tracking-readings/me/ => ${res.statusCode}',
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
    final animalIds = <String>{};
    final detectionIds = <String>{};
    final interactionIds = <String>{};
    final animals = <AnimalPin>[];
    final detections = <DetectionPin>[];
    final interactions = <InteractionQueryResult>[];

    for (final reading in readings) {
      final v = reading.vicinity;
      if (v == null) continue;
      for (final a in v.animals) {
        if (animalIds.add(a.id)) {
          animals.add(a);
        }
      }
      for (final d in v.detections) {
        if (detectionIds.add(d.id)) {
          detections.add(d);
        }
      }
      for (final i in v.interactions) {
        if (interactionIds.add(i.id)) {
          interactions.add(i);
        }
      }
    }

    debugPrint(
      '[TrackingApi] Merged vicinity from ${readings.length} tracking readings: '
      '${animals.length} animals, ${detections.length} detections, '
      '${interactions.length} interactions',
    );

    return Vicinity(
      animals: animals,
      detections: detections,
      interactions: interactions,
    );
  }
}
