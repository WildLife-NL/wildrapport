import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/models/api_models/question.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/models/beta_models/response_model.dart';
import 'package:wildrapport/providers/response_provider.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/questionnaire/shared_white_background.dart';

class QuestionnaireMultipleChoice extends StatefulWidget {
  final ResponseProvider responseProvider;
  final Question question;
  final Questionnaire questionnaire;
  final String interactionID;
  final VoidCallback onNextPressed;
  final VoidCallback onBackPressed;
  final int index;

  const QuestionnaireMultipleChoice({
    super.key,
    required this.responseProvider,
    required this.question,
    required this.questionnaire,
    required this.interactionID,
    required this.onNextPressed,
    required this.onBackPressed,
    required this.index,
  });

  @override
  State<QuestionnaireMultipleChoice> createState() =>
      _QuestionnaireMultipleChoiceState();
}

class _QuestionnaireMultipleChoiceState extends State<QuestionnaireMultipleChoice> {
  Response? existingResponse;
  String? selectedAnswerID;
  List<String> selectedAnswerIDs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.responseProvider.setInteractionID(widget.interactionID);
      widget.responseProvider.setQuestionID(widget.question.id);
      existingResponse = widget.responseProvider.responses.firstWhereOrNull(
        (response) => response.questionID == widget.question.id,
      );
      setState(() {
        selectedAnswerID = existingResponse?.answerID;
        selectedAnswerIDs = existingResponse?.answerID?.split(',') ?? [];
        debugPrint("[QuestionnaireMultipleChoice]: Initialized with questionID: ${widget.question.id}, selectedAnswerID: $selectedAnswerID");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SharedWhiteBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 12.0),
              child: Text(
                'Vraag ${widget.index + 1} van ${widget.questionnaire.questions?.length}',
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
                        value: selectedAnswerIDs.contains(answer.id),
                        title: Text(
                          answer.text,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.brown,
                          ),
                        ),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              selectedAnswerIDs.add(answer.id);
                            } else {
                              selectedAnswerIDs.remove(answer.id);
                            }

                            final updatedAnswerID = selectedAnswerIDs.join(',');

                            if (existingResponse != null) {
                              widget.responseProvider.setUpdatingResponse(true);
                              widget.responseProvider.updateResponse(
                                existingResponse!.copyWith(answerID: updatedAnswerID),
                              );
                            } else {
                              final newResponse = Response(
                                answerID: updatedAnswerID,
                                interactionID: widget.interactionID,
                                questionID: widget.question.id,
                              );
                              widget.responseProvider.addResponse(newResponse);
                              existingResponse = newResponse;
                            }
                            widget.responseProvider.setErrorState('answerID', false);
                            debugPrint("[QuestionnaireMultipleChoice]: Updated answerID: $updatedAnswerID");
                          });
                        },
                      )
                    : RadioListTile<String?>(
                        title: Text(
                          answer.text,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.brown,
                          ),
                        ),
                        value: answer.id,
                        groupValue: selectedAnswerID,
                        onChanged: (String? value) {
                          setState(() {
                            selectedAnswerID = value;
                            if (existingResponse != null && value != null) {
                              widget.responseProvider.setUpdatingResponse(true);
                              widget.responseProvider.updateResponse(
                                existingResponse!.copyWith(answerID: value),
                              );
                            } else if (value != null) {
                              final newResponse = Response(
                                answerID: value,
                                interactionID: widget.interactionID,
                                questionID: widget.question.id,
                              );
                              widget.responseProvider.addResponse(newResponse);
                              existingResponse = newResponse;
                            } else if (existingResponse != null) {
                              // Remove response if deselected
                              widget.responseProvider.removeResponse(existingResponse!);
                              existingResponse = null;
                            }
                            widget.responseProvider.setErrorState('answerID', false);
                            debugPrint("[QuestionnaireMultipleChoice]: Selected answerID: $value");
                          });
                        },
                      );
              }),
            if (widget.responseProvider.hasErrorAnswerID)
              const Padding(
                padding: EdgeInsets.only(left: 12.0, top: 8.0),
                child: Text(
                  'Kies een antwoord',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            Expanded(
              child: Container(),
            ),
            CustomBottomAppBar(
              onNextPressed: () {
                widget.responseProvider.setQuestionID(widget.question.id);
                debugPrint("[QuestionnaireMultipleChoice]: Setting questionID to ${widget.question.id} before next");
                widget.onNextPressed();
              },
              onBackPressed: widget.onBackPressed,
            ),
          ],
        ),
      ),
    );
  }
}