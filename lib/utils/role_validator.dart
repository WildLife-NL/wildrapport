import 'package:shared_preferences/shared_preferences.dart';

/// Validates whether the current user has access based on backend-provided scopes.
/// Allowed roles:
/// - land-user
/// - nature-area-manager
/// - wildlife-manager
class RoleValidator {
  static const List<String> _allowedRoles = [
    'land-user',
    'nature-area-manager',
    'wildlife-manager',
  ];

  /// Returns true if any allowed role is present in the stored scopes.
  static Future<bool> hasAccess() async {
    final prefs = await SharedPreferences.getInstance();
    final scopes = prefs.getStringList('scopes') ?? const [];
    if (scopes.isEmpty) return false;

    // Normalize scopes to lower-case for robust comparison
    final normalized = scopes.map((s) => s.toLowerCase().trim()).toSet();
    return _allowedRoles.any((role) => normalized.contains(role));
  }

  /// Clears persisted auth artifacts relevant to access (for logout or denial).
  static Future<void> clearAccessArtifacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bearer_token');
    await prefs.remove('scopes');
  }
}
