import 'package:wildrapport/models/reports/base_report.dart';

class animalSightingReport extends BaseReport {
  animalSightingReport() : super('animalSightingen');

  // Add specific getters/setters for animalSighting properties
  String? get selectedAnimal => getProperty('selectedAnimal');
  set selectedAnimal(String? value) => updateProperty('selectedAnimal', value);

  DateTime? get observationDate => getProperty('observationDate');
  set observationDate(DateTime? value) => updateProperty('observationDate', value);
}