import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists reported animal counts per interaction ID (survives vicinity refresh).
class InteractionAnimalCountStore {
  InteractionAnimalCountStore._();

  static const _prefsKey = 'interaction_animal_counts_v1';

  static Map<String, int> _memory = {};
  static bool _loaded = false;

  static Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _memory = _decode(prefs.getString(_prefsKey));
    _loaded = true;
  }

  static Future<void> save(String interactionId, int count) async {
    final id = interactionId.trim();
    if (id.isEmpty || count < 1) return;

    await ensureLoaded();
    _memory[id] = count;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_memory));
  }

  /// In-memory count after [ensureLoaded] (e.g. map vicinity merge).
  static int? peek(String interactionId) {
    final id = interactionId.trim();
    if (id.isEmpty) return null;
    return _memory[id];
  }

  static Future<int?> readAsync(String interactionId) async {
    await ensureLoaded();
    return peek(interactionId);
  }

  static Map<String, int> _decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return decoded.map((key, value) {
        final count = switch (value) {
          final int i => i,
          final num n => n.toInt(),
          final String s => int.tryParse(s.trim()) ?? 0,
          _ => 0,
        };
        return MapEntry(key.toString(), count);
      })..removeWhere((_, count) => count < 1);
    } catch (_) {
      return {};
    }
  }
}
