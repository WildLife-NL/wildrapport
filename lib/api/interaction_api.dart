import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:wildrapport/api/api_client.dart';
import 'package:wildrapport/interfaces/api/interaction_api_interface.dart';
import 'package:wildrapport/interfaces/reporting/common_report_fields.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/models/beta_models/interaction_model.dart';

import '../models/enums/interaction_type.dart';

class InteractionApi implements InteractionApiInterface{
  final ApiClient client;
  final greenLog = '\x1B[32m';
  final redLog = '\x1B[31m';
  final yellowLog = '\x1B[93m';
  InteractionApi(this.client);
  @override
  Future<Questionnaire> sendInteraction(Interaction interaction) async {
    try {
      debugPrint("$yellowLog[InteractionAPI]: Line 21, start of try catch");
      http.Response response;

      if(interaction.report is CommonReportFields){
        debugPrint("$yellowLog[InteractionAPI]: Line 25, report is CommonReportField");
        final report = interaction.report as CommonReportFields;
        switch (interaction.interactionType) { 
          case InteractionType.waarnemning:
            debugPrint("$yellowLog[InteractionAPI]: Line 29, report is waarneming");
            response = await client.post(
            'interaction/',
{
              "description": report.description,
              "location": 
                {
                  "latitude": report.systemLocation!.latitude,
                  "longitude": report.systemLocation!.longtitude,
                },
              "moment": report.userSelectedDateTime!.toIso8601String(),
              "place":
              {
                "latitude": report.userSelectedLocation!.latitude,
                "longitude": report.userSelectedLocation!.longtitude,
              }, 
              "reportOfSighting": interaction.report.toJson(),
              "suspectedSpeciesID": report.suspectedSpeciesID,
              "typeID": 1,
            },
            authenticated: true,
          );
          case InteractionType.gewasschade:
            debugPrint("$yellowLog[InteractionAPI]: Line 55, report is gewasschade");
            debugPrint(interaction.report.toJson().toString());
            response = await client.post(
            'interaction/',
            {
              "description": report.description,
              "location": 
                {
                  "latitude": report.systemLocation!.latitude,
                  "longitude": report.systemLocation!.longtitude,
                },
              "moment": report.userSelectedDateTime!.toUtc().toIso8601String(),
              "place":
              {
                "latitude": report.userSelectedLocation!.latitude,
                "longitude": report.userSelectedLocation!.longtitude,
              }, 
              "reportOfDamage": interaction.report.toJson(),
              "speciesID": report.suspectedSpeciesID,
              "typeID": 2,
            },
            authenticated: true,
          );
          case InteractionType.verkeersongeval:
            debugPrint("$yellowLog[InteractionAPI]: Line 81, report is verkeersongeval");
            response = await client.post(
            'interaction/',
            {
              "description": report.description,
              "location": 
                {
                  "latitude": report.systemLocation!.latitude,
                  "longitude": report.systemLocation!.longtitude,
                },
              "moment": report.userSelectedDateTime!.toUtc().toIso8601String(),
              "place":
              {
                "latitude": report.userSelectedLocation!.latitude,
                "longitude": report.userSelectedLocation!.longtitude,
              }, 
              "reportOfCollision": interaction.report.toJson(),
              "speciesID": report.suspectedSpeciesID,
              "typeID": 3,
            },
            authenticated: true,
          ); 
        }
        debugPrint("$greenLog[InteractionAPI] Response code: ${response.statusCode.toString()}");
        debugPrint("$greenLog[InteractionAPI] Response body: ${response.body.toString()}");
        Map<String, dynamic>? json;
        if(response.statusCode == HttpStatus.ok) {
          final json = jsonDecode(response.body);
          final questionnaireJson = json['questionnaire'];
          try{
            final Questionnaire questionnaire = Questionnaire.fromJson(questionnaireJson);
            return questionnaire;
          }catch(e){debugPrint("$redLog$e"); throw Exception("Questionnaire returned was invalid!");}
        }
        else{
          throw Exception(json ?? "Failed to get questionnaire");
        }   
      }
      else{
        throw Exception("Unhandled Exception");
      } 
    } catch(e) {
        debugPrint("$redLog$e");
        throw Exception("Unhandled Exception");
    }
  } 
}