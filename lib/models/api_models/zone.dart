class ZoneCreateRequest {
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final String description;
  final String name;

  ZoneCreateRequest({
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.description,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'area': {
        'location': {
          'latitude': latitude,
          'longitude': longitude,
        },
        'radius': radiusMeters,
      },
      'description': description,
      'name': name,
    };
  }
}

class ZoneSpeciesAssignRequest {
  final String speciesID;
  final String zoneID;

  ZoneSpeciesAssignRequest({required this.speciesID, required this.zoneID});

  Map<String, dynamic> toJson() {
    return {
      'speciesID': speciesID,
      'zoneID': zoneID,
    };
  }
}

class Zone {
  final String id;
  final ZoneArea area;
  final DateTime? created;
  final DateTime? deactivated;
  final String description;
  final String name;
  final List<ZoneSpecies> species;
  final ZoneUser user;

  Zone({
    required this.id,
    required this.area,
    required this.created,
    required this.deactivated,
    required this.description,
    required this.name,
    required this.species,
    required this.user,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['ID'] ?? json['id'],
      area: ZoneArea.fromJson(json['area'] as Map<String, dynamic>),
      created: _parseDate(json['created']),
      deactivated: _parseDate(json['deactivated']),
      description: json['description'] ?? '',
      name: json['name'] ?? '',
      species: ((json['species'] as List?) ?? [])
          .map((e) => ZoneSpecies.fromJson(e as Map<String, dynamic>))
          .toList(),
      user: ZoneUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) {
      return DateTime.tryParse(v);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'area': area.toJson(),
      'created': created?.toIso8601String(),
      'deactivated': deactivated?.toIso8601String(),
      'description': description,
      'name': name,
      'species': species.map((e) => e.toJson()).toList(),
      'user': user.toJson(),
    };
  }
}

class ZoneArea {
  final ZoneLocation location;
  final double radius;

  ZoneArea({required this.location, required this.radius});

  factory ZoneArea.fromJson(Map<String, dynamic> json) {
    return ZoneArea(
      location: ZoneLocation.fromJson(json['location'] as Map<String, dynamic>),
      radius: (json['radius'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'radius': radius,
    };
  }
}

class ZoneLocation {
  final double latitude;
  final double longitude;

  ZoneLocation({required this.latitude, required this.longitude});

  factory ZoneLocation.fromJson(Map<String, dynamic> json) {
    return ZoneLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class ZoneSpecies {
  final String id;
  final String? category;
  final String? commonName;

  ZoneSpecies({required this.id, this.category, this.commonName});

  factory ZoneSpecies.fromJson(Map<String, dynamic> json) {
    return ZoneSpecies(
      id: json['ID'] ?? json['id'],
      category: json['category'],
      commonName: json['commonName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      if (category != null) 'category': category,
      if (commonName != null) 'commonName': commonName,
    };
  }
}

class ZoneUser {
  final String id;
  final String name;

  ZoneUser({required this.id, required this.name});

  factory ZoneUser.fromJson(Map<String, dynamic> json) {
    return ZoneUser(
      id: json['ID'] ?? json['id'],
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'name': name,
    };
  }
}
