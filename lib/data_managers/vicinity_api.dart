import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:ntp_dart/ntp_dart.dart';
import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/interfaces/data_apis/vicinity_api_interface.dart';
import 'package:wildrapport/models/api_models/vicinity.dart';
import 'package:wildrapport/utils/tracking_vicinity_parser.dart';

class VicinityApi implements VicinityApiInterface {
  VicinityApi(this.apiClient);

  final ApiClient apiClient;

  static const String _tag = 'VicinityApi';
  static const String _getMyReadingsPath = '/tracking-readings/me/';
  static const String _postReadingPath = '/tracking-reading/';

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
  Future<Vicinity> getMyVicinity() async {
    final res = await apiClient.get(_getMyReadingsPath, authenticated: true);
    TrackingVicinityParser.logHttpResponse(
      tag: _tag,
      endpoint: 'GET $_getMyReadingsPath',
      statusCode: res.statusCode,
      body: res.body,
    );

    if (res.statusCode == 204) {
      return TrackingVicinityParser.empty();
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        '[$_tag] GET $_getMyReadingsPath failed (${res.statusCode}): ${res.body}',
      );
    }

    final decoded = _decodeBody(res.body);
    final vicinity = TrackingVicinityParser.parseResponseBody(
      res.body,
      tag: _tag,
      endpoint: 'GET $_getMyReadingsPath',
    );

    if (decoded is List) {
      final latest = TrackingVicinityParser.latestReadingMap(decoded);
      if (latest != null) {
        final loc = TrackingVicinityParser.readingLocation(latest);
        if (loc != null) {
          return TrackingVicinityParser.filterNearReading(
            vicinity,
            loc.latitude,
            loc.longitude,
            tag: _tag,
          );
        }
      }
    }

    return vicinity;
  }

  @override
  Future<Vicinity> getVicinityForCurrentLocation({
    required double latitude,
    required double longitude,
    DateTime? timestamp,
  }) =>
      submitTrackingReading(
        latitude: latitude,
        longitude: longitude,
        timestamp: timestamp,
      );

  @override
  Future<Vicinity> submitTrackingReading({
    required double latitude,
    required double longitude,
    DateTime? timestamp,
  }) async {
    var ts = (timestamp ?? DateTime.now()).toUtc();
    final nowUtc = await _nowUtc();
    if (!ts.isBefore(nowUtc)) {
      ts = nowUtc.subtract(const Duration(seconds: 30));
      debugPrint(
        '[$_tag] clamped timestamp to ${ts.toIso8601String()}',
      );
    }

    final body = {
      'location': {'latitude': latitude, 'longitude': longitude},
      'timestamp': ts.toIso8601String(),
    };

    final res = await apiClient.post(
      _postReadingPath,
      body,
      authenticated: true,
    );

    TrackingVicinityParser.logHttpResponse(
      tag: _tag,
      endpoint: 'POST $_postReadingPath',
      statusCode: res.statusCode,
      body: res.body,
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        '[$_tag] POST $_postReadingPath failed (${res.statusCode}): ${res.body}',
      );
    }

    final vicinity = TrackingVicinityParser.parseResponseBody(
      res.body,
      tag: _tag,
      endpoint: 'POST $_postReadingPath',
    );

    return TrackingVicinityParser.filterNearReading(
      vicinity,
      latitude,
      longitude,
      tag: _tag,
    );
  }

  Object? _decodeBody(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }
}
