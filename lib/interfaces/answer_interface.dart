import 'package:wildrapport/models/api_models/answer.dart';

abstract class AnswerInterface {
  void submitAnswer(String interactionID, String questionID, String answerID, String text);
  void storeAnswer(Answer answer, String questionaireID);
  void submitStoredAnswer();
}