import 'package:flutter/material.dart';
import 'package:wildrapport/interfaces/api/interaction_api_interface.dart';
import 'package:wildrapport/interfaces/possesion_interface.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/models/beta_models/interaction_model.dart';
import 'package:wildrapport/models/beta_models/possesion_damage_report_model.dart';
import 'package:wildrapport/models/enums/interaction_type.dart';
import 'package:wildrapport/widgets/possesion/gewasschade_details.dart';
import 'package:wildrapport/widgets/possesion/suspected_animal.dart';

class PossesionManager implements PossesionInterface{
  final InteractionApiInterface interactionAPI;
  PossesionManager(this.interactionAPI);
  final greenLog = '\x1B[32m';
  @override
  List<dynamic> buildPossesionWidgetList() {
    List<dynamic> possesionWidgetList = [];
    
    possesionWidgetList.add(GewasschadeDetails());
    possesionWidgetList.add(SuspectedAnimal());

    return possesionWidgetList;
  }

  @override
  Future<Questionnaire> postInteraction(PossesionDamageReport possesionDamageReport) async {

    final interaction = Interaction
    (
      interactionType: InteractionType.gewasschade, 
      userID: "4790e81a-dbfb-4316-9d85-8275de240f01",
      report: possesionDamageReport,
    );
    Questionnaire questionnaire = await interactionAPI.sendInteraction(interaction);
    debugPrint("$greenLog${questionnaire.name}");
    debugPrint("$greenLog${questionnaire.questions![0].description}");

    return questionnaire;
  }
}