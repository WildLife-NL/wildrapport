import 'package:flutter/material.dart';
import 'package:wildrapport/interfaces/api/questionnaire_api_interface.dart';
import 'package:wildrapport/interfaces/questionnaire_interface.dart';
import 'package:wildrapport/models/api_models/question.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/widgets/questionnaire/questionnaire_home.dart';
import 'package:wildrapport/widgets/questionnaire/questionnaire_multiple_choice.dart';
import 'package:wildrapport/widgets/questionnaire/questionnaire_open_response.dart';

class QuestionnaireManager implements QuestionnaireInterface {
  final QuestionnaireApiInterface questionnaireAPI;
  QuestionnaireManager(this.questionnaireAPI);

  @override
  Future<Questionnaire> getQuestionnaire() async {
    final String id = "34f54147-8296-4aa9-9a39-6c48dbf88c70";
    return await questionnaireAPI.getQuestionnaireByID(id);
  }


  @override
  Future<List<dynamic>> buildQuestionnaireLayout(String interactionID, VoidCallback nextScreen, VoidCallback previousScreen) async {
    final Questionnaire questionnaire = await getQuestionnaire();
    final List<Widget> questionnaireWidgets = [];
    questionnaireWidgets.add(QuestionnaireHome(nextScreen: nextScreen));
    final int lenght = questionnaire.questions!.length;

    for (Question question in questionnaire.questions!) {
      debugPrint("Question Description: ${question.description}");
      debugPrint("Allow Open Response: ${question.allowOpenResponse}");

      debugPrint("index: ${question.index}");
      debugPrint("lenght: $lenght");
      if(question.index == lenght){
        debugPrint("CORRECT!");
      }

      if (!question.allowOpenResponse) {
        questionnaireWidgets.add(
          QuestionnaireMultipleChoice(
            question: question,
            questionnaire: questionnaire,
            onNextPressed: nextScreen,
            onBackPressed: previousScreen, 
            interactionID: interactionID,
          ),
        );
      }
      if (question.allowOpenResponse) {
        questionnaireWidgets.add(
          QuestionnaireOpenResponse(
            question: question,
            questionnaire: questionnaire,
            onNextPressed: nextScreen,
            onBackPressed: previousScreen, 
            interactionID: interactionID,
          ),
        );
      }
    }
    return questionnaireWidgets;
  }
  
  @override
  int? getAmountOfQuestions(int amount) {
    return amount;
  }

  // Add a method to build questionnaire layout from an existing questionnaire
  @override
  Future<List<dynamic>> buildQuestionnaireLayoutFromExisting(
    Questionnaire questionnaire, 
    String interactionID,
    VoidCallback nextScreen,
    VoidCallback lastNextScreen, 
    VoidCallback previousScreen,
  ) async {
    final List<Widget> questionnaireWidgets = [];
    questionnaireWidgets.add(QuestionnaireHome(nextScreen: nextScreen));

    final int lenght = questionnaire.questions!.length;

    if (questionnaire.questions != null) {
      for (Question question in questionnaire.questions!) {
        debugPrint("Question Description: ${question.description}");
        debugPrint("Allow Open Response: ${question.allowOpenResponse}");
        
      debugPrint("index: ${question.index}");
      debugPrint("lenght: $lenght");
      if(question.index == lenght){
        nextScreen = lastNextScreen;
      }

        if (!question.allowOpenResponse) {
          debugPrint("index: ${question.index}");
          questionnaireWidgets.add(
            QuestionnaireMultipleChoice(
              question: question,
              questionnaire: questionnaire,
              onNextPressed: nextScreen,
              onBackPressed: previousScreen, 
              interactionID: interactionID,
            ),
          );
        }
        if (question.allowOpenResponse) {
          questionnaireWidgets.add(
            QuestionnaireOpenResponse(
              question: question,
              questionnaire: questionnaire,
              onNextPressed: nextScreen,
              onBackPressed: previousScreen, 
              interactionID: interactionID,
            ),
          );
        }
      }
    }
    return questionnaireWidgets;
  }
}

