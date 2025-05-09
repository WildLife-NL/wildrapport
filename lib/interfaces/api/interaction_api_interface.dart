import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/models/beta_models/interaction_model.dart';
import 'package:wildrapport/models/beta_models/interaction_response_model.dart';

abstract class InteractionApiInterface {
  Future<Questionnaire> sendInteractionDeprecated(Interaction interaction); //Deprecated!
  Future<InteractionResponse> sendInteraction(Interaction interaction);
}