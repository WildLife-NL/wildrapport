import 'package:flutter/material.dart';
import 'package:wildrapport/models/beta_models/response_model.dart';

class ResponseProvider extends ChangeNotifier {
  String? answerID;
  String? interactionID;
  String? questionID;
  String? text;
  Response? response;
  List<Response> responses = [];
  bool updatingResponse = false;
  bool hasErrorAnswerID = false;
  bool hasErrorText = false;

  final yellowLog = '\x1B[93m';

  void setResponse(Response value) {
    response = value;
    notifyListeners();
  }

  void addResponse(Response value) {
    debugPrint("$yellowLog [ResponseProvider]: Adding Response: $value");
    responses.add(value);
    notifyListeners();
  }

  void removeResponse(Response value) {
    debugPrint("$yellowLog [ResponseProvider]: Removing Response: $value");
    responses.remove(value);
    notifyListeners();
  }

  void setUpdatingResponse(bool value) {
    debugPrint("$yellowLog [ResponseProvider]: Updating Response: $value");
    updatingResponse = value;
    notifyListeners();
  }

  void updateResponse(Response? value) {
    if (value != null) {
      debugPrint("$yellowLog [ResponseProvider]: Updating response with ${value.answerID}");
      final index = responses.indexWhere((r) => r.questionID == value.questionID);
      if (index != -1) {
        debugPrint("$yellowLog [ResponseProvider]: Update successful at index $index");
        responses[index] = value;
        notifyListeners();
      }
    }
  }

  void setAnswerID(String value) {
    debugPrint("$yellowLog [ResponseProvider]: Setting answerID: $value");
    answerID = value;
    notifyListeners();
  }

  void clearAnswerID() {
    debugPrint("$yellowLog [ResponseProvider]: Clearing answerID");
    answerID = null;
    notifyListeners();
  }

  void setInteractionID(String value) {
    debugPrint("$yellowLog [ResponseProvider]: Setting interactionID: $value");
    interactionID = value;
    notifyListeners();
  }

  void setQuestionID(String value) {
    debugPrint("$yellowLog [ResponseProvider]: Setting questionID: $value");
    questionID = value;
    notifyListeners();
  }

  void setText(String value) {
    debugPrint("$yellowLog [ResponseProvider]: Setting text: $value");
    text = value;
    notifyListeners();
  }

  void setErrorState(String field, bool hasError) {
    debugPrint("$yellowLog [ResponseProvider]: Setting error state for $field: $hasError");
    if (field == 'answerID') {
      hasErrorAnswerID = hasError;
    } else if (field == 'text') {
      hasErrorText = hasError;
    }
    notifyListeners();
  }

  Response buildResponse() {
    return Response(
      answerID: answerID,
      interactionID: interactionID!,
      questionID: questionID!,
      text: text,
    );
  }

  void clearResponse() {
    debugPrint("$yellowLog [ResponseProvider]: Clearing response");
    response = null;
    answerID = null;
    interactionID = null;
    // Only clear questionID if explicitly needed
    text = null;
    updatingResponse = false;
    hasErrorAnswerID = false;
    hasErrorText = false;
    notifyListeners();
  }

  void clearResponsesList() {
    debugPrint("$yellowLog [ResponseProvider]: Clearing responses list");
    responses = [];
    notifyListeners();
  }
}