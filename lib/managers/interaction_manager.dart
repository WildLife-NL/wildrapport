import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:wildrapport/interfaces/api/interaction_api_interface.dart';
import 'package:wildrapport/interfaces/interaction_interface.dart';
import 'package:wildrapport/interfaces/reporting/reportable_interface.dart';
import 'package:wildrapport/models/beta_models/interaction_model.dart';
import 'package:wildrapport/models/beta_models/interaction_response_model.dart';
import 'package:wildrapport/models/enums/interaction_type.dart';

class InteractionManager implements InteractionInterface{
  final InteractionApiInterface interactionAPI;
  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  InteractionManager({required this.interactionAPI});

  final greenLog = '\x1B[32m';
  final redLog = '\x1B[31m';
  final yellowLog = '\x1B[93m';

  void init() {
    _connectivitySubscription =
      _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
  }

  void dispose() {
    _connectivitySubscription.cancel();
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) async {
  debugPrint(results.toString());

  final hasConnection = results.any((r) => r != ConnectivityResult.none);
  
  if (hasConnection) {
    await _trySendCachedData();
  } else {
    debugPrint('No internet connection – future data will be cached.');
  }
}

  Future<void> _trySendCachedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(await _doesInteractionCacheExist()){
      final List<Interaction> interactions = await _getAlreadyStoredInteractions();
      int interactionIndex = 0;
      for (Interaction interaction in interactions) {
        try {
          interactionAPI.sendInteraction(interaction);
          debugPrint("$greenLog Interaction $interactionIndex Send!");
          interactionIndex++;
        }
        catch(e, stackTrace){
          debugPrint("");
          debugPrint("$redLog Something went wrong at $interactionIndex");
          debugPrint("");
          debugPrint("$yellowLog ${prefs.getStringList('interaction_cache')}");
          debugPrint("");
          debugPrint("$redLog ${e.toString()}");
          debugPrint(stackTrace.toString());
          debugPrint("");
        }
      }
    }
  }

  @override
  Future<InteractionResponseModel?> postInteraction(Reportable report) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userID = prefs.getString("userID");

    if(userID == null){ throw Exception("User Profile Wasn't Loaded!"); }

    final results = await _connectivity.checkConnectivity();
    final hasConnection = results.any((r) => r != ConnectivityResult.none);

    final interaction = Interaction(
      interactionType: InteractionType.gewasschade,
      userID: userID, //Temp because we don't safe user date yet
      report: report,
    );

    if(hasConnection){
      return interactionAPI.sendInteraction(interaction);
    }
    else{
      _cacheInteraction(interaction);
      return null;
    }
  }

  Future<bool> _doesInteractionCacheExist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getStringList("interaction_cache") != null){ return true; }
    else { return false; }
  }

  Future<List<Interaction>> _getAlreadyStoredInteractions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();  
    List<String>? jsonStringList = prefs.getStringList('interaction_cache');

    if (jsonStringList != null) {
      List<Interaction> responses = jsonStringList
          .map((jsonString) => Interaction.fromJson(jsonDecode(jsonString)))
          .toList();
      return responses;
    }
    throw Exception("Something went wrong!");
  }
  Future<void> _cacheInteraction(Interaction interaction) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<Interaction> interactions = await _doesInteractionCacheExist()
        ? await _getAlreadyStoredInteractions()
        : [];

    interactions.add(interaction);

    List<String> interactionJson =
        interactions.map((obj) => jsonEncode(obj.toJson())).toList();

    await prefs.setStringList('interaction_cache', interactionJson);
  }
}