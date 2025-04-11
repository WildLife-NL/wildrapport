import 'package:wildrapport/models/beta_models/report_location.dart';
import 'package:wildrapport/models/beta_models/sighted_animal.dart';

class SightingReport {
  final List<SightedAnimal> animals;
  final String? sightingReportID;
  final String? description;
  final ReportLocation? userSelectedLocation;
  final ReportLocation? systemLocation;
  final DateTime? userSelectedDateTime;
  final DateTime systemDateTime;

  SightingReport({
    required this.animals,
    this.sightingReportID,
    this.description,
    this.userSelectedLocation,
    this.systemLocation,
    this.userSelectedDateTime,
    required this.systemDateTime,
  });
}