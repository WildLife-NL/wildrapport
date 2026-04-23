import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/interfaces/data_apis/interaction_api_interface.dart';
import 'package:wildrapport/interfaces/reporting/possesion_report_fields.dart';
import 'package:wildrapport/models/api_models/experiment.dart';
import 'package:wildrapport/models/api_models/interaction_type.dart' as api_models;
import 'package:wildrapport/models/api_models/question.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/models/api_models/user.dart';
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
            final apiPayload = interaction.report.toJson();
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
            // NOTE:
            // Backend schema for reportOfDamage changed:
            // - estimatedLoss must be string
            // - preventiveMeasures + preventiveMeasuresDescription are required
            // - estimatedDamage/impactType/impactValue are rejected
            final payload = {
              "description": report.description ?? '',
              "location": {
                "latitude": locLat,
                "longitude": locLon,
              },
              "moment": moment.toUtc().toIso8601String(),
              "place": {
                "latitude": placeLat,
                "longitude": placeLon,
              },
              "reportOfDamage": {
                "belonging": report.possesion.possesionName ?? '',
                "estimatedLoss": report.estimatedLossBucket,
                "preventiveMeasures": report.preventiveMeasures,
                "preventiveMeasuresDescription":
                    report.preventiveMeasuresDescription,
              },
              "speciesID": speciesID,
              "typeID": 2,
            };
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
            final payload = {
              'description': report.description ?? '',
              'location': {
                'latitude': report.systemLocation?.latitude ?? 0.0,
                'longitude': report.systemLocation?.longtitude ?? 0.0,
              },
              'moment':
                  (report.userSelectedDateTime ?? report.systemDateTime)
                      .toUtc()
                      .toIso8601String(),
              'place': {
                'latitude': report.userSelectedLocation?.latitude ?? 0.0,
                'longitude': report.userSelectedLocation?.longtitude ?? 0.0,
              },
              'reportOfCollision': {
                'estimatedDamage': int.tryParse(report.damages) ?? 0,
                'involvedAnimals':
                    involvedList.map((a) => a.toJson()).toList(),
                'severity': _mapCollisionSeverity(report.intensity),
              },
              'speciesID': report.suspectedSpeciesID ?? '',
              'typeID': 3,
            };
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

        final Map<String, dynamic> data = (json is Map<String, dynamic>)
            ? json
            : (json['interaction'] is Map<String, dynamic>
                ? json['interaction'] as Map<String, dynamic>
                : <String, dynamic>{});

        debugPrint("$yellowLog========================================");
        debugPrint("$yellowLog[InteractionAPI]: CHECKING FOR QUESTIONNAIRE");
        final questionnaireJson = data['questionnaire'] ?? json['questionnaire'];
        final String interactionID =
            (data['ID'] ?? data['id'] ?? json['ID'] ?? json['id'])?.toString() ?? '';

        debugPrint(
          "$yellowLog[InteractionAPI]: InteractionID from backend: $interactionID",
        );
        debugPrint(
          "$yellowLog[InteractionAPI]: Questionnaire in response: ${questionnaireJson != null ? 'YES' : 'NO'}",
        );

        if (questionnaireJson != null) {
          debugPrint("$yellowLog[InteractionAPI]: Questionnaire data:");
          debugPrint("$yellowLog${jsonEncode(questionnaireJson)}");
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
          final experimentId = _getExperimentId(data, json);
          if (experimentId != null && experimentId.isNotEmpty) {
            try {
              final list = await _fetchQuestionnairesByExperimentId(experimentId);
              final typeId = _getTypeId(data, json);
              for (final q in list) {
                if (q.questions != null && q.questions!.isNotEmpty) {
                  if (typeId == null || q.interactionType.id == typeId) {
                    debugPrint(
                      "$greenLog[InteractionAPI]: ✅ Questionnaire opgehaald via GET experiment ($experimentId), ${q.questions!.length} vragen",
                    );
                    return InteractionResponse(questionnaire: q, interactionID: interactionID);
                  }
                }
              }
              for (final q in list) {
                if (q.questions != null && q.questions!.isNotEmpty) {
                  debugPrint(
                    "$greenLog[InteractionAPI]: ✅ Questionnaire opgehaald via GET experiment ($experimentId), ${q.questions!.length} vragen",
                  );
                  return InteractionResponse(questionnaire: q, interactionID: interactionID);
                }
              }
            } catch (e) {
              debugPrint("$yellowLog[InteractionAPI]: Fetch questionnaires by experiment failed: $e");
            }
          }
          debugPrint(
            "$yellowLog[InteractionAPI]: ▶ No questionnaire returned. Proceeding without questionnaire.",
          );
          return InteractionResponse.empty(interactionID: interactionID);
        }

        try {
          return InteractionResponse(
            questionnaire: Questionnaire.fromJson(questionnaireJson is Map<String, dynamic>
                ? questionnaireJson
                : Map<String, dynamic>.from(questionnaireJson as Map)),
            interactionID: interactionID,
          );
        } catch (e, stack) {
          debugPrint("$redLog[InteractionAPI]: ❌ Questionnaire parse failed: $e");
          debugPrint("$redLog[InteractionAPI]: Stack: $stack");
          final raw = questionnaireJson != null ? jsonEncode(questionnaireJson) : 'null';
          debugPrint(
            "$redLog[InteractionAPI]: Raw questionnaire (first 800 chars): ${raw.length > 800 ? '${raw.substring(0, 800)}...' : raw}",
          );
          final fallback = _parseQuestionnaireFallback(questionnaireJson, interactionID);
          if (fallback != null) {
            debugPrint("$greenLog[InteractionAPI]: ✅ Fallback parse succeeded, ${fallback.questionnaire.questions?.length ?? 0} questions");
            return fallback;
          }
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

  static String? _getExperimentId(Map<String, dynamic> data, dynamic json) {
    final exp = data['experiment'];
    if (exp is Map) {
      final id = (exp['ID'] ?? exp['id'])?.toString();
      if (id != null && id.isNotEmpty) return id;
    }
    return (data['experimentID'] ?? json['experimentID'])?.toString();
  }

  static int? _getTypeId(Map<String, dynamic> data, dynamic json) {
    final type = data['type'] ?? json['type'];
    if (type is Map) {
      final id = type['ID'] ?? type['id'];
      if (id is int) return id;
      if (id != null) return int.tryParse(id.toString());
    }
    return null;
  }

  Future<List<Questionnaire>> _fetchQuestionnairesByExperimentId(String experimentId) async {
    final res = await client.get(
      'questionnaires/experiment/$experimentId',
      authenticated: true,
    );
    if (res.statusCode != 200) return [];
    final body = jsonDecode(res.body);
    if (body is! List) return [];
    final list = <Questionnaire>[];
    for (final item in body) {
      try {
        final map = item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item as Map);
        list.add(Questionnaire.fromJson(map));
      } catch (_) {
        continue;
      }
    }
    return list;
  }

  static InteractionResponse? _parseQuestionnaireFallback(
    dynamic questionnaireJson,
    String interactionID,
  ) {
    if (questionnaireJson == null || questionnaireJson is! Map) return null;
    final map = questionnaireJson is Map<String, dynamic>
        ? questionnaireJson
        : Map<String, dynamic>.from(questionnaireJson as Map); // ignore: unnecessary_cast
    final rawQuestions = map['questions'] ?? map['Questions'];
    if (rawQuestions == null || rawQuestions is! List || rawQuestions.isEmpty) {
      return null;
    }
    final List<Question> questions = [];
    for (final q in rawQuestions) {
      try {
        final qMap = q is Map<String, dynamic> ? q : Map<String, dynamic>.from(q is Map ? q : {});
        questions.add(Question.fromJson(qMap));
      } catch (_) {
        continue;
      }
    }
    if (questions.isEmpty) return null;
    final name = map['name']?.toString() ?? 'Vragenlijst';
    final id = (map['ID'] ?? map['id'])?.toString() ?? 'N/A';
    final experiment = Experiment(
      id: 'N/A',
      description: '',
      name: 'N/A',
      start: DateTime.now(),
      user: User(id: 'N/A', email: null),
    );
    final interactionType = api_models.InteractionType(id: 0, name: 'N/A', description: '');
    final questionnaire = Questionnaire(
      id: id,
      experiment: experiment,
      identifier: map['identifier']?.toString(),
      interactionType: interactionType,
      name: name,
      questions: questions,
    );
    return InteractionResponse(questionnaire: questionnaire, interactionID: interactionID);
  }

  static String _normalizeCondition(String condition) {
    final c = condition.toLowerCase();
    if (c == 'healthy' || c == 'impaired' || c == 'dead' || c == 'unknown' || c == 'onbekend') {
      return c == 'onbekend' ? 'unknown' : c;
    }
    return 'unknown';
  }

  static String _mapCollisionSeverity(String? value) {
    final v = (value ?? '').toLowerCase();
    if (v.contains('ernstig') || v == 'high') return 'high';
    if (v.contains('matig') || v == 'medium') return 'medium';
    if (v.contains('licht') || v == 'low') return 'low';
    return 'unknown';
  }
}
