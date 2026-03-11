import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class ApiClient {
  static const String _tokenKey = 'bearer_token';

  static const Duration _requestTimeout = Duration(seconds: 30);

  final String baseUrl;

  ApiClient(this.baseUrl);

  Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
    bool authenticated = true,
  }) async {
    headers = await _buildHeaders(headers, authenticated);
    final uri = _buildUri(url);
    print("GET: $uri");
    return await http.get(uri, headers: headers).timeout(_requestTimeout);
  }

  Future<http.Response> post(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    bool authenticated = true,
  }) async {
    headers = await _buildHeaders(headers, authenticated);
    final uri = _buildUri(url);
    final cleanedBody = _removeNulls(body);
    http.Response response = await http
        .post(uri, body: jsonEncode(cleanedBody), headers: headers)
        .timeout(_requestTimeout);

    return response;
  }

  Future<http.Response> put(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    bool authenticated = true,
  }) async {
    headers = await _buildHeaders(headers, authenticated);
    final uri = _buildUri(url);
    final cleanedBody = _removeNulls(body);
    return await http
        .put(uri, body: jsonEncode(cleanedBody), headers: headers)
        .timeout(_requestTimeout);
  }

  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
    bool authenticated = true,
  }) async {
    headers = await _buildHeaders(headers, authenticated);
    final uri = _buildUri(url);
    print("DELETE: $uri");
    return await http.delete(uri, headers: headers).timeout(_requestTimeout);
  }

  Future<http.Response> patch(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    bool authenticated = true,
  }) async {
    headers = await _buildHeaders(headers, authenticated);
    final uri = _buildUri(url);
    final cleanedBody = _removeNulls(body);
    return await http
        .patch(uri, body: jsonEncode(cleanedBody), headers: headers)
        .timeout(_requestTimeout);
  }

  Future<Map<String, String>> _buildHeaders(
    Map<String, String>? headers,
    bool authenticated,
  ) async {
    final Map<String, String> defaultHeaders = {
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    if (authenticated) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(_tokenKey);
      defaultHeaders[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }
    return defaultHeaders;
  }

  /// Recursively removes null values from maps and nested structures.
  /// APIs often reject payloads with null (e.g. 422 Unprocessable Entity).
  static Map<String, dynamic> _removeNulls(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    for (final entry in map.entries) {
      final value = entry.value;
      if (value == null) continue;
      if (value is Map<String, dynamic>) {
        result[entry.key] = _removeNulls(value);
      } else if (value is List) {
        result[entry.key] = value
            .map((e) => e is Map<String, dynamic> ? _removeNulls(e) : e)
            .where((e) => e != null)
            .toList();
      } else {
        result[entry.key] = value;
      }
    }
    return result;
  }

  Uri _buildUri(String url) {
    try {
      final base = Uri.parse(baseUrl);
      return base.resolve(url);
    } catch (e) {
      return Uri.parse('$baseUrl/$url');
    }
  }
}
