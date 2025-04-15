import 'package:wildrapport/interfaces/reportable_interface.dart';
import 'package:wildrapport/models/beta_models/report_location_model.dart';
import 'package:wildrapport/models/beta_models/sighted_animal_model.dart';

class AccidentReport implements Reportable {
  String? accidentReportID;
  String? description;
  String damages;
  List<SightedAnimal>? animals;
  ReportLocation? userSelectedLocation;
  ReportLocation? systemLocation;
  DateTime? userSelectedDateTime;
  DateTime systemDateTime;

  AccidentReport() :
    damages = "0",
    animals = [],
    systemDateTime = DateTime.now();
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

  factory AccidentReport.fromJson(Map<String, dynamic> json) {
    final report = AccidentReport();
    report.accidentReportID = json["accidentReportID"];
    report.description = json["description"];
    report.damages = json["damages"];
    report.userSelectedLocation = ReportLocation.fromJson(json["userSelectedLocation"]);
    report.systemLocation = ReportLocation.fromJson(json["systemLocation"]);
    report.userSelectedDateTime = json["userSelectedDateTime"];
    report.systemDateTime = json["systemDateTime"];
    report.animals = List<SightedAnimal>.from(
      json["animals"].map((x) => SightedAnimal.fromJson(x)));
    return report;
  }
}

