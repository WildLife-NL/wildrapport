import 'package:wildrapport/models/enums/animal_age.dart';

extension AnimalAgeExtensions on AnimalAge {
  /// UI label (Dutch)
  String get label {
    switch (this) {
      case AnimalAge.pasGeboren:
        return 'Pas geboren';
      case AnimalAge.onvolwassen:
        return 'Onvolwassen';
      case AnimalAge.volwassen:
        return 'Volwassen';
      case AnimalAge.onbekend:
        return 'Onbekend';
    }
  }

  /// Convert various legacy/API/form strings to the canonical enum value.
  static AnimalAge fromApiString(String? raw) {
    if (raw == null) return AnimalAge.onbekend;
    var s = raw.trim().toLowerCase();
    // normalize: remove angle brackets and collapse punctuation/underscores/whitespace
    s = s.replaceAll(RegExp(r'[<>]'), '');
    s = s.replaceAll(RegExp(r'[_\-\s]+'), ' ').trim();

    const Map<String, AnimalAge> _map = {
      // recently born variants
      '6 months': AnimalAge.pasGeboren,
      '6 maanden': AnimalAge.pasGeboren,
      'less than 6 months': AnimalAge.pasGeboren,
      '6': AnimalAge.pasGeboren,
      'pas geboren': AnimalAge.pasGeboren,
      'recently born': AnimalAge.pasGeboren,
      'kalf': AnimalAge.pasGeboren,
      // juvenile / young
      'onvolwassen': AnimalAge.onvolwassen,
      'young': AnimalAge.onvolwassen,
      'juvenile': AnimalAge.onvolwassen,
      // adult
      'volwassen': AnimalAge.volwassen,
      'adult': AnimalAge.volwassen,
      // unknown
      'onbekend': AnimalAge.onbekend,
      'unknown': AnimalAge.onbekend,
    };

    return _map[s] ?? AnimalAge.onbekend;
  }

  /// Canonical API value to send when submitting 
  String toApiString() {
    switch (this) {
      case AnimalAge.pasGeboren:
        return 'recently_born';
      case AnimalAge.onvolwassen:
        return 'juvenile';
      case AnimalAge.volwassen:
        return 'adult';
      case AnimalAge.onbekend:
        return 'unknown';
    }
  }
}