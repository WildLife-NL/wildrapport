class Answer {
  String id;
  int index;
  String? nextQuestionId;
  String text;

  Answer({
    required this.id,
    required this.index,
    required this.text,
    this.nextQuestionId,
  });

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
    id: (json["ID"] ?? json["id"])?.toString() ?? '',
    index: (json["index"] is int) ? json["index"] as int : 0,
    nextQuestionId: json["nextQuestionID"] ?? json["nextQuestionId"]?.toString(),
    text: json["text"]?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    "ID": id,
    "index": index,
    "nextQuestionID": nextQuestionId,
    "text": text,
  };
}
