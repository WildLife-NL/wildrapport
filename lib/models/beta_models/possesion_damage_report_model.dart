import 'package:flutter/material.dart';
import 'package:wildrapport/interfaces/reporting/common_report_fields.dart';
import 'package:wildrapport/interfaces/reporting/reportable_interface.dart';
import 'package:wildrapport/models/beta_models/possesion_model.dart';
import 'package:wildrapport/models/beta_models/report_location_model.dart';

class PossesionDamageReport implements Reportable, CommonReportFields{
  final String? possesionDamageReportID;
  final Possesion possesion;
  final String impactedAreaType;
  final double impactedArea;
  final String currentImpactDamages;
  final String estimatedTotalDamages;
  @override
  final String? description;
  @override
  final String? suspectedSpeciesID;
  @override
  final ReportLocation? userSelectedLocation;
  @override
  final ReportLocation? systemLocation;
  @override
  final DateTime? userSelectedDateTime;
  @override
  final DateTime systemDateTime; 

  PossesionDamageReport({
    this.possesionDamageReportID,
    required this.possesion,
    required this.impactedAreaType,
    required this.impactedArea,
    required this.currentImpactDamages,
    required this.estimatedTotalDamages,
    this.description,
    this.suspectedSpeciesID,
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
    debugPrint
    (
      '''
      possesionDamageReportID: $possesionDamageReportID
      possesion: $jsonPossesion
      impactedAreaType: $impactedAreaType,
      impactedArea: $impactedArea,
      currentImpactDamages: $currentImpactDamages,
      estimatedTotalDamages: $estimatedTotalDamages,
      decription: $description,
      suspectedAnimalID: $suspectedSpeciesID,
      userSelectedLocation: $jsonUserSelectedLocation,
      systemLocation: $jsonSystemLocation,
      userSelectedDateTime: ${userSelectedDateTime!.toIso8601String()},
      systemDateTime: ${systemDateTime.toIso8601String()}
      '''
    );
    return {
      "belonging": 
      {
        "ID": possesion.possesionID,
        "category": possesion.category,
        "name": possesion.possesionName,
      },
      "estimatedDamage": num.parse(currentImpactDamages).toInt(),
      "estimatedLoss": num.parse(estimatedTotalDamages).toInt(),
      "impactType": "square-meters",
      "impactValue": impactedArea.toInt(),
    };
  }
  factory PossesionDamageReport.fromJson(Map<String, dynamic> json) => PossesionDamageReport(
      possesionDamageReportID: json["possesionDamageReportID"],
      possesion: json["possesion"] = Possesion.fromJson(json["possesion"]),
      impactedAreaType: json["impactedAreaType"],
      impactedArea: json["impactedArea"],
      currentImpactDamages: json["currentImpactDamages"],
      estimatedTotalDamages: json["estimatedTotalDamages"],
      description: json["decription"],
      suspectedSpeciesID: json["suspectedAnimalID"],
      userSelectedLocation: json["userSelectedLocation"] = ReportLocation.fromJson(json["userSelectedLocation"]),
      systemLocation: json["systemLocation"] = ReportLocation.fromJson(json["systemLocation"]),
      userSelectedDateTime: json["userSelectedDateTime"],
      systemDateTime: json["systemDateTime"],
    );
}
