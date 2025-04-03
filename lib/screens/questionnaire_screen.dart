import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/questionnaire_interface.dart';

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
    _questionnaireManager = context.read<QuestionnaireInterface>();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(

    );
  }
}