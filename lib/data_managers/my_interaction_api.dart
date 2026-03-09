import 'package:flutter/foundation.dart';
import 'package:wildrapport/models/api_models/my_interaction.dart';
import 'package:wildlifenl_interaction_components/wildlifenl_interaction_components.dart';

/// Gebruikt de interaction-component package voor GET interactions/me/.
class MyInteractionApi {
  MyInteractionApi(this._api);

  final InteractionReadApiInterface _api;

  /// Fetches the user's interaction history from the GET /interactions/me endpoint.
  Future<List<MyInteraction>> getMyInteractions() async {
    try {
      debugPrint('[MyInteractionApi]: Fetching my interactions');
      final list = await _api.getMyInteractions();
      debugPrint('[MyInteractionApi]: Fetched ${list.length} interactions');
      return list.map((e) => MyInteraction.fromJson(e)).toList();
    } catch (e) {
      debugPrint('[MyInteractionApi]: Error fetching interactions: $e');
      rethrow;
    }
  }
}
