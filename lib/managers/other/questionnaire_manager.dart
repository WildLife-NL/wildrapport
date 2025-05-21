import 'package:flutter/material.dart';
import 'package:wildrapport/interfaces/data_apis/questionnaire_api_interface.dart';
import 'package:wildrapport/interfaces/questionnaire_interface.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/widgets/questionnaire/questionnaire_home.dart';
import 'package:wildrapport/widgets/questionnaire/questionnaire_multiple_choice.dart';
import 'package:wildrapport/widgets/questionnaire/questionnaire_open_response.dart';

class QuestionnaireManager implements QuestionnaireInterface {
  final QuestionnaireApiInterface questionnaireAPI;
  QuestionnaireManager(this.questionnaireAPI);

  @override
  Future<Questionnaire> getQuestionnaire() async {
    final String id = "5c5cd71a-ed88-4e18-8cd4-725a6c6fe4b1";
    return await questionnaireAPI.getQuestionnaireByID(id);
  }

  @override
  Future<List<dynamic>> buildQuestionnaireLayout(
    Questionnaire questionnaire,
    String interactionID,
    VoidCallback nextScreen,
    VoidCallback lastNextScreen,
    VoidCallback previousScreen,
  ) async {
    final List<Widget> questionnaireWidgets = [];
    questionnaireWidgets.add(QuestionnaireHome(nextScreen: nextScreen, amountOfQuestions: questionnaire.questions!.length));

    final int length = questionnaire.questions!.length;

    if (questionnaire.questions != null) {
      for (final (index, question) in questionnaire.questions!.indexed) {
        debugPrint("Question Description: ${question.description}");
        debugPrint("Allow Open Response: ${question.allowOpenResponse}");
        debugPrint("index: $index");
        debugPrint("length: $length");

        if (index == length) {
          nextScreen = lastNextScreen;
        }

        if (!question.allowOpenResponse) {
          questionnaireWidgets.add(
            QuestionnaireMultipleChoice(
              question: question,
              questionnaire: questionnaire,
              onNextPressed: nextScreen,
              onBackPressed: previousScreen,
              interactionID: interactionID,
              index: index,
            ),
          );
        } else {
          questionnaireWidgets.add(
            QuestionnaireOpenResponse(
              question: question,
              questionnaire: questionnaire,
              onNextPressed: nextScreen,
              onBackPressed: previousScreen,
              interactionID: interactionID,
              index: index, 
            ),
          );
        }
      }
    }
    return questionnaireWidgets;
  }
}