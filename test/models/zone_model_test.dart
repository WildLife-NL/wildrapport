import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/models/api_models/zone.dart';

void main() {
  test('Zone.fromJson parses minimal schema', () {
    final json = {
      'ID': '3892eb50-4697-4c72-aadc-32b766bce3c0',
      'area': {
        'location': {'latitude': -90, 'longitude': -180},
        'radius': 1
      },
      'created': '2019-08-24T14:15:22Z',
      'deactivated': '2019-08-24T14:15:22Z',
      'description': 'string',
      'name': 'string',
      'species': [
        {
          'ID': '3892eb50-4697-4c72-aadc-32b766bce3c0',
          'category': 'mammal',
          'commonName': 'Fox'
        }
      ],
      'user': {
        'ID': '3892eb50-4697-4c72-aadc-32b766bce3c0',
        'name': 'string'
      }
    };

    final zone = Zone.fromJson(json);
    expect(zone.id, '3892eb50-4697-4c72-aadc-32b766bce3c0');
    expect(zone.area.radius, 1);
    expect(zone.area.location.latitude, -90);
    expect(zone.area.location.longitude, -180);
    expect(zone.name, 'string');
    expect(zone.description, 'string');
    expect(zone.species.length, 1);
    expect(zone.user.name, 'string');
    expect(zone.created, isNotNull);
  });
}
