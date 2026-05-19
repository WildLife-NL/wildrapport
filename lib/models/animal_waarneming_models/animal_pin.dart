class AnimalPin {
  final String id;
  final String? speciesName;
  final double lat;
  final double lon;
  final DateTime seenAt;
  final String? imageUrl;

  AnimalPin({
    required this.id,
    required this.lat,
    required this.lon,
    required this.seenAt,
    this.speciesName,
    this.imageUrl,
  });

  factory AnimalPin.fromJson(Map<String, dynamic> j) {
    final loc = _locationMap(j['location'] ?? j['place']);
    if (loc == null) {
      throw const FormatException('AnimalPin: missing location');
    }

    final lat = _asDouble(loc['latitude'] ?? loc['lat']);
    final lon = _asDouble(loc['longitude'] ?? loc['lon']);
    if (lat == null || lon == null) {
      throw const FormatException('AnimalPin: missing coordinates');
    }

    final id = (j['id'] ?? j['ID'])?.toString();
    if (id == null || id.isEmpty) {
      throw const FormatException('AnimalPin: missing id');
    }

    final ts =
        (j['locationTimestamp'] ?? j['moment'] ?? j['timestamp'] ?? j['seenAt'])
            ?.toString();

    return AnimalPin(
      id: id,
      lat: lat,
      lon: lon,
      seenAt: DateTime.tryParse(ts ?? '')?.toUtc() ?? DateTime.now().toUtc(),
      speciesName:
          (j['species']?['commonName'] ?? j['species']?['name'])?.toString(),
      imageUrl: j['imageUrl'] as String?,
    );
  }

  static Map<String, dynamic>? _locationMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static double? _asDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
