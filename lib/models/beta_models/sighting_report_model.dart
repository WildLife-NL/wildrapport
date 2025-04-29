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

    return {
      "sightingReportID": sightingReportID,
      "involvedAnimals": listAnimals,
    };
  }
  factory SightingReport.fromJson(Map<String, dynamic> json) => SightingReport(
      sightingReportID: json["sightingReportID"],
      description: json["description"],
      suspectedSpeciesID: json["suspectedSpeciesID"],
      userSelectedLocation: json["userSelectedLocation"] != null 
          ? ReportLocation.fromJson(json["userSelectedLocation"])
          : null,
      systemLocation: json["systemLocation"] != null 
          ? ReportLocation.fromJson(json["systemLocation"])
          : null,
      userSelectedDateTime: json["userSelectedDateTime"] != null 
          ? DateTime.parse(json["userSelectedDateTime"])
          : null,
      systemDateTime: DateTime.parse(json["systemDateTime"]),
      animals: json["animals"] != null 
          ? List<SightedAnimal>.from(
              json["animals"].map((x) => SightedAnimal.fromJson(x)))
          : [],
    );
}
