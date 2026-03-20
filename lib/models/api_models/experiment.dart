import 'package:wildrapport/models/api_models/living_labs.dart';
import 'package:wildrapport/models/api_models/user.dart';

class Experiment {
  String id;
  String description;
  DateTime? end;
  LivingLabs? livingLab;
  int? messageActivity;
  String name;
  int? numberOfMessages;
  int? numberOfQuestionnaires;
  int? questionnaireActivity;
  DateTime start;
  User user;

  Experiment({
    required this.id,
    required this.description,
    required this.name,
    required this.start,
    required this.user,
    this.livingLab,
    this.numberOfMessages,
    this.numberOfQuestionnaires,
    this.questionnaireActivity,
    this.messageActivity,
    this.end,
  });

  factory Experiment.fromJson(Map<String, dynamic> json) {
    DateTime? contertedEnd;
    LivingLabs? convertedLivingLabs;

    if (json["end"] != null) {
      try {
        contertedEnd = DateTime.parse(json["end"].toString());
      } catch (_) {}
    }
    if (json["livingLab"] != null && json["livingLab"] is Map<String, dynamic>) {
      convertedLivingLabs = LivingLabs.fromJson(json["livingLab"] as Map<String, dynamic>);
    }

    DateTime startDate = DateTime.now();
    if (json["start"] != null) {
      try {
        startDate = DateTime.parse(json["start"].toString());
      } catch (_) {}
    }

    final userJson = json["user"];
    final User user = userJson != null && userJson is Map<String, dynamic>
        ? User.fromJson(userJson)
        : User(id: 'N/A', email: null);

    return Experiment(
      id: (json["ID"] ?? json["id"])?.toString() ?? 'N/A',
      description: json["description"]?.toString() ?? '',
      end: contertedEnd,
      livingLab: convertedLivingLabs,
      messageActivity: json["messageActivity"] as int?,
      name: json["name"]?.toString() ?? 'N/A',
      numberOfMessages: json["numberOfMessages"] as int?,
      numberOfQuestionnaires: json["numberOfQuestionnaires"] as int?,
      questionnaireActivity: json["questionnaireActivity"] as int?,
      start: startDate,
      user: user,
    );
  }

  Map<String, dynamic> toJson() {
    String? endString;
    Map<String, dynamic>? livingLabString;

    if (end != null) {
      endString = end!.toIso8601String();
    }
    if (livingLab != null) {
      livingLabString = livingLab!.toJson();
    }

    return {
      "ID": id,
      "description": description,
      "end": endString,
      "livingLab": livingLabString,
      "messageActivity": messageActivity,
      "name": name,
      "numberOfMessages": numberOfMessages,
      "numberOfQuestionnaires": numberOfQuestionnaires,
      "questionnaireActivity": questionnaireActivity,
      "start": start.toIso8601String(),
      "user": user.toJson(),
    };
  }
}
