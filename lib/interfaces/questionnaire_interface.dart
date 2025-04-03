import 'package:wildrapport/models/api_models/questionaire.dart';

abstract class QuestionnaireInterface {
  Future<Questionnaire> getQuestionnaire();  
}