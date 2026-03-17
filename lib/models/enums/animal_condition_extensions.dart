import 'package:wildrapport/models/enums/animal_condition.dart';

extension AnimalConditionExtensions on AnimalCondition {
  String get label {
    switch (this) {
      case AnimalCondition.gezond:
        return 'Gezond';
      case AnimalCondition.ziek:
        return 'Gewond / Ziek';
      case AnimalCondition.dood:
        return 'Dood';
      case AnimalCondition.andere:
        return 'Anders';
      case AnimalCondition.levend:
        return 'Levend';
    }
  }

  String get apiValue {
    switch (this) {
      case AnimalCondition.gezond:
        return 'healthy';
      case AnimalCondition.levend:
        return 'healthy';
      case AnimalCondition.ziek:
        return 'impaired';
      case AnimalCondition.dood:
        return 'dead';
      case AnimalCondition.andere:
        return 'other';
    }
  }
}
