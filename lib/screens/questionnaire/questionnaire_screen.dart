import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/interfaces/reporting/questionnaire_interface.dart';
import 'package:wildrapport/interfaces/reporting/response_interface.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/providers/response_provider.dart';
import 'package:wildrapport/screens/shared/overzicht_screen.dart';
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
    _loadQuestionnaire();
  }

  void nextScreen() {
    debugPrint("${responseProvider.answerID}");
    if (responseProvider.interactionID != null &&
        responseProvider.questionID != null) {
      _responseManager.storeResponse(
        responseProvider.responses.last,
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
    if (responseProvider.interactionID != null &&
        responseProvider.questionID != null) {
      await _responseManager.storeResponse(
        responseProvider.responses.last,
        widget.questionnaire.id,
        responseProvider.questionID!,
      );
    }
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
    final questionnaireScreens = await _questionnaireManager.buildQuestionnaireLayout(
      widget.questionnaire,
      widget.interactionID,
      nextScreen,
      lastNextScreen,
      previousScreen,
    );

    if (mounted) {
      setState(() {
        questionnaireScreensList = questionnaireScreens;
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
    return ChangeNotifierProvider<ResponseProvider>.value(
      value: responseProvider,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              CustomAppBar(
                leftIcon: Icons.arrow_back_ios,
                centerText: "Vragenlijst",
                rightIcon: Icons.menu,
                onLeftIconPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OverzichtScreen(),
                  ),
                ),
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