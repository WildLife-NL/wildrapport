/// Chooses map coordinates from API payloads that expose both [place] (user-chosen)
/// and [location] (device GPS at submit time). Display should prefer [place].
class PreferredReportLocation {
  PreferredReportLocation._();

  static Map<String, dynamic>? mapForDisplay(Map<String, dynamic> json) {
    final place = _asLocationMap(json['place']);
    if (_hasCoordinates(place)) return place;
    return _asLocationMap(json['location']);
  }

  static Map<String, dynamic>? _asLocationMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static bool _hasCoordinates(Map<String, dynamic>? map) {
    if (map == null) return false;
    final lat = _asDouble(map['latitude'] ?? map['lat']);
    final lon = _asDouble(map['longitude'] ?? map['lon']);
    if (lat == null || lon == null) return false;
    // Treat null island as missing (same heuristic as logbook map pins).
    if (lat == 0.0 && lon == 0.0) return false;
    return true;
  }

  static double? _asDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
