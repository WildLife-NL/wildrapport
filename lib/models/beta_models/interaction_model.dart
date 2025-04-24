import 'package:wildrapport/interfaces/reporting/reportable_interface.dart';
import 'package:wildrapport/models/beta_models/report_factory.dart';
import '../enums/interaction_type.dart';

class Interaction {
  final InteractionType interactionType; //waarneming, gewasschade, verkeersongeval  
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
      "interactionType": interactionType.toString(),
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
      interactionType: InteractionType.values.byName(type),
      userID: json["userID"],
      report: report,
    );
  }
}