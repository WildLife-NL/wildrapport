import 'package:flutter/foundation.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_sighting_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SubmittedSightingsProvider extends ChangeNotifier {
  static const String _prefsKey = 'submitted_sightings';
  final List<AnimalSightingModel> _submittedSightings = [];

  SubmittedSightingsProvider() {
    _loadSightings();
  }

    List<AnimalSightingModel> get submittedSightings =>
      List.unmodifiable(_submittedSightings);


  Future<void> addSighting(AnimalSightingModel sighting) async {
    _submittedSightings.insert(0, sighting); // Add to front (most recent first)
    await _saveSightings();
    notifyListeners();
  }


  Future<void> removeSighting(AnimalSightingModel sighting) async {
    _submittedSightings.remove(sighting);
    await _saveSightings();
    notifyListeners();
  }


  Future<void> clearSightings() async {
    _submittedSightings.clear();
    await _saveSightings();
    notifyListeners();
  }

  Future<void> _saveSightings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _submittedSightings.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_prefsKey, jsonList);
  }

  Future<void> _loadSightings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_prefsKey) ?? [];
    _submittedSightings.clear();
    for (final jsonStr in jsonList) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        _submittedSightings.add(AnimalSightingModel.fromJson(map));
      } catch (_) {}
    }
    notifyListeners();
  }
}
