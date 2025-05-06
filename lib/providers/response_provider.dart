import 'package:flutter/material.dart';
import 'package:wildrapport/models/beta_models/response_model.dart';

class ResponseProvider extends ChangeNotifier {
  String? answerID;
  String? interactionID;
  String? questionID;
  String? text;

  final yellowLog = '\x1B[93m';

  void setAnswerID(String value) {
    debugPrint("$yellowLog [ResponseProvider]: setting the answerID: $value");
    answerID = value;
    notifyListeners();
  }  

  void setInteractionID(String value) {
    debugPrint("$yellowLog [ResponseProvider]: setting the interactionID: $value");
    interactionID = value;
    notifyListeners();
  }  
  
  void setQuestionID(String value) {
    debugPrint("$yellowLog [ResponseProvider]: setting the questionID: $value");
    questionID = value;
    notifyListeners();
  }  
  
  void setText(String value) {
    debugPrint("$yellowLog [ResponseProvider]: setting the text: $value");
    text = value;
    notifyListeners();
  }
  Response buildResponse(){
    return Response(
      answerID: answerID,
      interactionID: interactionID!,
      questionID: questionID!,
      text: text,
    );
  }

  void clearResponse() {
    answerID = null;
    interactionID = null;
    questionID = null;
    text = null;
    notifyListeners();
  }
}