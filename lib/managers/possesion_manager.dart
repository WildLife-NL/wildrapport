import 'package:flutter/material.dart';
import 'package:wildrapport/interfaces/api/interaction_api_interface.dart';
import 'package:wildrapport/interfaces/possesion_interface.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/models/beta_models/interaction_model.dart';
import 'package:wildrapport/models/beta_models/possesion_damage_report_model.dart';
import 'package:wildrapport/models/beta_models/possesion_model.dart';
import 'package:wildrapport/models/beta_models/report_location_model.dart';
import 'package:wildrapport/models/enums/interaction_type.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/providers/possesion_damage_report_provider.dart';
import 'package:wildrapport/widgets/possesion/gewasschade_details.dart';
import 'package:wildrapport/widgets/possesion/suspected_animal.dart';

class PossesionManager implements PossesionInterface {
  final InteractionApiInterface interactionAPI;
  final PossesionDamageFormProvider formProvider;
  final MapProvider mapProvider;

  PossesionManager(this.interactionAPI, this.formProvider, this.mapProvider);

  final greenLog = '\x1B[32m';
  final redLog = '\x1B[31m';
  final yellowLog = '\x1B[93m';

  @override
  List<dynamic> buildPossesionWidgetList() {
    return [
      GewasschadeDetails(),
      SuspectedAnimal(),
    ];
  }

  @override
  Future<Questionnaire> postInteraction() async {
    final interaction = Interaction(
      interactionType: InteractionType.gewasschade,
      userID: "4790e81a-dbfb-4316-9d85-8275de240f01", //Temp because we don't safe user date yet
      report: buildPossionReport(),
    );
    final questionnaire = await interactionAPI.sendInteraction(interaction);
    debugPrint("$greenLog${questionnaire.name}");
    
    // Add null check before accessing questions
    if (questionnaire.questions != null && questionnaire.questions!.isNotEmpty) {
      debugPrint("$greenLog${questionnaire.questions![0].description}");
    } else {
      debugPrint("${greenLog}No questions available in questionnaire");
    }

    //Clearing the provider of it's value
    formProvider.clearStateOfValues(); 

    return questionnaire;
  }

  @override
  void updateSystemLocation(ReportLocation value) {
    formProvider.setSystemLocation(value);
  }

  @override
  void updateUserLocation(ReportLocation value) {
    formProvider.setUserLocation(value);
  }

  @override
  void updateCurrentDamage(double value) {
    formProvider.setCurrentDamage(value);
  }

  @override
  void updateDescription(String value) {
    formProvider.setDescription(value);
  }

  @override
  void updateExpectedDamage(double value) {
    formProvider.setExpectedDamage(value);
  }

  @override
  void updateImpactedArea(double value) {
    try {
      if(formProvider.impactedAreaType == "hectare"){
        debugPrint("$greenLog impactArea selected is Hectare");
        formProvider.setImpactedArea(value * 10000);
      }
      else if(formProvider.impactedAreaType == "vierkante meters"){
        debugPrint("$greenLog impactArea selected is Vierkante Meters");
        formProvider.setImpactedArea(value);
      }
      else{
        throw Exception("$redLog Impacted Area Type of: ${formProvider.impactedAreaType} Isn't Valid!");
      }
    } catch(e, stackTrace){
      debugPrint("$redLog Something went wrong:");
      debugPrint("$redLog Message: ${e.toString()}");
      debugPrint("$redLog Stacktrace: $stackTrace");

    }
  }

  @override
  void updateImpactedAreaType(String value) {
    formProvider.setImpactedAreaType(value);
  }

  @override
  void updateImpactedCrop(String value) {
    formProvider.setImpactedCrop(value);
  }

  @override
  void updateSuspectedAnimal(String value) {
    formProvider.setSuspectedAnimal(value);
  }
  //we only use vierkante meters and unit, unit as in number of sheep in the future
  String getCorrectImpactArea(){
    return "vierkante meters";
  }
  @override
  PossesionDamageReport buildPossionReport() {
    debugPrint("✅ buildReportTesting called");
    try {
      // Log provider state
      debugPrint("📍 formProvider location state: selectedPosition=${formProvider.userLocation}, currentPosition=${formProvider.systemLocation}");
      debugPrint("📋 formProvider state: "
          "impactedCrop=${formProvider.impactedCrop}, "
          "impactedAreaType=$getCorrectImpactArea()"
          "impactedArea=${formProvider.impactedArea}, "
          "currentDamage=${formProvider.currentDamage}, "
          "expectedDamage=${formProvider.expectedDamage}, "
          "description=${formProvider.description}, "
          "suspectedSpeciesID=${formProvider.suspectedSpeciesID}");

      // Validate positions
      if (formProvider.userLocation == null || formProvider.systemLocation == null) {
        debugPrint("❗ One or both positions are null: "
            "selectedPosition=${formProvider.userLocation}, "
            "currentPosition=${formProvider.systemLocation}");
      }

      // Use actual positions if available, fallback to defaults
      final systemReportLocation = formProvider.systemLocation ?? ReportLocation(latitude: 20.0, longtitude: 20.0);
      final userReportLocation = formProvider.userLocation ?? ReportLocation(latitude: 20.0, longtitude: 20.0);

      // Validate formProvider inputs
      if (formProvider.impactedCrop.isEmpty) {
        throw Exception("Impacted crop is empty");
      }
      if (formProvider.impactedArea == 0) {
        throw Exception("Impacted area is empty");
      }
      final impactedArea = formProvider.impactedArea;
      if (impactedArea == null) {
        throw Exception("Invalid impacted area: ${formProvider.impactedArea}");
      }

      final report = PossesionDamageReport(
        possesion: Possesion(
          possesionID: "3c6c44fc-06da-4530-ab27-3974e6090d7d",
          possesionName: formProvider.impactedCrop,
          category: "gewassen",
        ),
        impactedAreaType: formProvider.impactedAreaType,
        impactedArea: impactedArea,
        currentImpactDamages: formProvider.currentDamage.toString(),
        estimatedTotalDamages: formProvider.expectedDamage.toString(),
        description: formProvider.description,
        suspectedSpeciesID: formProvider.suspectedSpeciesID,
        userSelectedDateTime: DateTime.now(),
        systemDateTime: DateTime.now(),
        systemLocation: systemReportLocation,
        userSelectedLocation: userReportLocation,
      );

      debugPrint("✅ Report created: $report");
      return report;
    } catch (e, stackTrace) {
      debugPrint("❌ Exception in buildReportTesting: $e");
      debugPrint("🔍 Stack trace: $stackTrace");
      rethrow;
    }
  }
}
