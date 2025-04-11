import 'package:wildrapport/interfaces/reportable_interface.dart';
import 'package:wildrapport/models/beta_models/report_location_model.dart';
import 'package:wildrapport/models/beta_models/sighted_animal_model.dart';

class AccidentReport implements Reportable{
  final String? accidentReportID;
  final String? description;
  final String damages;
  final List<SightedAnimal>? animals;
  final ReportLocation? userSelectedLocation;
  final ReportLocation? systemLocation;
  final DateTime? userSelectedDateTime;
  final DateTime systemDateTime;

  AccidentReport({
    this.accidentReportID,
    this.description,
    required this.damages,
    this.animals,
    this.userSelectedLocation,
    this.systemLocation,
    this.userSelectedDateTime,
    required this.systemDateTime,
  });
    @override
    Map<String, dynamic> toJson() {
    List<dynamic>? listAnimals;
    listAnimals = List<dynamic>.from(animals!.map((x) => x.toJson()));
    dynamic jsonUserSelectedLocation = userSelectedLocation!.toJson();
    dynamic jsonSystemLocation = systemLocation!.toJson();

    return {
      "accidentReportID": accidentReportID,
      "description": description,
      "damages": damages,
      "userSelectedLocation": jsonUserSelectedLocation,
      "systemLocation": jsonSystemLocation,
      "userSelectedDateTime": userSelectedDateTime,
      "systemDateTime": systemDateTime,
      "animals": listAnimals,
    };
  }
  factory AccidentReport.fromJson(Map<String, dynamic> json) => AccidentReport(
      accidentReportID: json["accidentReportID"],
      description: json["description"],
      damages: json["damages"],
      userSelectedLocation: json["userSelectedLocation"] = ReportLocation.fromJson(json["userSelectedLocation"]),
      systemLocation: json["systemLocation"] = ReportLocation.fromJson(json["systemLocation"]),
      userSelectedDateTime: json["userSelectedDateTime"],
      systemDateTime: json["systemDateTime"],
      animals: json["animals"] = List<SightedAnimal>.from(
        json["animals"].map((x) => SightedAnimal.fromJson(x))),
    );
}