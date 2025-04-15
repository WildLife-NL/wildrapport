import 'package:flutter/material.dart';

class PossesionDamageModel with ChangeNotifier {
  String? impactedAreaType;
  double? impactedArea;
  String? currentImpactDamages;
  String? estimatedTotalDamages;
  String? description;
  String? suspectedAnimalID;

  void updateGewasschadeData({
    String? type,
    double? area,
    String? current,
    String? estimated,
    String? desc, required String impactedAreaType, required double impactedArea, required String currentImpactDamages, required String estimatedTotalDamages, required String description,
  }) {
    impactedAreaType = type!;
    impactedArea = area!;
    currentImpactDamages = current!;
    estimatedTotalDamages = estimated!;
    description = desc!;
    notifyListeners();
  }

  void setSuspectedAnimal(String? id) {
    suspectedAnimalID = id;
    notifyListeners();
  }
}
