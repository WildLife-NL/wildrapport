import 'package:wildrapport/models/api_models/questionaire.dart';

class InteractionResponseModel {
  Questionnaire questionnaire;
  String interactionID;
  InteractionResponseModel({
    required this.questionnaire,
    required this.interactionID,
  });
  factory InteractionResponseModel.fromJson(Map<String, dynamic> json) => InteractionResponseModel(
    questionnaire: Questionnaire.fromJson(json["questionnaire"]),
    interactionID: json["interactionID"],
  );

  Map<String, dynamic> toJson() => {
    "questionnaire": questionnaire.toJson(),
    "interactionID": interactionID,
  };

}