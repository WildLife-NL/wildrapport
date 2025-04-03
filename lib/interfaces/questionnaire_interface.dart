import 'package:wildrapport/models/api_models/questionaire.dart';

abstract class QuestionnaireInterface {
  Future<Questionnaire> getQuestionnaire();
  int? getAmountOfQuestions(int amount); //replace int amount with Questionnaire questionnaire after testing  
}