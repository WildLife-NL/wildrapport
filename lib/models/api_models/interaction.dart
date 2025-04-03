import 'package:wildrapport/models/api_models/interaction_type.dart';
import 'package:wildrapport/models/api_models/location.dart';
import 'package:wildrapport/models/api_models/species.dart';
import 'package:wildrapport/models/api_models/user.dart';

class Interaction {
  User user;
  String? id;
  String description;
  Location location;
  Species species;
  InteractionType type;
  DateTime timestamp;
  Questionnaire? questionnaire;

  Interaction({
    required this.user,
    required this.description,
    required this.location,
    required this.species,
    required this.type,
    required this.timestamp,
    this.id,
    this.questionnaire,
  });

  factory Interaction.fromJson(Map<String, dynamic> json) {
    Questionnaire? questionnaire;

    if (json['questionnaire'] != null) {
      questionnaire = Questionnaire.fromJson(json['questionnaire']);
    }

    return Interaction(
      user: User.fromJson(json['user']),
      id: json['ID'],
      description: json['description'],
      location: Location.fromJson(json['location']),
      species: Species.fromJson(json['species']),
      type: InteractionType.fromJson(json['type']),
      timestamp: DateTime.tryParse(json['timestamp'])!,
      questionnaire: questionnaire,
    );
  }
}