import 'package:wildrapport/interfaces/reportable_interface.dart';
import 'package:wildrapport/models/beta_models/report_factory.dart';

class Interaction {
  final String interactionType; //waarneming, gewasschade, verkeersongeval
  final String userID;
  final Reportable report;

  Interaction({
    required this.interactionType,
    required this.userID,
    required this.report,
  });
  Map<String, dynamic> toJson() {
    dynamic jsonReport = report.toJson();

    return {
      "interactionType": interactionType,
      "userID": userID,
      "report": jsonReport,
    };
  }
  factory Interaction.fromJson(Map<String, dynamic> json) {
    final String type = json["interactionType"];
    final Map<String, dynamic> reportJson = json["report"];

    final factory = reportFactories[type];
    if (factory == null) {
      throw Exception("Unknown interactionType: $type");
    }

    final report = factory(reportJson);

    return Interaction(
      interactionType: type,
      userID: json["userID"],
      report: report,
    );
  }
}