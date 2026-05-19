import 'package:wildrapport/models/api_models/vicinity.dart';

abstract class VicinityApiInterface {
  Future<Vicinity> getMyVicinity();

  Future<Vicinity> getVicinityForCurrentLocation({
    required double latitude,
    required double longitude,
    DateTime? timestamp,
  });

  Future<Vicinity> submitTrackingReading({
    required double latitude,
    required double longitude,
    DateTime? timestamp,
  });
}
