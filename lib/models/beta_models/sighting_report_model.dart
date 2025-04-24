import 'package:wildrapport/interfaces/reporting/common_report_fields.dart';
import 'package:wildrapport/interfaces/reporting/reportable_interface.dart';
import 'package:wildrapport/models/beta_models/report_location_model.dart';
import 'package:wildrapport/models/beta_models/sighted_animal_model.dart';

class SightingReport implements Reportable, CommonReportFields{
  final List<SightedAnimal> animals;
  final String? sightingReportID;
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

  SightingReport({
    required this.animals,
    this.sightingReportID,
    this.description,
    this.suspectedSpeciesID,
    this.userSelectedLocation,
    this.systemLocation,
    this.userSelectedDateTime,
    required this.systemDateTime,
  });
  @override
  Map<String, dynamic> toJson() {
    List<dynamic>? listAnimals;
    listAnimals = List<dynamic>.from(animals.map((x) => x.toJson()));
    dynamic jsonUserSelectedLocation = userSelectedLocation!.toJson();
    dynamic jsonSystemLocation = systemLocation!.toJson();

    return {
      "sightingReportID": sightingReportID,
      "description": description,
      "suspectedSpeciesID": suspectedSpeciesID,
      "userSelectedLocation": jsonUserSelectedLocation,
      "systemLocation": jsonSystemLocation,
      "userSelectedDateTime": userSelectedDateTime!.toIso8601String(),
      "systemDateTime": systemDateTime.toIso8601String(),
      "animals": listAnimals,
    };
  }
  factory SightingReport.fromJson(Map<String, dynamic> json) => SightingReport(
      sightingReportID: json["sightingReportID"],
      description: json["description"],
      suspectedSpeciesID: json["suspectedSpeciesID"],
      userSelectedLocation: json["userSelectedLocation"] = ReportLocation.fromJson(json["userSelectedLocation"]),
      systemLocation: json["systemLocation"] = ReportLocation.fromJson(json["systemLocation"]),
      userSelectedDateTime: json["userSelectedDateTime"],
      systemDateTime: json["systemDateTime"],
      animals: json["animals"] = List<SightedAnimal>.from(
        json["animals"].map((x) => SightedAnimal.fromJson(x))),
    );
}