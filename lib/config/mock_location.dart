/// Centralized mock location configuration.
/// Set `kForceMockLocation` to true only for development/testing with fixed coordinates.
/// When false, the app uses the device's real GPS location.
class MockLocationConfig {
  static const bool kForceMockLocation = false;
  static const double kMockLat = 52.088130;
  static const double kMockLon = 5.170465;
}
