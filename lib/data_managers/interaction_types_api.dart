import 'dart:convert';
import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/interfaces/data_apis/interaction_types_api_interface.dart';
import 'package:wildrapport/models/api_models/interaction_type.dart';
import 'package:flutter/foundation.dart';

class InteractionTypesApi implements InteractionTypesApiInterface {
  final ApiClient apiClient;
  InteractionTypesApi(this.apiClient);

  @override
  Future<List<InteractionType>> getAllInteractionTypes() async {
    // Fallback types in case API fails
    final fallbackTypes = [
      InteractionType(id: 1, name: 'Waarneming', description: 'Waarneming van dieren'),
      InteractionType(id: 2, name: 'Schademelding', description: 'Rapportage van schade'),
      InteractionType(id: 3, name: 'Dieraanrijding', description: 'Dieraanrijding'),
    ];

    // Attempt to get interaction types from server. The exact endpoint
    // may vary across deployments; try a reasonable path and return an
    // empty list on non-200/204 responses.
    const path = 'interactionTypes/';
    try {
      final res = await apiClient.get(path, authenticated: false);
      debugPrint('[InteractionTypesApi] GET $path => ${res.statusCode}');
      if (res.statusCode == 200) {
        final body = res.body.trim();
        if (body.isEmpty) return fallbackTypes;
        final decoded = json.decode(body);
        final List list =
            decoded is List
                ? decoded
                : (decoded is Map && decoded['items'] is List)
                ? decoded['items']
                : const [];
        return list
            .whereType<Map<String, dynamic>>()
            .map(InteractionType.fromJson)
            .toList();
      }
      if (res.statusCode == 204 || res.statusCode == 404) return fallbackTypes;
    } catch (e) {
      debugPrint('[InteractionTypesApi] Error fetching types: $e');
    }

    return fallbackTypes;
  }
}
