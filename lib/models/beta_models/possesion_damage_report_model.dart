import 'package:wildrapport/models/beta_models/possesion.dart';
import 'package:wildrapport/models/beta_models/report_location.dart';

class PossesionDamageReport {
  final String? possesionDamageReportID;
  final Possesion possesion;
  final String impactedAreaType;
  final double impactedArea;
  final String currentImpactDamages;
  final String estimatedTotalDamages;
  final String? decription;
  final String? suspectedAnimalID;
  final ReportLocation? userSelectedLocation;
  final ReportLocation? systemLocation;
  final DateTime? userSelectedDateTime;
  final DateTime systemDateTime; 

  PossesionDamageReport({
    this.possesionDamageReportID,
    required this.possesion,
    required this.impactedAreaType,
    required this.impactedArea,
    required this.currentImpactDamages,
    required this.estimatedTotalDamages,
    this.decription,
    this.suspectedAnimalID,
    this.userSelectedLocation,
    this.systemLocation,
    this.userSelectedDateTime,
    required this.systemDateTime,
  });
}