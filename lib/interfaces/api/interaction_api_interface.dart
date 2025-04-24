import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/models/beta_models/interaction_model.dart';

abstract class InteractionApiInterface {
  Future<Questionnaire> sendInteraction(Interaction interaction);
}