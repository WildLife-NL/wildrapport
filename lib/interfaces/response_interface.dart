
import '../models/beta_models/response_model.dart';

abstract class ResponseInterface {
  void submitResponse(String answerID, String interactionID, String questionID, String text); //Deprecated, won't be suported in final version!
  void storeResponse(Response response, String questionaireID, String questionID);
  void submitStoredResponses();
  void updateResponse(Response response, String questionaireID, String questionID);
}