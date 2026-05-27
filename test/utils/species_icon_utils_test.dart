import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/utils/species_icon_utils.dart';

void main() {
  group('getSpeciesIconPath', () {
    test('resolves boommarter to correct package silhouette path', () {
      final path = getSpeciesIconPath('Boommarter');

      expect(
        path,
        'packages/wildlifenl_assets/assets/icons/animals/boommarter.png',
      );
    });

    test('resolves steenmarter', () {
      final path = getSpeciesIconPath('Steenmarter');

      expect(path, isNotNull);
      expect(path, contains('steenmarter'));
    });
  });
}
