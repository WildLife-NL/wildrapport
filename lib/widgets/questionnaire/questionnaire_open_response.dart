import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/providers/response_provider.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/models/api_models/question.dart';

class QuestionnaireOpenResponse extends StatefulWidget {
  final Question question;
  final Questionnaire questionnaire;
  final String interactionID;
  final VoidCallback onNextPressed;
  final VoidCallback onBackPressed;

  final redLog = '\x1B[31m';

  const QuestionnaireOpenResponse({
    super.key,
    required this.question,
    required this.questionnaire,
    required this.interactionID,
    required this.onNextPressed,
    required this.onBackPressed,
  });

  @override
  State<QuestionnaireOpenResponse> createState() => _QuestionnaireOpenResponseState();
}

class _QuestionnaireOpenResponseState extends State<QuestionnaireOpenResponse> {
  final TextEditingController _responseController = TextEditingController();
  late final ResponseProvider responseProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      responseProvider = context.read<ResponseProvider>();
      responseProvider.setInteractionID(widget.interactionID);
      responseProvider.setQuestionID(widget.question.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 12.0),
            child: Text(
              'Vraag ${widget.question.index} van ${widget.questionnaire.questions?.length}',
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.brown),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 12.0),
            child: Text(
              widget.question.text,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.brown),
            ),
          ),
          const SizedBox(height: 1),
          if (widget.question.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.question.description,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 18, color: AppColors.brown),
              ),
            ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: TextField(
              controller: _responseController,
              onChanged: (value) {
                  responseProvider.setText(value);
                  responseProvider.buildResponse();
              },
              maxLines: 10,  
              decoration: InputDecoration(
                hintText: 'Schrijf hier uw antwoord...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              style: const TextStyle(fontSize: 18, color: AppColors.brown),
            ),
          ),
          Expanded(
            child: Container(), 
          ),
          CustomBottomAppBar(
            onNextPressed: widget.onNextPressed,
            onBackPressed: widget.onBackPressed,
          ),
        ],
      ),
    );
  }
}
