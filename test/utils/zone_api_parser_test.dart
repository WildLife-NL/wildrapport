import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/utils/zone_api_parser.dart';

void main() {
  test('zoneFromApiJson accepts null description and created', () {
    final zone = zoneFromApiJson({
      'ID': 'zone-1',
      'name': 'Tuin',
      'description': null,
      'created': null,
      'definition': [
        {'latitude': 52.1, 'longitude': 5.3},
        {'latitude': 52.2, 'longitude': 5.4},
        {'latitude': 52.15, 'longitude': 5.35},
      ],
    });

    expect(zone, isNotNull);
    expect(zone!.description, '');
    expect(zone.created, '');
    expect(zone.definition, hasLength(3));
  });

  test('zonesFromApiList skips entries without id', () {
    final zones = zonesFromApiList([
      {'name': 'No id'},
      {'ID': 'z2', 'name': 'Valid'},
    ]);
    expect(zones, hasLength(1));
    expect(zones.first.id, 'z2');
  });

  test('loadZonesWithSpeciesFromApi parses species per zone', () {
    final loaded = loadZonesWithSpeciesFromApi([
      {
        'ID': 'z1',
        'name': 'Tuin',
        'species': [
          {'ID': 's1', 'commonName': 'Vos'},
        ],
      },
    ], null);
    expect(loaded.zones, hasLength(1));
    expect(loaded.speciesByZoneId['z1'], hasLength(1));
    expect(loaded.speciesByZoneId['z1']!.first.commonName, 'Vos');
  });

  test('zonesFromApiListForUser excludes zones owned by others', () {
    final zones = zonesFromApiListForUser([
      {'ID': 'mine', 'name': 'Tuin', 'userID': 'user-a'},
      {'ID': 'theirs', 'name': 'Buren', 'userID': 'user-b'},
      {'ID': 'no-owner', 'name': 'Legacy'},
    ], 'user-a');

    expect(zones.map((z) => z.id), ['mine', 'no-owner']);
  });
}
