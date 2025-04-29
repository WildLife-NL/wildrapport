import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/models/beta_models/possesion_damage_report_model.dart';
import 'package:wildrapport/models/beta_models/report_location_model.dart';

abstract class PossesionInterface{
  List<dynamic> buildPossesionWidgetList();
  Future<Questionnaire> postInteraction();
  void updateImpactedCrop(String value);
  void updateCurrentDamage(double value);
  void updateExpectedDamage(double value);
  void updateImpactedAreaType(String value);
  void updateImpactedArea(String value);
  void updateDescription(String value);
  void updateSuspectedAnimal(String value);
  void updateSystemLocation(ReportLocation value);
  void updateUserLocation(ReportLocation value);
  PossesionDamageReport buildPossionReport();
}