import 'package:wildrapport/models/api_models/interaction_type.dart';

abstract class InteractionTypeApiInterface {
  Future<List<InteractionType>> getAllInteractionTypes();
}
