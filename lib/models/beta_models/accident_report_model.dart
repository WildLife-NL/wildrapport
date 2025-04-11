import 'package:wildrapport/models/beta_models/report_location_model.dart';

class AccidentReport {
  final String? accidentReportID;
  final String damages;
  final ReportLocation? userSelectedLocation;
  final ReportLocation? systemLocation;
  final DateTime? userSelectedDateTime;
  final DateTime systemDateTime;

  AccidentReport({
    this.accidentReportID,
    required this.damages,
    this.userSelectedLocation,
    this.systemLocation,
    this.userSelectedDateTime,
    required this.systemDateTime,
  });
}