import 'package:wildrapport/interfaces/reportable_interface.dart';
import 'package:wildrapport/models/beta_models/report_location_model.dart';
import 'package:wildrapport/models/beta_models/sighted_animal_model.dart';

class SightingReport implements Reportable{
  final List<SightedAnimal> animals;
  final String? sightingReportID;
  final String? description;
  final ReportLocation? userSelectedLocation;
  final ReportLocation? systemLocation;
  final DateTime? userSelectedDateTime;
  final DateTime systemDateTime;

  SightingReport({
    required this.animals,
    this.sightingReportID,
    this.description,
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
      "userSelectedLocation": jsonUserSelectedLocation,
      "systemLocation": jsonSystemLocation,
      "userSelectedDateTime": userSelectedDateTime,
      "systemDateTime": systemDateTime,
      "animals": listAnimals,
    };
  }
  factory SightingReport.fromJson(Map<String, dynamic> json) => SightingReport(
      sightingReportID: json["sightingReportID"],
      description: json["description"],
      userSelectedLocation: json["userSelectedLocation"] = ReportLocation.fromJson(json["userSelectedLocation"]),
      systemLocation: json["systemLocation"] = ReportLocation.fromJson(json["systemLocation"]),
      userSelectedDateTime: json["userSelectedDateTime"],
      systemDateTime: json["systemDateTime"],
      animals: json["animals"] = List<SightedAnimal>.from(
        json["animals"].map((x) => SightedAnimal.fromJson(x))),
    );
}