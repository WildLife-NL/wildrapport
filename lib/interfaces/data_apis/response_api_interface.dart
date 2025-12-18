abstract class ResponseApiInterface {
  Future<bool> addReponse(
    String interactionID,
    String questionID,
    String? answerID,
    String? text,
  );

  /// Fetch responses for the current authenticated user
  Future<List<dynamic>> getMyResponsesRaw();
}
