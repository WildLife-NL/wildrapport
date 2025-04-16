import 'package:flutter/material.dart';

class PossesionDamageModel with ChangeNotifier {
  String? impactedCrop;
  String? impactedAreaType;
  double? impactedArea;
  String? currentImpactDamages;
  String? estimatedTotalDamages;
  String? description;
  String? suspectedAnimalID;

  void updateGewasschadeData({
    String? crop,
    String? type,
    double? area,
    String? current,
    String? estimated,
    String? desc, required String impactedCrop, required String impactedAreaType, required double impactedArea, required String currentImpactDamages, required String estimatedTotalDamages, required String description,
  }) {
    impactedCrop = crop!;
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
