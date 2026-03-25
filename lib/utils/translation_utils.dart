class Translator {
  static final Map<String, String> _phraseMap = {
    // UI phrases
    'filter map icons': 'Kaarticonen filteren',
    'new (< 24 hours)': 'Nieuw (< 24 uur)',
    'recent (24h - 1 week)': 'Recent (24u - 1 week)',
    'old (> 1 week)': 'Oud (> 1 week)',
    'reset map rotation': 'Kaartrotatie resetten',
    'center on me': 'Centreer op mijn locatie',

    // Dialog section titles
    'reported by': 'Gemeld door',
    'when': 'Wanneer',
    'location': 'Locatie',
    'description': 'Beschrijving',

    // Common terms
    'animals': 'Dieren',
    'detections': 'Detecties',
    'interactions': 'Interacties',
    'device type': 'Apparaat Type',
    'confidence': 'Betrouwbaarheid',

    // Interaction type samples (best-effort)
    'damage report': 'Schademelding',
    'animal damage': 'Dierschade',
    'livestock': 'Vee',
    'feeding': 'Voeren',
    'collision': 'Botsing',
    'search': 'Zoeken',
  };

  static String toDutch(String input) {
    final normalized = input.trim().toLowerCase();
    final mapped = _phraseMap[normalized];
    return mapped ?? input;
  }

  static String? toDutchOpt(String? input) {
    if (input == null) return null;
    return toDutch(input);
  }
}
