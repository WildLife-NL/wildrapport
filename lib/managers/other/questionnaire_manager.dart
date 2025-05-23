import 'package:flutter/material.dart';
import 'package:wildrapport/interfaces/data_apis/questionnaire_api_interface.dart';
import 'package:wildrapport/interfaces/reporting/questionnaire_interface.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/providers/response_provider.dart';
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
    ResponseProvider responseProvider,
    Questionnaire questionnaire,
    String interactionID,
    VoidCallback nextScreen,
    VoidCallback lastNextScreen,
    VoidCallback previousScreen,
    VoidCallback openQuestionnaire,
  ) async {
    final List<Widget> questionnaireWidgets = [];
    questionnaireWidgets.add(QuestionnaireHome(nextScreen: openQuestionnaire, amountOfQuestions: questionnaire.questions!.length));

    final int length = questionnaire.questions!.length;

    if (questionnaire.questions != null) {
      for (final (index, question) in questionnaire.questions!.indexed) {
        debugPrint("Question Description: ${question.description}");
        debugPrint("Allow Open Response: ${question.allowOpenResponse}");
        debugPrint("index: $index");
        debugPrint("length: $length");

        VoidCallback buttonAction;

        if (index == length - 1) {
          debugPrint("using lastNextScreen");
          buttonAction = lastNextScreen;
        } else {
          debugPrint("using nextScreen");
          buttonAction = nextScreen;
        }

        if (!question.allowOpenResponse) {
          questionnaireWidgets.add(
            QuestionnaireMultipleChoice(
              responseProvider: responseProvider,
              question: question,
              questionnaire: questionnaire,
              onNextPressed: buttonAction,
              onBackPressed: previousScreen,
              interactionID: interactionID,
              index: index,
            ),
          );
        } else {
          questionnaireWidgets.add(
            QuestionnaireOpenResponse(
              responseProvider: responseProvider,
              question: question,
              questionnaire: questionnaire,
              onNextPressed: buttonAction, // Use buttonAction here
              onBackPressed: previousScreen,
              interactionID: interactionID,
              index: index,
            ),
          );
        }
      }
    }

    // Set the initial questionID for the first question (after the home screen)
    if (questionnaire.questions!.isNotEmpty) {
      responseProvider.setQuestionID(questionnaire.questions!.first.id);
      debugPrint("[QuestionnaireManager]: Set initial questionID to ${questionnaire.questions!.first.id}");
    }

    return questionnaireWidgets;
  }
}