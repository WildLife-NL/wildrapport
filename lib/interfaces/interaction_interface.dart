import 'package:wildrapport/interfaces/reporting/reportable_interface.dart';
import 'package:wildrapport/models/beta_models/interaction_response_model.dart';

abstract class InteractionInterface {
  Future<InteractionResponseModel?> postInteraction(Reportable report);
}