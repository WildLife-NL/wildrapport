import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/api/questionaire_api.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/interfaces/questionnaire_interface.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/screens/login_screen.dart';
import 'package:wildrapport/screens/overzicht_screen.dart';
import 'package:wildrapport/widgets/questionnaire/questionnaire_home_buttons.dart';

class QuestionnaireHome extends StatefulWidget{
  const QuestionnaireHome({super.key});

  @override
  State<QuestionnaireHome> createState() => _QuestionnaireHomeState();
}

class _QuestionnaireHomeState extends State<QuestionnaireHome>{
  late final QuestionnaireInterface _questionnaireManager;

  @override
  void initState() {
    super.initState();
    _questionnaireManager = context.read<QuestionnaireInterface>();
    debugPrint("Home");
  }
  @override
  Widget build(BuildContext context){
    return
      Column(
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 100.0),            
              child: Text(
              "Wil je de natuur helpen door een paar vragen te beantwoorden?",
              textAlign: TextAlign.center,
              style: AppTextTheme.textTheme.titleMedium?.copyWith(
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.25),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
            ),
          ),
          Column(
            children: [
              Text(
                "Total",
                style: AppTextTheme.textTheme.titleLarge?.copyWith(
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.25),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
              ),
              Text(
                "${_questionnaireManager.getAmountOfQuestions(2)}",
                style: AppTextTheme.textTheme.titleLarge?.copyWith(
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.25),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
              )
            ],
          ),
          QuestionnaireHomeButtons(
            onOverslaanPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OverzichtScreen(),
                ),
              );
            },
            onBewaarVoorLaterPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OverzichtScreen(),
                ),
              );
            },
            onVragenlijnstOpenenPressed: () {
              Future<Questionnaire> questionnaire = _questionnaireManager.getQuestionnaire();
              debugPrint("Name: $questionnaire");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      );
  }
}