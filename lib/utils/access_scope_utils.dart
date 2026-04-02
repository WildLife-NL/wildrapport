import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:wildrapport/data_managers/api_client.dart';

class ScopeAccessResult {
  final bool checked;
  final Set<String> scopes;
  final bool hasRequiredScope;

  const ScopeAccessResult({
    required this.checked,
    required this.scopes,
    required this.hasRequiredScope,
  });
}

class AccessScopeUtils {
  static const Set<String> requiredScopes = {
    'land-user',
    'nature-area-manager',
    'wildlife-manager',
  };

  static Future<ScopeAccessResult> checkAuthorizeScopes(ApiClient apiClient) async {
    // Authorize endpoint is expected at this exact path.
    const candidates = ['Authorize', 'authorize'];

    for (final endpoint in candidates) {
      try {
        final response = await apiClient.get(endpoint, authenticated: true);
        if (response.statusCode < 200 || response.statusCode >= 300) {
          debugPrint(
            '[AccessScope] $endpoint returned ${response.statusCode}',
          );
          continue;
        }

        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          debugPrint('[AccessScope] $endpoint response is not a JSON object');
          continue;
        }

        final rawScopes = decoded['scopes'];
        if (rawScopes is! List) {
          debugPrint('[AccessScope] $endpoint response has no valid "scopes" array');
          continue;
        }

        final scopes = rawScopes
            .whereType<String>()
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toSet();
        final hasRequired = scopes.any(requiredScopes.contains);

        return ScopeAccessResult(
          checked: true,
          scopes: scopes,
          hasRequiredScope: hasRequired,
        );
      } catch (e) {
        debugPrint('[AccessScope] failed to check $endpoint: $e');
      }
    }

    return const ScopeAccessResult(
      checked: false,
      scopes: {},
      hasRequiredScope: false,
    );
  }
}
