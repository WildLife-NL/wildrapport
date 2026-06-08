import 'package:wildrapport/utils/api_datetime.dart';
import 'package:wildrapport/utils/preferred_report_location.dart';
import 'package:wildrapport/utils/involved_animal_count.dart';

class AnimalPin {
  final String id;
  final String? speciesName;
  final String? speciesLatinName;
  final int? animalCount;
  final double lat;
  final double lon;
  final DateTime seenAt;
  final String? imageUrl;
  final String? animalSex;
  final String? animalLifeStage;
  final String? animalAge;
  final String? animalCondition;
  final String? collarAnimalName;
  final String? collarAnimalSpecies;
  /// `waarneming`, `gewasschade`, or `verkeersongeval` (interaction pins).
  final String? reportType;
  final String? reportedByName;
  final String? groupSummary;

  AnimalPin({
    required this.id,
    required this.lat,
    required this.lon,
    required this.seenAt,
    this.speciesName,
    this.speciesLatinName,
    this.animalCount,
    this.imageUrl,
    this.animalSex,
    this.animalLifeStage,
    this.animalAge,
    this.animalCondition,
    this.collarAnimalName,
    this.collarAnimalSpecies,
    this.reportType,
    this.reportedByName,
    this.groupSummary,
  });

  factory AnimalPin.fromJson(Map<String, dynamic> j) {
    final loc = PreferredReportLocation.mapForDisplay(j);
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

    print('Common: ${j['species']?['commonName']}');
    print('Latin: ${j['species']?['name']}');
    // DEBUG: log parsed collar/animal metadata for troubleshooting
    try {
      final debugName = _readNestedString(j, const [
        'borneSensorDeployment.animal.commonName',
        'collar.animal.commonName',
        'animal.commonName',
      ]);
      final debugSpecies = _readNestedString(j, const [
        'borneSensorDeployment.animal.species',
        'collar.animal.species',
        'animal.species',
        'species.commonName',
      ]);
      final debugSex = _readNestedString(j, const [
        'borneSensorDeployment.animal.sex',
        'collar.animal.sex',
        'animal.sex',
        'sex',
      ]);
      final debugLife = _readNestedString(j, const [
        'borneSensorDeployment.animal.lifeStage',
        'collar.animal.lifeStage',
        'animal.lifeStage',
        'lifeStage',
      ]);
      final debugAge = _readNestedString(j, const [
        'borneSensorDeployment.animal.age',
        'collar.animal.age',
        'animal.age',
        'age',
      ]);
      final debugCond = _readNestedString(j, const [
        'borneSensorDeployment.animal.condition',
        'collar.animal.condition',
        'animal.condition',
        'condition',
      ]);

      print('[DEBUG AnimalPin] collarName=$debugName species=$debugSpecies sex=$debugSex life=$debugLife age=$debugAge cond=$debugCond');
    } catch (e) {
      print('[DEBUG AnimalPin] failed to extract debug fields: $e');
    }
    return AnimalPin(
      id: id,
      lat: lat,
      lon: lon,
      seenAt: parseApiMomentToUtc(ts),
      speciesName: _readNestedString(j, const [
        'species.commonName',
        'species.name',
      ]),
      speciesLatinName: _readNestedString(j, const [
        'species.name',
      ]),
      animalCount: _extractAnimalCount(j),
      imageUrl: j['imageUrl']?.toString(),
      animalSex: _readNestedString(j, const [
        'borneSensorDeployment.animal.sex',
        'collar.animal.sex',
        'animal.sex',
        'sex',
        'gender',
      ]),
      animalLifeStage: _readNestedString(j, const [
        'borneSensorDeployment.animal.lifeStage',
        'collar.animal.lifeStage',
        'animal.lifeStage',
        'lifeStage',
      ]),
      animalAge: _readNestedString(j, const [
        'borneSensorDeployment.animal.age',
        'collar.animal.age',
        'animal.age',
        'age',
      ]),
      animalCondition: _readNestedString(j, const [
        'borneSensorDeployment.animal.condition',
        'collar.animal.condition',
        'animal.condition',
        'condition',
      ]),
      collarAnimalName: _readNestedString(j, const [
        'borneSensorDeployment.animal.commonName',
        'borneSensorDeployment.animal.name',
        'collar.animal.commonName',
        'collar.animal.name',
        'animal.commonName',
        'animal.name',
      ]),
      collarAnimalSpecies: _readNestedString(j, const [
        'borneSensorDeployment.animal.species.commonName',
        'borneSensorDeployment.animal.species.name',
        'borneSensorDeployment.animal.species',
        'collar.animal.species.commonName',
        'collar.animal.species.name',
        'collar.animal.species',
        'animal.species.commonName',
        'animal.species.name',
        'animal.species',
      ]),
      reportedByName: _readNestedString(j, const [
        'user.name',
        'user.username',
      ]),
      // Vicinity `animals` are GPS collar positions (Smart Parks).
      reportType: 'collar',
    );
  }

  static int? _extractAnimalCount(Map<String, dynamic> j) {
    return extractAnimalCountFromInteractionJson(j);
  }

  static double? _asDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static String? _readNestedString(
    Map<String, dynamic> map,
    List<String> paths,
  ) {
    for (final path in paths) {
      final value = _readPath(map, path.split('.'));
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  static Object? _readPath(Object? value, List<String> segments) {
    if (value == null) return null;
    if (segments.isEmpty) return value;
    if (value is! Map) return null;

    final map = value is Map<String, dynamic>
        ? value
        : Map<String, dynamic>.from(value);
    final next = map[segments.first];
    if (segments.length == 1) return next;
    return _readPath(next, segments.sublist(1));
  }
}
