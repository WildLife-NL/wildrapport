import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/utils/map_marker_style.dart';

void main() {
  group('mapMarkerStyleKey', () {
    test('maps visual detection type to camera pin style', () {
      expect(mapMarkerStyleKey('visual'), 'camera');
      expect(mapMarkerUsesCameraIcon('visual'), isTrue);
    });

    test('maps acoustic detection type', () {
      expect(mapMarkerStyleKey('acoustic'), 'acoustic');
      expect(mapMarkerUsesAcousticIcon('acoustic'), isTrue);
    });

    test('still maps interaction report types', () {
      expect(mapMarkerStyleKey('waarneming'), 'waarneming');
      expect(mapMarkerStyleKey('gewasschade'), 'gewasschade');
    });
  });
}
