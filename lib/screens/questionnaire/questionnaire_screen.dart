import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/interfaces/reporting/questionnaire_interface.dart';
import 'package:wildrapport/interfaces/reporting/response_interface.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/providers/response_provider.dart';
import 'package:wildrapport/screens/questionnaire/questionnaire_completion_screen.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/models/beta_models/response_model.dart';
import 'package:wildrapport/widgets/questionnaire/questionnaire_home.dart';

class QuestionnaireScreen extends StatefulWidget {
  final Questionnaire questionnaire;
  final String interactionID;
  final int? initialScreenIndex;
  final List<Response>? initialResponses;

  const QuestionnaireScreen({
    super.key,
    required this.questionnaire,
    required this.interactionID,
    this.initialScreenIndex,
    this.initialResponses,
  });

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  late final QuestionnaireInterface _questionnaireManager;
  final ResponseProvider responseProvider = ResponseProvider();
  late final ResponseInterface _responseManager;
  late List<dynamic> questionnaireScreensList = [];
  int currentQuestionnaireIndex = 0;
  bool _shouldNavigate = false;

  @override
  void initState() {
    super.initState();
    _questionnaireManager = context.read<QuestionnaireInterface>();
    _responseManager = context.read<ResponseInterface>();
    if (widget.initialResponses != null) {
      responseProvider.responses = List<Response>.from(widget.initialResponses!);
    }
    _loadQuestionnaire();
  }

  Future<void> _persistCurrentAnswerIfAny() async {
    if (responseProvider.interactionID == null ||
        responseProvider.questionID == null) {
      return;
    }
    if (responseProvider.responses.isEmpty) return;
    final currentResponse = responseProvider.responses.firstWhere(
      (r) => r.questionID == responseProvider.questionID,
      orElse: () => responseProvider.responses.last,
    );
    await _responseManager.storeResponse(
      currentResponse,
      widget.questionnaire.id,
      responseProvider.questionID!,
    );
  }

  Future<void> _saveForLater() async {
    await _persistCurrentAnswerIfAny();
    if (!mounted) return;
    await saveQuestionnaireDraftAndExit(
      context,
      draft: DraftQuestionnaire(
        interactionID: widget.interactionID,
        savedAt: DateTime.now(),
        questionnaireJson: widget.questionnaire.toJson(),
        currentScreenIndex: currentQuestionnaireIndex,
        responsesJson: responseProvider.responses
            .map((r) => r.toJson())
            .toList(),
      ),
    );
  }

  void nextScreen() {
    debugPrint("${responseProvider.answerID}");
    debugPrint(
      "[QuestionnaireScreen] Total responses in provider: ${responseProvider.responses.length}",
    );

    if (responseProvider.interactionID != null &&
        responseProvider.questionID != null) {
      // Find the response for the current question instead of using .last
      final currentResponse = responseProvider.responses.firstWhere(
        (r) => r.questionID == responseProvider.questionID,
        orElse: () => responseProvider.responses.last,
      );

      debugPrint(
        "[QuestionnaireScreen] Storing response for question: ${responseProvider.questionID}",
      );
      debugPrint(
        "[QuestionnaireScreen] Answer: ${currentResponse.answerID}, Text: ${currentResponse.text}",
      );

      _responseManager.storeResponse(
        currentResponse,
        widget.questionnaire.id,
        responseProvider.questionID!,
      );
    }
    debugPrint("Next Screen");
    debugPrint("Current Index: $currentQuestionnaireIndex");
    if (currentQuestionnaireIndex < questionnaireScreensList.length - 1) {
      setState(() {
        currentQuestionnaireIndex++;
      });
    }
  }

  void lastNextScreen() async {
    debugPrint(
      "[QuestionnaireScreen] Final submit - Total responses: ${responseProvider.responses.length}",
    );

    if (responseProvider.interactionID != null &&
        responseProvider.questionID != null) {
      // Find the response for the last question
      final lastResponse = responseProvider.responses.firstWhere(
        (r) => r.questionID == responseProvider.questionID,
        orElse: () => responseProvider.responses.last,
      );

      debugPrint(
        "[QuestionnaireScreen] Storing last response for question: ${responseProvider.questionID}",
      );

      await _responseManager.storeResponse(
        lastResponse,
        widget.questionnaire.id,
        responseProvider.questionID!,
      );
    }

    debugPrint("[QuestionnaireScreen] Submitting all responses to backend...");
    await _responseManager.submitResponses();

    setState(() {
      _shouldNavigate = true;
    });
  }

  void previousScreen() {
    debugPrint("Previous Screen");
    debugPrint("Current Index: $currentQuestionnaireIndex");
    if (currentQuestionnaireIndex > 0) {
      setState(() {
        currentQuestionnaireIndex--;
      });
    }
  }

  Future<void> _loadQuestionnaire() async {
    final questionnaireScreens = await _questionnaireManager
        .buildQuestionnaireLayout(
          widget.questionnaire,
          widget.interactionID,
          nextScreen,
          lastNextScreen,
          previousScreen,
        );

    if (mounted) {
      var index = widget.initialScreenIndex ?? 0;
      if (questionnaireScreens.isNotEmpty) {
        index = index.clamp(0, questionnaireScreens.length - 1);
      }
      setState(() {
        questionnaireScreensList = questionnaireScreens;
        currentQuestionnaireIndex = index;
      });
      debugPrint(
        'Loaded questionnaireScreensList: ${questionnaireScreensList.length}',
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
            const QuestionnaireCompletionScreen(),
          );
        }
      });
      // Reset _shouldNavigate to prevent repeated navigation
      _shouldNavigate = false;
    }

    if (questionnaireScreensList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return ChangeNotifierProvider<ResponseProvider>.value(
      value: responseProvider,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              CustomAppBar(
                leftIcon: null,
                centerText: 'Vragenlijst',
                rightIcon: Icons.bookmark_border,
                onRightIconPressed: () => unawaited(_saveForLater()),
                showUserIcon: false,
                useFixedText: true,
                iconColor: AppColors.textPrimary,
                textColor: AppColors.textPrimary,
                fontScale: 1.15,
                iconScale: 1.15,
                userIconScale: 1.15,
              ),
              if (currentQuestionnaireIndex > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => unawaited(_saveForLater()),
                      icon: const Icon(
                        Icons.bookmark_add_outlined,
                        size: 20,
                        color: AppColors.primaryGreen,
                      ),
                      label: const Text(
                        'Voor later opslaan',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
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
