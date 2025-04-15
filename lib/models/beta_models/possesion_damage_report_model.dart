import 'package:wildrapport/interfaces/reportable_interface.dart';
import 'package:wildrapport/models/beta_models/possesion_model.dart';
import 'package:wildrapport/models/beta_models/report_location_model.dart';

class PossesionDamageReport implements Reportable{
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
    @override
    Map<String, dynamic> toJson() {
    dynamic jsonPossesion = possesion.toJson();
    dynamic jsonUserSelectedLocation = userSelectedLocation!.toJson();
    dynamic jsonSystemLocation = systemLocation!.toJson();

    return {
      "possesionDamageReportID": possesionDamageReportID,
      "possesion": jsonPossesion,
      "impactedAreaType": impactedAreaType,
      "impactedArea": impactedArea,
      "currentImpactDamages": currentImpactDamages,
      "estimatedTotalDamages": estimatedTotalDamages,
      "decription": decription,
      "suspectedAnimalID": suspectedAnimalID,
      "userSelectedLocation": jsonUserSelectedLocation,
      "systemLocation": jsonSystemLocation,
      "userSelectedDateTime": userSelectedDateTime,
      "systemDateTime": systemDateTime,
    };
  }
  factory PossesionDamageReport.fromJson(Map<String, dynamic> json) => PossesionDamageReport(
      possesionDamageReportID: json["possesionDamageReportID"],
      possesion: json["possesion"] = Possesion.fromJson(json["possesion"]),
      impactedAreaType: json["impactedAreaType"],
      impactedArea: json["impactedArea"],
      currentImpactDamages: json["currentImpactDamages"],
      estimatedTotalDamages: json["estimatedTotalDamages"],
      decription: json["decription"],
      suspectedAnimalID: json["suspectedAnimalID"],
      userSelectedLocation: json["userSelectedLocation"] = ReportLocation.fromJson(json["userSelectedLocation"]),
      systemLocation: json["systemLocation"] = ReportLocation.fromJson(json["systemLocation"]),
      userSelectedDateTime: json["userSelectedDateTime"],
      systemDateTime: json["systemDateTime"],
    );
}
