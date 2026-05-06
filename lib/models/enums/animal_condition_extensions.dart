import 'package:wildrapport/models/enums/animal_condition.dart';

extension AnimalConditionExtensions on AnimalCondition {
  String get label {
    switch (this) {
      case AnimalCondition.onbekend:
        return 'Onbekend';
      case AnimalCondition.gezond:
        return 'Gezond';
      case AnimalCondition.gewond:
        return 'Gewond / Ziek';
      case AnimalCondition.dood:
        return 'Dood';
      
    }
  }

  String get apiValue {
    switch (this) {
      case AnimalCondition.onbekend:
        return 'Onbekend';
      case AnimalCondition.gezond:
        return 'healthy';
      case AnimalCondition.gewond:
        return 'impaired';
      case AnimalCondition.dood:
        return 'dead';
    }
  }
}
