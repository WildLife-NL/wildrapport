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

    test('resolves bever to package bever silhouette', () {
      expect(
        getSpeciesIconPath('Bever'),
        'packages/wildlifenl_assets/assets/icons/animals/bever.png',
      );
    });

    test('resolves shetlandpony to package silhouette file', () {
      expect(
        getSpeciesIconPath('Shetlandpony'),
        'packages/wildlifenl_assets/assets/icons/animals/shetlandpony.png',
      );
      expect(
        getSpeciesIconPath('Shetland pony'),
        'packages/wildlifenl_assets/assets/icons/animals/shetlandpony.png',
      );
    });

    test('resolves wilde kat to package wild_kat silhouette', () {
      expect(
        getSpeciesIconPath('Wilde kat'),
        'packages/wildlifenl_assets/assets/icons/animals/wild_kat.png',
      );
    });
  });
}
