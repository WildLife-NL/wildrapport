import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/models/api_models/question.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/providers/response_provider.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';

class QuestionnaireMultipleChoice extends StatefulWidget {
  final Question question;
  final Questionnaire questionnaire;
  final String interactionID;
  final VoidCallback onNextPressed;
  final VoidCallback onBackPressed;

  const QuestionnaireMultipleChoice({
    super.key,
    required this.question,
    required this.questionnaire,
    required this.interactionID,
    required this.onNextPressed,
    required this.onBackPressed,
  });

  @override
  State<QuestionnaireMultipleChoice> createState() =>
      _QuestionnaireMultipleChoiceState();
}

class _QuestionnaireMultipleChoiceState
    extends State<QuestionnaireMultipleChoice> {
  List<String> _selectedAnswers = [];
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
          // Display question index and total questions
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 12.0),
            child: Text(
              'Vraag ${widget.question.index} van ${widget.questionnaire.questions?.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.brown,
              ),
            ),
          ),
          const SizedBox(height: 1),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 12.0),
            child: Text(
              widget.question.text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.brown,
              ),
            ),
          ),
          const SizedBox(height: 1),
          if (widget.question.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                widget.question.description,
                style: const TextStyle(fontSize: 18, color: AppColors.brown),
              ),
            ),
          const SizedBox(height: 24),
          if (widget.question.answers != null)
            ...widget.question.answers!.map((answer) {
              return widget.question.allowMultipleResponse
                  ? CheckboxListTile(
                    title: Text(
                      answer.text,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.brown,
                      ),
                    ),
                    value: _selectedAnswers.contains(answer.id),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedAnswers.add(answer.id);
                        } else {
                          _selectedAnswers.remove(answer.id);
                        }
                      });
                    },
                  )
                  : RadioListTile<String>(
                    title: Text(
                      answer.text,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.brown,
                      ),
                    ),
                    value: answer.id,
                    groupValue:
                        _selectedAnswers.isNotEmpty
                            ? _selectedAnswers.first
                            : null,
                    onChanged: (String? value) {
                      setState(() {
                        debugPrint("onChanged!");
                        _selectedAnswers = value != null ? [value] : [];
                        responseProvider.setAnswerID(answer.id);
                      });
                    },
                  );
            }),
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
