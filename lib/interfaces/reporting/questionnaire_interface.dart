import 'package:flutter/material.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/providers/response_provider.dart';

abstract class QuestionnaireInterface {
  Future<Questionnaire> getQuestionnaire();
  Future<List<dynamic>> buildQuestionnaireLayout(
    ResponseProvider responseProvider,
    Questionnaire questionnaire,
    String interactionID,
    VoidCallback nextScreen,
    VoidCallback lastNextScreen,
    VoidCallback previousScreen,
    VoidCallback openQuestionnaire,
  );
}
