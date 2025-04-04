import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/models/api_models/question.dart';

class QuestionnaireOpenResponse extends StatefulWidget {
  final Question question;
  final Questionnaire questionnaire;
  final VoidCallback onNextPressed;
  final VoidCallback onBackPressed;

  const QuestionnaireOpenResponse({
    super.key,
    required this.question,
    required this.questionnaire,
    required this.onNextPressed,
    required this.onBackPressed,
  });

  @override
  State<QuestionnaireOpenResponse> createState() => _QuestionnaireOpenResponseState();
}

class _QuestionnaireOpenResponseState extends State<QuestionnaireOpenResponse> {
  final TextEditingController _responseController = TextEditingController();

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
          // Single TextField for open response
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: TextField(
              controller: _responseController,
              maxLines: 10,  // Adjust this for the number of lines you want
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
            child: Container(), // This will take up remaining space
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
