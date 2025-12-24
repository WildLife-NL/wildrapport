import 'package:flutter/material.dart';
import 'package:wildrapport/interfaces/data_apis/zone_api_interface.dart';
import 'package:wildrapport/interfaces/data_apis/species_api_interface.dart';
import 'package:wildrapport/models/api_models/species.dart';
import 'package:wildrapport/models/api_models/zone.dart';

class ZoneProvider extends ChangeNotifier {
  final ZoneApiInterface zoneApi;
  final SpeciesApiInterface speciesApi;

  ZoneProvider({required this.zoneApi, required this.speciesApi});

  // Form state
  String name = '';
  String description = '';
  double latitude = 0;
  double longitude = 0;
  double radiusMeters = 100;

  Zone? createdZone;
  bool isSubmitting = false;
  List<Species> allSpecies = [];
  final Set<String> selectedSpeciesIds = {};

  Future<void> loadSpecies() async {
    try {
      allSpecies = await speciesApi.getAllSpecies();
      notifyListeners();
    } catch (e) {
      // ignore errors for now
    }
  }

  void setName(String v) { name = v; notifyListeners(); }
  void setDescription(String v) { description = v; notifyListeners(); }
  void setLatitude(double v) { latitude = v; notifyListeners(); }
  void setLongitude(double v) { longitude = v; notifyListeners(); }
  void setRadius(double v) { radiusMeters = v; notifyListeners(); }

  void toggleSpecies(String id, bool sel) {
    if (sel) {
      selectedSpeciesIds.add(id);
    } else {
      selectedSpeciesIds.remove(id);
    }
    notifyListeners();
  }

  Future<void> createZone() async {
    isSubmitting = true;
    notifyListeners();
    try {
      final req = ZoneCreateRequest(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
        description: description,
        name: name,
      );
      createdZone = await zoneApi.addZone(req);
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> assignSelectedSpecies() async {
    final zoneId = createdZone?.id;
    if (zoneId == null) return;
    isSubmitting = true;
    notifyListeners();
    try {
      for (final sid in selectedSpeciesIds) {
        final req = ZoneSpeciesAssignRequest(speciesID: sid, zoneID: zoneId);
        createdZone = await zoneApi.addSpeciesToZone(req);
      }
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
