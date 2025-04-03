import 'package:wildrapport/interfaces/api/questionnaire_api_interface.dart';
import 'package:wildrapport/interfaces/questionnaire_interface.dart';
import 'package:wildrapport/models/api_models/question.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';

class QuestionnaireManager implements QuestionnaireInterface{
  final QuestionnaireApiInterface questionnaireAPI;
  QuestionnaireManager(this.questionnaireAPI);

  @override
  Future<Questionnaire> getQuestionnaire() {
    //Change to actual test questionaire ID.
    //This is here so we can test, in future we want to get, 
    //questionnaires in a different way than using ID
    final String id = "0344790e-8e86-4c5f-982d-9879928bb9e4";

    return questionnaireAPI.getQuestionnaireByID(id);
  }
  List<dynamic> buildQuestionnaireLayout(Questionnaire questionnaire){
    final List<dynamic> questionnaireWidgets = List<dynamic>.empty();
    
    //Implement logic to determine what widget to put in list
    //Questionnaire screen will then display one by one
    for (Question question in questionnaire.questions!){
      if(question.allowMultipleResponse == true){
        //Create multiplechoice widget
      }
      if(question.allowOpenResponse == true){
        //Create openresponse widget
      }
    }
    return questionnaireWidgets;
  }
  
  @override
  int? getAmountOfQuestions(int amount) { //replace int amount with Questionnaire questionnaire after testing
    return amount;
  } 
}