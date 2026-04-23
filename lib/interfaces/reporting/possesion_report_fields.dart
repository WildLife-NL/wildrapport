import 'package:wildrapport/interfaces/reporting/common_report_fields.dart';
import 'package:wildrapport/models/beta_models/possesion_model.dart';

abstract class PossesionReportFields extends CommonReportFields {
  Possesion get possesion;
  double get currentImpactDamages;
  double get estimatedTotalDamages;
  String get estimatedLossBucket;
  String get impactedAreaType;
  double get impactedArea;
  bool get preventiveMeasures;
  String get preventiveMeasuresDescription;
}
