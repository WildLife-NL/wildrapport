import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/utils/netherlands_map_defaults.dart';

void main() {
  test('detects legacy dev mock coordinates', () {
    expect(
      NetherlandsMapDefaults.isLegacyDevMockCoordinate(
        NetherlandsMapDefaults.legacyMockLat,
        NetherlandsMapDefaults.legacyMockLon,
      ),
      isTrue,
    );
    expect(
      NetherlandsMapDefaults.isLegacyDevMockCoordinate(
        NetherlandsMapDefaults.center.latitude,
        NetherlandsMapDefaults.center.longitude,
      ),
      isFalse,
    );
  });
}
