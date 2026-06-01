import 'package:wildrapport/models/api_models/detection_pin.dart';
import 'package:wildrapport/models/api_models/interaction_query_result.dart';

enum AlarmFocusKind { detection, interaction }

/// Map focus for the interaction or detection that triggered an alarm.
class MapAlarmFocus {
  const MapAlarmFocus.detection(this.detection)
      : kind = AlarmFocusKind.detection,
        interaction = null;

  const MapAlarmFocus.interaction(this.interaction)
      : kind = AlarmFocusKind.interaction,
        detection = null;

  final AlarmFocusKind kind;
  final DetectionPin? detection;
  final InteractionQueryResult? interaction;

  double get lat =>
      kind == AlarmFocusKind.detection ? detection!.lat : interaction!.lat;

  double get lon =>
      kind == AlarmFocusKind.detection ? detection!.lon : interaction!.lon;

  String get eventId =>
      kind == AlarmFocusKind.detection ? detection!.id : interaction!.id;
}
