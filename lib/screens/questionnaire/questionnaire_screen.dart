import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/interfaces/reporting/questionnaire_interface.dart';
import 'package:wildrapport/interfaces/reporting/response_interface.dart';
import 'package:wildrapport/models/api_models/question.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/providers/response_provider.dart';
import 'package:wildrapport/screens/shared/overzicht_screen.dart';
import 'package:wildrapport/utils/toast_notification_handler.dart';
import 'package:wildrapport/widgets/questionnaire/questionnaire_multiple_choice.dart';
import 'package:wildrapport/widgets/questionnaire/questionnaire_open_response.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';

class QuestionnaireScreen extends StatefulWidget {
  final Questionnaire questionnaire;
  final String interactionID;
  const QuestionnaireScreen({
    super.key,
    required this.questionnaire,
    required this.interactionID,
  });

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  late final QuestionnaireInterface _questionnaireManager;
  late final ResponseInterface _responseManager;
  late List<dynamic> questionnaireScreensList = [];
  late final ResponseProvider responseProvider;

  int currentQuestionnaireIndex = 0;
  bool _shouldNavigate = false;
  final yellowLog = '\x1B[93m';

  @override
  void initState() {
    super.initState();
    _questionnaireManager = context.read<QuestionnaireInterface>();
    _responseManager = context.read<ResponseInterface>();
    responseProvider = context.read<ResponseProvider>();
    _loadQuestionnaire();
  }

  bool validateResponse() {
    bool isValid = true;

    final currentQuestionID = responseProvider.questionID;
    if (currentQuestionID == null) {
      debugPrint("$yellowLog [QuestionnaireScreen]: questionID is null");
      return false;
    }

    final currentQuestion = widget.questionnaire.questions!.firstWhereOrNull(
      (x) => x.id == currentQuestionID,
    );

    if (currentQuestion == null) {
      debugPrint("$yellowLog [QuestionnaireScreen]: No question found for questionID: $currentQuestionID");
      return false;
    }

    // Find the response for the current question
    final existingResponse = responseProvider.responses.firstWhereOrNull(
      (response) => response.questionID == currentQuestion.id,
    );

    debugPrint("$yellowLog [QuestionnaireScreen]: Validating question ${currentQuestion.id}, Response: $existingResponse, Responses: ${responseProvider.responses}");

    if (currentQuestion.answers != null) {
      if (currentQuestion.allowMultipleResponse) {
        // Checkbox (multiple-choice) question: check if answerID is non-null and non-empty
        if (existingResponse == null || existingResponse.answerID == null || existingResponse.answerID!.isEmpty) {
          isValid = false;
          responseProvider.setErrorState('answerID', true);
          debugPrint("$yellowLog [QuestionnaireScreen]: answerID is missing for multiple-choice question ${currentQuestion.id}");
        } else {
          responseProvider.setErrorState('answerID', false);
        }
      } else {
        // Radio button (single-choice) question: require a response with a non-empty answerID
        if (existingResponse == null || existingResponse.answerID == null || existingResponse.answerID!.isEmpty) {
          isValid = false;
          responseProvider.setErrorState('answerID', true);
          debugPrint("$yellowLog [QuestionnaireScreen]: answerID is missing or empty for single-choice question ${currentQuestion.id}");
        } else {
          responseProvider.setErrorState('answerID', false);
        }
      }
    } else {
      // Open-response question: check if text is non-null and non-empty
      if (existingResponse == null || existingResponse.text == null || existingResponse.text!.isEmpty) {
        isValid = false;
        responseProvider.setErrorState('text', true);
        debugPrint("$yellowLog [QuestionnaireScreen]: text is missing for question ${currentQuestion.id}");
      } else {
        responseProvider.setErrorState('text', false);
      }
    }

    return isValid;
  }
    
  void openQuestionnaire() {
    debugPrint("$yellowLog [QuestionnaireScreen]: Opening questionnaire");
    if (currentQuestionnaireIndex < questionnaireScreensList.length - 1) {
      setState(() {
        currentQuestionnaireIndex++;
        // Set questionID for the first question
        if (currentQuestionnaireIndex > 0 &&
            currentQuestionnaireIndex - 1 < widget.questionnaire.questions!.length) {
          final firstQuestion = widget.questionnaire.questions![currentQuestionnaireIndex - 1];
          responseProvider.setQuestionID(firstQuestion.id);
          debugPrint("$yellowLog [QuestionnaireScreen]: Set questionID to ${firstQuestion.id} for index $currentQuestionnaireIndex");
        } else {
          debugPrint("$yellowLog [QuestionnaireScreen]: No question available at index $currentQuestionnaireIndex");
        }
      });
    }
  }

  void nextScreen() {
    // Validate the current response
    if (validateResponse()) {
      if (responseProvider.interactionID != null && responseProvider.questionID != null) {
        _responseManager.storeResponse(
          responseProvider.responses.last,
          widget.questionnaire.id,
          responseProvider.questionID!,
        );
      }
      debugPrint("$yellowLog [QuestionnaireScreen]: Next Screen, Current Index: $currentQuestionnaireIndex");
      if (currentQuestionnaireIndex < questionnaireScreensList.length - 1) {
        setState(() {
          currentQuestionnaireIndex++;
          // Update questionID for the next question
          if (currentQuestionnaireIndex > 0 &&
              currentQuestionnaireIndex - 1 < widget.questionnaire.questions!.length) {
            final nextQuestion = widget.questionnaire.questions![currentQuestionnaireIndex - 1];
            responseProvider.setQuestionID(nextQuestion.id);
            debugPrint("$yellowLog [QuestionnaireScreen]: Set questionID to ${nextQuestion.id} for index $currentQuestionnaireIndex");
          } else {
            debugPrint("$yellowLog [QuestionnaireScreen]: No next question available at index $currentQuestionnaireIndex");
          }
        });
      }
    } else {
      debugPrint(questionnaireScreensList[currentQuestionnaireIndex].runtimeType.toString());
      debugPrint("$yellowLog [QuestionnaireScreen]: Form is not valid!!!");
      if (questionnaireScreensList[currentQuestionnaireIndex].runtimeType == QuestionnaireMultipleChoice) {
        _sendToastNotification("Kies astublieft een antwoord");
      } else if (questionnaireScreensList[currentQuestionnaireIndex].runtimeType == QuestionnaireOpenResponse) {
        _sendToastNotification("Vul astublieft een antwoord in");
      }
    }
  }

  void lastNextScreen() async {    
    if (validateResponse()) {
      if (responseProvider.interactionID != null && responseProvider.questionID != null) {
        await _responseManager.storeResponse(
          responseProvider.responses.last,
          widget.questionnaire.id,
          responseProvider.questionID!,
        );
      }
      await _responseManager.submitResponses();
      _sendToastNotification("Uw antwoorden zijn verstuurd");

      setState(() {
        _shouldNavigate = true;
      });
    } else {
      debugPrint("$yellowLog [QuestionnaireScreen]: Form is not valid for submission!!!");
      if(context.widget.runtimeType == QuestionnaireMultipleChoice){
        _sendToastNotification("Kies astublieft een antwoord");
      }
      else if(context.widget.runtimeType == QuestionnaireOpenResponse){
        _sendToastNotification("Vul astublieft een antwoord in");
      }
    }
  }

  void _sendToastNotification(String toastMessage) {
    ToastNotificationHandler.sendToastNotification(context, toastMessage, 2);
  }

  void previousScreen() {
    debugPrint("$yellowLog [QuestionnaireScreen]: Previous Screen, Current Index: $currentQuestionnaireIndex");
    if (currentQuestionnaireIndex > 0) {
      setState(() {
        currentQuestionnaireIndex--;
      });
    } else {
      final navigationManager = context.read<NavigationStateInterface>();
      navigationManager.pushReplacementForward(
        context,
        OverzichtScreen(),
      );
    }
  }

  Future<void> _loadQuestionnaire() async {
    final questionnaireScreens = await _questionnaireManager.buildQuestionnaireLayout(
      responseProvider,
      widget.questionnaire,
      widget.interactionID,
      nextScreen,
      lastNextScreen,
      previousScreen,
      openQuestionnaire,
    );

    if (mounted) {
      setState(() {
        questionnaireScreensList = questionnaireScreens;
      });
      debugPrint(
        '$yellowLog [QuestionnaireScreen]: Loaded questionnaireScreensList: ${questionnaireScreensList.length}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle navigation in build when _shouldNavigate is true
    if (_shouldNavigate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<NavigationStateInterface>().pushAndRemoveUntil(
            context,
            OverzichtScreen(),
          );
        }
      });
      // Reset _shouldNavigate to prevent repeated navigation
      _shouldNavigate = false;
    }

    if (questionnaireScreensList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return ChangeNotifierProvider<ResponseProvider>(
      create: (_) => ResponseProvider(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              CustomAppBar(
                leftIcon: Icons.arrow_back_ios,
                centerText: "Vragenlijst",
                rightIcon: Icons.menu,
                onLeftIconPressed: previousScreen,
                onRightIconPressed: () {
                  /* Handle menu */
                },
              ),
              Expanded(
                child: questionnaireScreensList[currentQuestionnaireIndex],
              ),
            ],
          ),
        ),
      ),
    );
  }
}