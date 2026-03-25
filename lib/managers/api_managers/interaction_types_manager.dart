import 'package:flutter/foundation.dart';
import 'package:wildrapport/interfaces/data_apis/interaction_types_api_interface.dart';
import 'package:wildrapport/models/api_models/interaction_type.dart';

class InteractionTypesManager {
  final InteractionTypesApiInterface _api;
  List<InteractionType>? _cached;

  InteractionTypesManager(this._api);

  Future<List<InteractionType>> ensureFetched() async {
    if (_cached != null) return _cached!;
    try {
      _cached = await _api.getAllInteractionTypes();
      return _cached!;
    } catch (e) {
      debugPrint('[InteractionTypesManager] fetch error: $e');
      _cached = const [];
      return _cached!;
    }
  }

  String? nameForTypeId(int id) {
    if (_cached == null) return null;
    for (final t in _cached!) {
      if (t.id == id) return t.name;
    }
    return null;
  }
}
