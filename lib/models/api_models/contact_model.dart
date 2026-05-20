DateTime? _parseOptionalEnd(dynamic value) {
  if (value == null) return null;
  final raw = value.toString().trim();
  if (raw.isEmpty) return null;
  return _parseContactDate(raw);
}

DateTime _parseContactDate(String? value) {
  final raw = (value ?? '').trim();
  if (raw.isEmpty) return DateTime.now();
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return DateTime.now();
  final hasTz = RegExp(r'(Z|[+\-]\d{2}:\d{2})$').hasMatch(raw);
  if (!hasTz) return parsed;
  return parsed.isUtc ? parsed.toLocal() : parsed;
}

class ContactConveyance {
  final String id;
  final DateTime timestamp;
  final String? messageName;
  final String? animalName;

  ContactConveyance({
    required this.id,
    required this.timestamp,
    this.messageName,
    this.animalName,
  });

  factory ContactConveyance.fromJson(Map<String, dynamic> json) {
    final message = json['message'];
    String? messageName;
    if (message is Map) {
      messageName = message['name']?.toString();
    }
    final animal = json['animal'];
    String? animalName;
    if (animal is Map) {
      animalName =
          animal['commonName']?.toString() ?? animal['name']?.toString();
    }
    return ContactConveyance(
      id: (json['ID'] ?? json['id'] ?? '').toString(),
      timestamp: _parseContactDate(json['timestamp']?.toString()),
      messageName: messageName,
      animalName: animalName,
    );
  }
}

class Contact {
  final String id;
  final String? contactHardwareAddress;
  final DateTime start;
  final DateTime? end;
  final String? collarAnimalName;
  final String? collarAnimalSpecies;
  final String? collarAnimalId;
  final String? sensorId;
  final List<ContactConveyance> conveyances;

  Contact({
    required this.id,
    this.contactHardwareAddress,
    required this.start,
    this.end,
    this.collarAnimalName,
    this.collarAnimalSpecies,
    this.collarAnimalId,
    this.sensorId,
    this.conveyances = const [],
  });

  bool get isActive {
    if (id.isEmpty) return false;
    return end == null;
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    final deployment = json['borneSensorDeployment'];
    String? animalName;
    String? animalSpecies;
    String? animalId;
    String? sensorId;
    if (deployment is Map<String, dynamic>) {
      sensorId = deployment['sensorID']?.toString();
      final animal = deployment['animal'];
      if (animal is Map<String, dynamic>) {
        animalName =
            animal['commonName']?.toString() ?? animal['name']?.toString();
        animalSpecies = animal['species']?.toString();
        animalId = (animal['ID'] ?? animal['id'])?.toString();
      }
    }

    final conveyancesRaw = json['conveyances'];
    final conveyances = <ContactConveyance>[];
    if (conveyancesRaw is List) {
      for (final item in conveyancesRaw) {
        if (item is Map<String, dynamic>) {
          conveyances.add(ContactConveyance.fromJson(item));
        } else if (item is Map) {
          conveyances.add(
            ContactConveyance.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return Contact(
      id: (json['ID'] ?? json['id'] ?? '').toString(),
      contactHardwareAddress: json['contactHardwareAddress']?.toString(),
      start: _parseContactDate(json['start']?.toString()),
      end: _parseOptionalEnd(json['end']),
      collarAnimalName: animalName,
      collarAnimalSpecies: animalSpecies,
      collarAnimalId: animalId,
      sensorId: sensorId,
      conveyances: conveyances,
    );
  }
}
