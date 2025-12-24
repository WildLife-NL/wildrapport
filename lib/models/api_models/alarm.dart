class Alarm {
  final String id;
  final DateTime timestamp;
  final AlarmAnimal? animal;
  final List<AlarmConveyance> conveyances;
  final AlarmZone zone;

  Alarm({
    required this.id,
    required this.timestamp,
    required this.animal,
    required this.conveyances,
    required this.zone,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['ID'] ?? json['id'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      animal: json['animal'] != null
          ? AlarmAnimal.fromJson(json['animal'] as Map<String, dynamic>)
          : null,
      conveyances: ((json['conveyances'] as List?) ?? [])
          .map((e) => AlarmConveyance.fromJson(e as Map<String, dynamic>))
          .toList(),
      zone: AlarmZone.fromJson(json['zone'] as Map<String, dynamic>),
    );
  }
}

class AlarmAnimal {
  final String id;
  final String name;
  final String? commonName;
  final String? category;
  final double? latitude;
  final double? longitude;
  final DateTime? locationTimestamp;

  AlarmAnimal({
    required this.id,
    required this.name,
    this.commonName,
    this.category,
    this.latitude,
    this.longitude,
    this.locationTimestamp,
  });

  factory AlarmAnimal.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>?;
    final species = json['species'] as Map<String, dynamic>?;
    return AlarmAnimal(
      id: json['ID'] ?? json['id'],
      name: json['name'] ?? '',
      commonName: species != null ? species['commonName'] : null,
      category: species != null ? species['category'] : null,
      latitude: loc != null ? (loc['latitude'] as num?)?.toDouble() : null,
      longitude: loc != null ? (loc['longitude'] as num?)?.toDouble() : null,
      locationTimestamp:
          DateTime.tryParse(json['locationTimestamp'] ?? ''),
    );
  }
}

class AlarmZone {
  final String id;
  final String name;
  final double? latitude;
  final double? longitude;
  final double? radius;

  AlarmZone({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
    this.radius,
  });

  factory AlarmZone.fromJson(Map<String, dynamic> json) {
    final area = json['area'] as Map<String, dynamic>?;
    final loc = area != null ? area['location'] as Map<String, dynamic>? : null;
    return AlarmZone(
      id: json['ID'] ?? json['id'],
      name: json['name'] ?? '',
      latitude: loc != null ? (loc['latitude'] as num?)?.toDouble() : null,
      longitude: loc != null ? (loc['longitude'] as num?)?.toDouble() : null,
      radius: area != null ? (area['radius'] as num?)?.toDouble() : null,
    );
  }
}

class AlarmConveyance {
  final String id;
  final DateTime timestamp;
  final String? messageText;
  final int? severity;

  AlarmConveyance({
    required this.id,
    required this.timestamp,
    this.messageText,
    this.severity,
  });

  factory AlarmConveyance.fromJson(Map<String, dynamic> json) {
    final message = json['message'] as Map<String, dynamic>?;
    return AlarmConveyance(
      id: json['ID'] ?? json['id'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      messageText: message != null ? message['text'] : null,
      severity: message != null ? (message['severity'] as num?)?.toInt() : null,
    );
  }
}
