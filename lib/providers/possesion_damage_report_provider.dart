import 'package:flutter/material.dart';

class PossesionDamageFormProvider extends ChangeNotifier {
  String impactedCrop = '';
  double currentDamage = 0;
  double expectedDamage = 0;
  String impactedAreaType = '';
  String impactedArea = '';
  String description = '';
  String? suspectedSpeciesID;
  final greenLog = '\x1B[32m';
  bool hasErrorImpactedCrop = false;
  bool hasErrorImpactedAreaType = false;
  bool hasErrorImpactedArea = false;

  void setImpactedCrop(String value){
    impactedCrop = value;
    notifyListeners();
  }

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
    suspectedSpeciesID = value;
    notifyListeners();
  }
  void setErrorState(String field, bool hasError) {
    if (field == 'impactedCrop') {
      hasErrorImpactedCrop = hasError;
    } else if (field == 'impactedAreaType') {
      hasErrorImpactedAreaType = hasError;
    } else if (field == 'impactedArea') {
      hasErrorImpactedArea = hasError;
    }
    notifyListeners();
  }
  void clearStateOfValues(){
    debugPrint("$greenLog[PossesionDamageReportProvider]: Clearing Values!");
    impactedCrop = '';
    currentDamage = 0;
    expectedDamage = 0;
    impactedAreaType = '';
    impactedArea = '';
    description = '';
    hasErrorImpactedCrop = false;
    hasErrorImpactedAreaType = false;
    hasErrorImpactedArea = false;
    notifyListeners();
  }
    void resetErrors() {
    hasErrorImpactedCrop = false;
    hasErrorImpactedAreaType = false;
    hasErrorImpactedArea = false;
    notifyListeners();
  }
}
