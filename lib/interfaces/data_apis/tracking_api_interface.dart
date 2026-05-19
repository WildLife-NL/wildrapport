import 'package:wildrapport/models/api_models/vicinity.dart';

class TrackingNotice {
  final String text;
  final int? severity;
  final Vicinity? vicinity;

  TrackingNotice(this.text, {this.severity, this.vicinity});

  bool get hasMessage => text.trim().isNotEmpty;
}

class TrackingReadingResponse {
  final String userId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;

  /// Animals, detections and interactions in the vicinity of this reading (OpenAPI).
  final Vicinity? vicinity;

  TrackingReadingResponse({
    required this.userId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.vicinity,
  });

  factory TrackingReadingResponse.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;

    final timestampStr = json['timestamp'] as String;
    final parsedTime = DateTime.parse(timestampStr);

    Vicinity? vicinity;
    if (json['vicinity'] is Map<String, dynamic>) {
      vicinity = Vicinity.fromJson(json['vicinity'] as Map<String, dynamic>);
    } else if (json['animals'] != null ||
        json['detections'] != null ||
        json['interactions'] != null) {
      vicinity = Vicinity.fromJson(json);
    }

    return TrackingReadingResponse(
      userId: json['userID'] as String,
      timestamp: parsedTime,
      latitude: (location['latitude'] as num).toDouble(),
      longitude: (location['longitude'] as num).toDouble(),
      vicinity: vicinity,
    );
  }
}

abstract class TrackingApiInterface {
  Future<TrackingNotice?> addTrackingReading({
    required double lat,
    required double lon,
    required DateTime timestampUtc,
  });

  Future<List<TrackingReadingResponse>> getMyTrackingReadings();

  /// Vicinity for the map: latest tracking reading only (OpenAPI: per-reading vicinity).
  Future<Vicinity> getMergedVicinityFromMyTrackingReadings();
}
