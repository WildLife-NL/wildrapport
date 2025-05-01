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
  Future<List<dynamic>> buildQuestionnaireLayout(VoidCallback nextScreen, VoidCallback previousScreen) async {
    final Questionnaire questionnaire = await getQuestionnaire();
    final List<Widget> questionnaireWidgets = [];
    questionnaireWidgets.add(QuestionnaireHome(nextScreen: nextScreen));
    
    for (Question question in questionnaire.questions!) {
      debugPrint("Question Description: ${question.description}");
      debugPrint("Allow Open Response: ${question.allowOpenResponse}");
      if (!question.allowOpenResponse) {
        debugPrint("index: ${question.index}");
        questionnaireWidgets.add(
          QuestionnaireMultipleChoice(
            question: question,
            questionnaire: questionnaire,
            onNextPressed: nextScreen,
            onBackPressed: previousScreen,
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
  Future<List<dynamic>> buildQuestionnaireLayoutFromExisting(
    Questionnaire questionnaire, 
    VoidCallback nextScreen, 
    VoidCallback previousScreen
  ) async {
    final List<Widget> questionnaireWidgets = [];
    questionnaireWidgets.add(QuestionnaireHome(nextScreen: nextScreen));
    
    if (questionnaire.questions != null) {
      for (Question question in questionnaire.questions!) {
        debugPrint("Question Description: ${question.description}");
        debugPrint("Allow Open Response: ${question.allowOpenResponse}");
        if (!question.allowOpenResponse) {
          debugPrint("index: ${question.index}");
          questionnaireWidgets.add(
            QuestionnaireMultipleChoice(
              question: question,
              questionnaire: questionnaire,
              onNextPressed: nextScreen,
              onBackPressed: previousScreen,
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
            ),
          );
        }
      }
    }
    return questionnaireWidgets;
  }
}

