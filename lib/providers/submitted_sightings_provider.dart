import 'package:flutter/foundation.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_sighting_model.dart';
import 'package:wildrapport/utils/sighting_display_utils.dart';
import 'package:wildrapport/utils/interaction_type_display.dart';
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
    _submittedSightings.insert(
      0,
      normalizeStoredSighting(sighting),
    );
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
    var migrated = false;
    for (final jsonStr in jsonList) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        final raw = AnimalSightingModel.fromJson(map);
        final normalized = normalizeStoredSighting(raw);
        if (normalized.reportType != raw.reportType ||
            effectiveReportTypeKey(raw) != normalizeReportTypeKey(raw.reportType) ||
            normalized.animalSelected?.animalImagePath !=
                raw.animalSelected?.animalImagePath) {
          migrated = true;
        }
        _submittedSightings.add(normalized);
      } catch (_) {}
    }
    if (migrated) {
      await _saveSightings();
    }
    notifyListeners();
  }
}
