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

String? _readNestedString(Map<dynamic, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

int? _parseSeverity(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

class ContactConveyance {
  final String id;
  final DateTime timestamp;
  final String? messageName;
  final String? messageText;
  final int? messageSeverity;
  final String? animalName;
  final String? animalSpecies;

  ContactConveyance({
    required this.id,
    required this.timestamp,
    this.messageName,
    this.messageText,
    this.messageSeverity,
    this.animalName,
    this.animalSpecies,
  });

  bool get hasMessageContent {
    final name = messageName?.trim();
    final text = messageText?.trim();
    return (name != null && name.isNotEmpty) || (text != null && text.isNotEmpty);
  }

  String get displayTitle {
    final name = messageName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final animal = animalName?.trim();
    if (animal != null && animal.isNotEmpty) return animal;
    return 'Bericht';
  }

  String get severityLabel {
    return switch (messageSeverity) {
      1 => 'Hoog',
      2 => 'Midden',
      3 => 'Laag',
      _ => 'Info',
    };
  }

  factory ContactConveyance.fromJson(Map<String, dynamic> json) {
    String? messageName;
    String? messageText;
    int? messageSeverity;
    final message = json['message'];
    if (message is Map) {
      final msg = message is Map<String, dynamic>
          ? message
          : Map<String, dynamic>.from(message);
      messageName = _readNestedString(msg, ['name', 'title']);
      messageText = _readNestedString(msg, ['text', 'body', 'message']);
      messageSeverity = _parseSeverity(msg['severity']);
    }

    String? animalName;
    String? animalSpecies;
    final animal = json['animal'];
    if (animal is Map) {
      final a = animal is Map<String, dynamic>
          ? animal
          : Map<String, dynamic>.from(animal);
      animalName =
          _readNestedString(a, ['commonName', 'name']) ??
          _readNestedString(a, ['species', 'commonName']);
      final species = a['species'];
      if (species is Map) {
        final s = species is Map<String, dynamic>
            ? species
            : Map<String, dynamic>.from(species);
        animalSpecies = _readNestedString(s, ['commonName', 'name', 'species']);
      } else {
        animalSpecies = a['species']?.toString();
      }
    }

    return ContactConveyance(
      id: (json['ID'] ?? json['id'] ?? '').toString(),
      timestamp: _parseContactDate(json['timestamp']?.toString()),
      messageName: messageName,
      messageText: messageText,
      messageSeverity: messageSeverity,
      animalName: animalName,
      animalSpecies: animalSpecies,
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

  bool get hasAnimalInfo {
    final name = collarAnimalName?.trim();
    final species = collarAnimalSpecies?.trim();
    return (name != null && name.isNotEmpty) ||
        (species != null && species.isNotEmpty) ||
        (sensorId != null && sensorId!.isNotEmpty);
  }

  String get displayAnimalTitle {
    final name = collarAnimalName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Collar / dier onbekend';
  }

  String? get displayAnimalSubtitle {
    final species = collarAnimalSpecies?.trim();
    if (species == null || species.isEmpty) return null;
    return species;
  }

  List<ContactConveyance> get conveyancesWithMessages =>
      conveyances.where((c) => c.hasMessageContent).toList();

  String? get primaryResearcherMessage {
    for (final c in conveyancesWithMessages) {
      final text = c.messageText?.trim();
      if (text != null && text.isNotEmpty) return text;
      final name = c.messageName?.trim();
      if (name != null && name.isNotEmpty) return name;
    }
    return null;
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
        if (animalSpecies == null && animal['species'] is Map) {
          final speciesMap = animal['species'] as Map;
          animalSpecies = speciesMap['commonName']?.toString() ??
              speciesMap['name']?.toString();
        }
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
