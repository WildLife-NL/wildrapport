import 'package:flutter/material.dart';
import 'package:wildrapport/interfaces/answer_interface.dart';
import 'package:wildrapport/interfaces/api/answer_api_interface.dart';
import 'package:wildrapport/models/api_models/answer.dart';

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

  @override
  void storeAnswer(Answer answer, String questionaireID) {
    
    // TODO: implement storeAnswer
  }

  @override
  void submitStoredAnswer() {
    List<AnswerObject> answers;


    // TODO: implement submitStoredAnswer
  }
}

class AnswersListObject{
  Map<String, AnswerObject> answers; 

  AnswersListObject(this.answers);
  
  factory AnswersListObject.fromJson(Map<String, dynamic> json) {
    return AnswersListObject(

    );
  }

  Map<String, dynamic> toJson() {
    return {
     
    };
  }
}

class AnswerObject{
  Map<String, Answer> answer;

  AnswerObject(this.answer);

  factory AnswerObject.fromJson(Map<String, dynamic> json) {
    return AnswerObject(
     
    );
  }

  Map<String, dynamic> toJson() {
    return {
      
    };
  }
}