import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/interfaces/data_apis/vicinity_api_interface.dart';
import 'package:wildrapport/models/api_models/vicinity.dart';

class VicinityApi implements VicinityApiInterface {
  final ApiClient apiClient;
  VicinityApi(this.apiClient);

  /// Candidate paths (server/OpenAPI variants). First match wins.
  static const List<String> _vicinityPaths = [
    'vicinity/me',
    '/vicinity/me',
    'vicinity/me/',
    '/vicinity/me/',
  ];

  /// Unwraps `{ animals, ... }` or `{ vicinity: { animals, ... } }`.
  static Map<String, dynamic> unwrapVicinityPayload(Map<String, dynamic> data) {
    final nested = data['vicinity'];
    if (nested is Map<String, dynamic>) {
      debugPrint('[VicinityApi] Using nested "vicinity" object from response');
      return nested;
    }
    return data;
  }

  static bool _looksLikeHtml(String body) {
    final trimmed = body.trimLeft().toLowerCase();
    return trimmed.startsWith('<!doctype') ||
        trimmed.startsWith('<html') ||
        trimmed.startsWith('<!');
  }

  static Vicinity _parseVicinityBody(String body) {
    if (body.isEmpty) {
      return Vicinity(animals: [], detections: [], interactions: []);
    }
    if (_looksLikeHtml(body)) {
      throw FormatException(
        'Server returned HTML instead of JSON (wrong URL or gateway page). '
        'Check DEV_BASE_URL and vicinity path with backend.',
      );
    }

    final decoded = json.decode(body);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException(
        'Vicinity GET: expected JSON object, got ${decoded.runtimeType}',
      );
    }

    final data = unwrapVicinityPayload(decoded);
    debugPrint(
      '[VicinityApi] Parsed JSON - animals: ${(data['animals'] as List?)?.length ?? 0}, '
      'detections: ${(data['detections'] as List?)?.length ?? 0}, '
      'interactions: ${(data['interactions'] as List?)?.length ?? 0}',
    );

    return Vicinity.fromJson(data);
  }

  @override
  Future<Vicinity> getMyVicinity() async {
    Object? lastError;

    for (final path in _vicinityPaths) {
      try {
        final res = await apiClient.get(path, authenticated: true);
        debugPrint('[VicinityApi] GET $path => ${res.statusCode}');

        if (res.statusCode == 204) {
          debugPrint('[VicinityApi] 204 No Content, returning empty vicinity');
          return Vicinity(animals: [], detections: [], interactions: []);
        }

        if (res.statusCode == 200) {
          final body = res.body.trim();
          debugPrint('[VicinityApi] Response body length: ${body.length}');
          if (_looksLikeHtml(body)) {
            debugPrint(
              '[VicinityApi] $path returned HTML (not JSON) — endpoint likely missing on server',
            );
            lastError = 'HTML response on $path';
            continue;
          }
          if (body.isNotEmpty) {
            debugPrint(
              '[VicinityApi] Raw response: '
              '${body.substring(0, body.length > 500 ? 500 : body.length)}...',
            );
          }
          final vicinity = _parseVicinityBody(body);
          debugPrint(
            '[VicinityApi] OK via $path — '
            'animals: ${vicinity.animals.length}, '
            'detections: ${vicinity.detections.length}, '
            'interactions: ${vicinity.interactions.length}',
          );
          return vicinity;
        }

        if (res.statusCode == 404) {
          debugPrint('[VicinityApi] 404 on $path, trying next path');
          lastError = '404 on $path';
          continue;
        }

        lastError = 'HTTP ${res.statusCode} on $path: ${res.body}';
        debugPrint('[VicinityApi] $lastError');
      } catch (e) {
        lastError = e;
        debugPrint('[VicinityApi] Failed $path: $e');
      }
    }

    throw Exception(
      'Vicinity GET failed on all paths ($_vicinityPaths). Last error: $lastError',
    );
  }
}
