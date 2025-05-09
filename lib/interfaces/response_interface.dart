import '../models/beta_models/response_model.dart';

abstract class ResponseInterface {
  void storeResponse(
    Response response,
    String questionaireID,
    String questionID,
  );
  void submitResponses();
  void updateResponse(
    Response response,
    String questionaireID,
    String questionID,
  );
}
