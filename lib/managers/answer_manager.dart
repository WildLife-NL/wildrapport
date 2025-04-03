import 'package:flutter/material.dart';
import 'package:wildrapport/interfaces/answer_interface.dart';
import 'package:wildrapport/interfaces/api/answer_api_interface.dart';

class AnswerManager implements AnswerInterface{
  AnswerApiInterface answerAPI;
  AnswerManager(this.answerAPI);

  @override
  void submitAnswer(String interactionID, String questionID, String answerID, String text) {
    try{
      answerAPI.addReponse(interactionID, questionID, answerID, text);
    }
    catch(error){
      debugPrint("An error occured: $error");
    }
  }
}