# Troubleshooting – packages (GitHub)

De packages **wildlifenl_map_ui_components** en **wildlifenl_map_logic_components** komen van GitHub: [WildLife-NL/wildlifenl-components](https://github.com/WildLife-NL/wildlifenl-components), branch `Wildlife-rapport-Components`.

## 1. Dependencies ophalen

In de **projectroot**:

```bash
flutter pub get
```

Daarmee worden de packages van GitHub gehaald.

## 2. Analysis server herstarten

**Ctrl+Shift+P** → **"Dart: Restart Analysis Server"**. Of project sluiten en opnieuw openen.

## 3. Bij problemen

- **"Package not found" / resolvers fout**  
  Controleer internetverbinding en of de repo en branch bestaan. Daarna opnieuw `flutter pub get`.

- **Tests**  
  Na `flutter pub get`: `flutter test`.
