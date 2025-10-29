import 'package:flutter/material.dart';
import 'package:wildrapport/interfaces/data_apis/interaction_type_api_interface.dart';
import 'package:wildrapport/models/api_models/interaction_type.dart';
import 'package:wildrapport/providers/interaction_type_provider.dart';

class InteractionTypeManager {
  final InteractionTypeApiInterface interactionTypeApi;
  final InteractionTypeProvider provider;

  InteractionTypeManager({
    required this.interactionTypeApi,
    required this.provider,
  });

  Future<void> loadInteractionTypes() async {
    try {
      debugPrint('[InteractionTypeManager] Loading interaction types...');
      provider.setLoading(true);
      
      final types = await interactionTypeApi.getAllInteractionTypes();
      
      debugPrint('[InteractionTypeManager] Loaded ${types.length} interaction types');
      provider.setInteractionTypes(types);
    } catch (e) {
      debugPrint('[InteractionTypeManager] Error loading interaction types: $e');
      provider.setError('Failed to load interaction types: $e');
    } finally {
      provider.setLoading(false);
    }
  }

  List<InteractionType> getInteractionTypes() {
    return provider.interactionTypes;
  }
}
