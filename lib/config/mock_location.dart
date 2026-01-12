/// Centralized mock location configuration.
/// Enable `kForceMockLocation` to return the fixed coordinates everywhere
/// the app requests a device location for map usage.
class MockLocationConfig {
  static const bool kForceMockLocation = true;
  static const double kMockLat = 52.088130;
  static const double kMockLon = 5.170465;
}
