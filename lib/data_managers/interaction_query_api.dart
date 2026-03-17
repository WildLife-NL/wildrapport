import 'package:flutter/foundation.dart';
import 'package:wildrapport/interfaces/data_apis/interaction_query_api_interface.dart';
import 'package:wildrapport/models/api_models/interaction_query_result.dart';
import 'package:wildlifenl_interaction_components/wildlifenl_interaction_components.dart';

class InteractionQueryApi implements InteractionQueryApiInterface {
  InteractionQueryApi(this._api);

  final InteractionReadApiInterface _api;

  @override
  Future<List<InteractionQueryResult>> queryInteractions({
    required double areaLatitude,
    required double areaLongitude,
    required int areaRadiusMeters,
    DateTime? momentAfter,
    DateTime? momentBefore,
  }) async {
    final list = await _api.queryInteractions(
      areaLatitude: areaLatitude,
      areaLongitude: areaLongitude,
      areaRadiusMeters: areaRadiusMeters,
      momentAfter: momentAfter,
      momentBefore: momentBefore,
    );
    debugPrint('[InteractionQueryApi] Got ${list.length} interactions');
    return list.map(InteractionQueryResult.fromJson).toList();
  }
}
