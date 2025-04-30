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
    debugPrint("$greenLog${questionnaire.questions![0].description}");

    //Clearing the provider of it's value
    //In the future need to implement caching for when out of range of internet
    //And only clearing after succesfull cache, then submit all reports after reconnect
    //Probably in a seperate function that doesn't return a questionnaire to the frontend
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
  void updateImpactedArea(String value) {
    formProvider.setImpactedArea(value);
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

  @override
  PossesionDamageReport buildPossionReport() {
    debugPrint("✅ buildReportTesting called");
    try {
      // Log provider state
      debugPrint("📍 MapProvider state: selectedPosition=${mapProvider.selectedPosition}, currentPosition=${mapProvider.currentPosition}");
      debugPrint("📋 formProvider state: "
          "impactedCrop=${formProvider.impactedCrop}, "
          "impactedAreaType=${formProvider.impactedAreaType}, "
          "impactedArea=${formProvider.impactedArea}, "
          "currentDamage=${formProvider.currentDamage}, "
          "expectedDamage=${formProvider.expectedDamage}, "
          "description=${formProvider.description}, "
          "suspectedSpeciesID=${formProvider.suspectedSpeciesID}");

      // Validate positions
      if (mapProvider.selectedPosition == null || mapProvider.currentPosition == null) {
        debugPrint("❗ One or both positions are null: "
            "selectedPosition=${mapProvider.selectedPosition}, "
            "currentPosition=${mapProvider.currentPosition}");
      }

      // Use actual positions if available, fallback to defaults
      final systemReportLocation = ReportLocation(
        latitude: mapProvider.currentPosition?.latitude ?? 20,
        longtitude: mapProvider.currentPosition?.longitude ?? 20, // Fixed typo: longtitude -> longitude
      );
      final userReportLocation = ReportLocation(
        latitude: mapProvider.selectedPosition?.latitude ?? 20,
        longtitude: mapProvider.selectedPosition?.longitude ?? 20,
      );

      // Validate formProvider inputs
      if (formProvider.impactedCrop.isEmpty) {
        throw Exception("Impacted crop is empty");
      }
      if (formProvider.impactedArea.isEmpty) {
        throw Exception("Impacted area is empty");
      }
      final impactedArea = double.tryParse(formProvider.impactedArea);
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