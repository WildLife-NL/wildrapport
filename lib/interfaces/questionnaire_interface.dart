import 'package:flutter/material.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';

abstract class QuestionnaireInterface {
  Future<Questionnaire> getQuestionnaire();
  Future<List<dynamic>> buildQuestionnaireLayout(String interactionID, VoidCallback nextScreen, VoidCallback previousScreen);
  Future<List<dynamic>> buildQuestionnaireLayoutFromExisting(
    Questionnaire questionnaire, 
    String interactionID,
    VoidCallback nextScreen, 
    VoidCallback previousScreen
  );
  int? getAmountOfQuestions(int amount);
}
