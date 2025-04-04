import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/questionnaire_interface.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/screens/overzicht_screen.dart';
import 'package:wildrapport/widgets/app_bar.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  late final QuestionnaireInterface _questionnaireManager;
  late List<dynamic> questionnaireScreensList = [];
  int currentQuestionnaireIndex = 0;

  @override
  void initState() {
    super.initState();
    _questionnaireManager = context.read<QuestionnaireInterface>();
    _loadQuestionnaire(); // Call this asynchronously
  }

  void nextScreen() {
    debugPrint("Next Screen");
    debugPrint("Current Index: $currentQuestionnaireIndex");
    if (currentQuestionnaireIndex < questionnaireScreensList.length - 1) {
      setState(() {
        currentQuestionnaireIndex++;
      });
    }
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
    // First, get the questionnaire
    final questionnaire = await _questionnaireManager.getQuestionnaire();
    
    // Now, build the questionnaire layout (async operation)
    final questionnaireScreens = await _questionnaireManager.buildQuestionnaireLayout(
      nextScreen,
      previousScreen,
    );

    // After the async operations are complete, update the state
    setState(() {
      questionnaireScreensList = questionnaireScreens;
    });
    debugPrint('Loaded questionnaireScreensList: ${questionnaireScreensList.length}');
  }

  @override
  Widget build(BuildContext context) {
    if (questionnaireScreensList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
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
                onRightIconPressed: () {/* Handle menu */},
              ),
            Expanded(child: questionnaireScreensList[currentQuestionnaireIndex]),
          ],
        ),
      ),
    );
  }
}
