import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/interfaces/data_apis/interaction_api_interface.dart';
import 'package:wildrapport/interfaces/reporting/possesion_report_fields.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/models/beta_models/accident_report_model.dart';
import 'package:wildrapport/models/beta_models/animal_sighting_report_wrapper.dart';
import 'package:wildrapport/models/beta_models/interaction_model.dart';
import 'package:wildrapport/models/beta_models/interaction_response_model.dart';
import 'package:wildrapport/models/enums/interaction_type.dart';
import 'package:wildlifenl_rapporten_components/wildlifenl_rapporten_components.dart';

class InteractionApi implements InteractionApiInterface {
  final ApiClient client;
  final greenLog = '\x1B[32m';
  final redLog = '\x1B[31m';
  final yellowLog = '\x1B[93m';
  InteractionApi(this.client);

  @override
  Future<InteractionResponse> sendInteraction(Interaction interaction) async {
    try {
      debugPrint("$yellowLog[InteractionAPI]: Starting sendInteraction");
      http.Response response;

      switch (interaction.interactionType) {
        case InteractionType.waarneming:
          debugPrint("$yellowLog[InteractionAPI]: Report is waarneming");
          if (interaction.report is AnimalSightingReportWrapper) {
            final apiPayload =
                interaction.report
                    .toJson(); // Use the wrapper's toJson directly
            response = await client.post(
              'interaction/',
              apiPayload,
              authenticated: true,
            );
          } else {
            throw Exception(
              "Invalid report type for waarnemning: ${interaction.report.runtimeType}",
            );
          }
          break;
        case InteractionType.gewasschade:
          debugPrint("$yellowLog========================================");
          debugPrint("$yellowLog[InteractionAPI]: Report is gewasschade");
          if (interaction.report is PossesionReportFields) {
            final report = interaction.report as PossesionReportFields;
            final locLat = report.systemLocation?.latitude ?? 0.0;
            final locLon = report.systemLocation?.longtitude ?? 0.0;
            final placeLat = report.userSelectedLocation?.latitude ?? 0.0;
            final placeLon = report.userSelectedLocation?.longtitude ?? 0.0;
            final moment = report.userSelectedDateTime ?? report.systemDateTime;
            final speciesID = report.suspectedSpeciesID ?? '';
            final payload = RapportenApiBodyBuilder.buildDamageBody(
              description: report.description ?? '',
              locationLatitude: locLat,
              locationLongitude: locLon,
              placeLatitude: placeLat,
              placeLongitude: placeLon,
              moment: moment,
              speciesID: speciesID,
              belonging: report.possesion.possesionName ?? '',
              estimatedDamage: report.currentImpactDamages.toInt(),
              estimatedLoss: report.estimatedTotalDamages.toInt(),
              impactType: report.impactedAreaType == 'units' ? 'units' : 'square-meters',
              impactValue: report.impactedArea.toInt(),
            );
            debugPrint("$yellowLog[InteractionAPI]: GEWASSCHADE Payload:");
            debugPrint("$yellowLog${jsonEncode(payload)}");
            debugPrint("$yellowLog========================================");
            response = await client.post(
              'interaction/',
              payload,
              authenticated: true,
            );
          } else {
            throw Exception(
              "Invalid report type for gewasschade: ${interaction.report.runtimeType}",
            );
          }
          break;
        case InteractionType.verkeersongeval:
          debugPrint("$yellowLog[InteractionAPI]: Report is verkeersongeval");
          if (interaction.report is AccidentReport) {
            final report = interaction.report as AccidentReport;
            final involvedList = <InvolvedAnimalDto>[
              ...(report.animals ?? []).map((a) => InvolvedAnimalDto(
                    condition: _normalizeCondition(a.condition),
                    lifeStage: a.lifeStage,
                    sex: a.sex,
                  )),
            ];
            if (involvedList.isEmpty) {
              involvedList.add(const InvolvedAnimalDto(
                condition: 'unknown',
                lifeStage: 'unknown',
                sex: 'unknown',
              ));
            }
            final payload = RapportenApiBodyBuilder.buildCollisionBody(
              description: report.description ?? '',
              locationLatitude: report.systemLocation?.latitude ?? 0.0,
              locationLongitude: report.systemLocation?.longtitude ?? 0.0,
              placeLatitude: report.userSelectedLocation?.latitude ?? 0.0,
              placeLongitude: report.userSelectedLocation?.longtitude ?? 0.0,
              moment: report.userSelectedDateTime ?? report.systemDateTime,
              speciesID: report.suspectedSpeciesID ?? '',
              estimatedDamage: int.tryParse(report.damages) ?? 0,
              intensity: report.intensity,
              urgency: report.urgency,
              involvedAnimals: involvedList,
            );
            response = await client.post(
              'interaction/',
              payload,
              authenticated: true,
            );
          } else {
            throw Exception(
              "Invalid report type for verkeersongeval: ${interaction.report.runtimeType}",
            );
          }
          break;
      }

      debugPrint(
        "$greenLog[InteractionAPI] Response code: ${response.statusCode}",
      );
      debugPrint("$greenLog[InteractionAPI] Response body: ${response.body}");

      if (response.statusCode == HttpStatus.ok) {
        final json = jsonDecode(response.body);
        if (json == null) {
          throw Exception("Empty response received from server");
        }

        debugPrint("$yellowLog========================================");
        debugPrint("$yellowLog[InteractionAPI]: CHECKING FOR QUESTIONNAIRE");
        final questionnaireJson = json['questionnaire'];
        final String interactionID = json['ID'];

        debugPrint(
          "$yellowLog[InteractionAPI]: InteractionID from backend: $interactionID",
        );
        debugPrint(
          "$yellowLog[InteractionAPI]: Questionnaire in response: ${questionnaireJson != null ? 'YES' : 'NO'}",
        );

        if (questionnaireJson != null) {
          debugPrint("$yellowLog[InteractionAPI]: Questionnaire data:");
          debugPrint("$yellowLog${jsonEncode(questionnaireJson)}");
          
          // Detailed breakdown of questions and answers
          debugPrint("$yellowLog════════════════════════════════════════");
          debugPrint("$yellowLog[InteractionAPI]: DETAILED QUESTION ANALYSIS");
          debugPrint("$yellowLog════════════════════════════════════════");
          final questionsArray = questionnaireJson['questions'];
          if (questionsArray != null && questionsArray is List) {
            debugPrint("$yellowLog📋 Total questions: ${questionsArray.length}");
            for (int i = 0; i < questionsArray.length; i++) {
              final q = questionsArray[i];
              debugPrint("$yellowLog────────────────────────────────────────");
              debugPrint("$yellowLog[Q${i + 1}] ${q['text']}");
              debugPrint("$yellowLog    ID: ${q['ID']}");
              debugPrint("$yellowLog    allowMultipleResponse: ${q['allowMultipleResponse']}");
              debugPrint("$yellowLog    allowOpenResponse: ${q['allowOpenResponse']}");
              
              final answers = q['answers'];
              if (answers != null && answers is List) {
                debugPrint("$yellowLog    ✅ Has ${answers.length} answers:");
                for (int j = 0; j < answers.length; j++) {
                  final a = answers[j];
                  debugPrint("$yellowLog       [A${j + 1}] ${a['text']} (ID: ${a['ID']})");
                }
              } else {
                debugPrint("$yellowLog    ❌ NO ANSWERS PROVIDED by backend!");
              }
            }
          }
          debugPrint("$yellowLog════════════════════════════════════════");
        }
        debugPrint("$yellowLog========================================");

        if (questionnaireJson == null) {
          // Graceful handling: not all interactions yield questionnaires.
          debugPrint(
            "$yellowLog[InteractionAPI]: ▶ No questionnaire returned. Proceeding without questionnaire.",
          );
          return InteractionResponse.empty(interactionID: interactionID);
        }

        try {
          return InteractionResponse(
            questionnaire: Questionnaire.fromJson(questionnaireJson),
            interactionID: interactionID,
          );
        } catch (e) {
          debugPrint("$redLog Error parsing questionnaire: $e");
          // Fallback: return an empty questionnaire response instead of failing whole interaction
          return InteractionResponse.empty(interactionID: interactionID);
        }
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessages =
            (errorBody['errors'] as List?)
                ?.map((e) => e['message'])
                .join('; ') ??
            errorBody['detail'] ??
            'Unknown error';
        throw Exception(
          "API request failed with status ${response.statusCode}: $errorMessages",
        );
      }
    } catch (e) {
      debugPrint("$redLog[InteractionAPI] Error: $e");
      throw Exception("Failed to send interaction: $e");
    }
  }

  static String _normalizeCondition(String condition) {
    final c = condition.toLowerCase();
    if (c == 'healthy' || c == 'impaired' || c == 'dead' || c == 'unknown' || c == 'onbekend') {
      return c == 'onbekend' ? 'unknown' : c;
    }
    return 'unknown';
  }
}
