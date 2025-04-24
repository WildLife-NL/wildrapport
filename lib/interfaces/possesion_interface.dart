import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/models/beta_models/possesion_damage_report_model.dart';

abstract class PossesionInterface{
  List<dynamic> buildPossesionWidgetList();
  Future<Questionnaire> postInteraction(PossesionDamageReport possesionDamageReport);
}