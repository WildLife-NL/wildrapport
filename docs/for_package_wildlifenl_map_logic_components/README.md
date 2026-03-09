# Toevoeging voor wildlifenl_map_logic_components

De app wildrapport gebruikt **WildLifeNLMap** uit de package `wildlifenl_map_logic_components`. De widget staat nu alleen in de lokale pub-cache; de package-repo op GitHub moet dezelfde code krijgen.

## Wat toevoegen aan de package-repo

1. **Bestand:** `lib/src/widgets/wildlifenl_map.dart`  
   Kopieer de inhoud uit `lib/src/widgets/wildlifenl_map.dart` in deze map.  
   (De map `lib/src/interfaces/` hier is alleen een stub voor de analyzer; die hoef je niet te kopiëren.)

2. **Export in** `lib/wildlifenl_map_logic_components.dart` toevoegen:
   ```dart
   export 'src/widgets/wildlifenl_map.dart';
   ```

Na deze wijziging in de repo [WildLife-NL/wildlifenl-components](https://github.com/WildLife-NL/wildlifenl-components) (branch `Wildlife-rapport-Components`) werkt `flutter pub get` overal en hoeft er niets meer lokaal te staan.
