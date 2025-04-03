import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/questionnaire_interface.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/questionnaire/questionnaire_home.dart';
import 'package:wildrapport/widgets/questionnaire/questionnaire_home_buttons.dart';

class QuestionnaireScreen extends StatefulWidget{
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen>{
  late final QuestionnaireInterface _questionnaireManager;


  @override
  void initState() {
    super.initState();
    debugPrint("Here");
    _questionnaireManager = context.read<QuestionnaireInterface>();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: CustomAppBar(
                leftIcon: Icons.arrow_back_ios,
                centerText: "Vragenlijst",
                rightIcon: Icons.menu,
                onLeftIconPressed: () => Navigator.pop(context),
                onRightIconPressed: () {/* Handle menu */},
              ),
          ),
          Expanded(child: QuestionnaireHome()),
        ],
      ),
    );
  }
}