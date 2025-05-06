class Response {
  String? answerID;
  String interactionID;
  String questionID;
  String? text;

  Response({
    this.answerID,
    required this.interactionID,
    required this.questionID,
    this.text,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
    answerID: json["answerID"],
    interactionID: json["interactionID"],
    questionID: json["questionID"],
    text: json["text"],
  );

  Map<String, dynamic> toJson() => {
    "answerID": answerID,
    "interactionID": interactionID,
    "questionID": questionID,
    "text": text,
  };
}