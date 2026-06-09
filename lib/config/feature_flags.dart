/// Feature toggles for this app build.
abstract final class FeatureFlags {
  /// Zones tab and zone hub screens.
  static const bool zonesNavEnabled = true;

  /// Adding species / alarm animals to a zone (disabled in current release).
  static const bool addSpeciesToZoneEnabled = false;
}
