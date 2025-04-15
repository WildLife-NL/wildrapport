import 'package:flutter/material.dart';

class PossesionDamageFormProvider extends ChangeNotifier {
  double currentDamage = 0;
  double expectedDamage = 0;
  String impactedAreaType = '';
  String impactedArea = '';
  String description = '';
  String? suspectedAnimalID;

  void setCurrentDamage(double value) {
    currentDamage = value;
    notifyListeners();
  }

  void setExpectedDamage(double value) {
    expectedDamage = value;
    notifyListeners();
  }

  void setImpactedAreaType(String value) {
    impactedAreaType = value;
    notifyListeners();
  }

  void setImpactedArea(String value) {
    impactedArea = value;
    notifyListeners();
  }

  void setDescription(String value) {
    description = value;
    notifyListeners();
  }

  void setSuspectedAnimal(String value) {
    suspectedAnimalID = value;
    notifyListeners();
  }
}
