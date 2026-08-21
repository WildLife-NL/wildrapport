import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Tijdelijke Google Play reviewer-login bypass.
///
/// Config via `.env` / flutter_dotenv:
/// - REVIEWER_EMAIL
/// - REVIEWER_TOKEN (lange sessie-token na echte login, NIET de 6-cijferige mailcode)
/// - REVIEWER_PIN
///
/// Bypass alleen actief als alle drie gezet zijn én REVIEWER_TOKEN ≥ 16 tekens.
///
/// NA DE REVIEW: account op de server uitzetten, secrets legen, daarna deze
/// bypass-code (ReviewerAuth + ReviewerAwareLoginService + UI-hints + tests)
/// verwijderen.
class ReviewerAuth {
  ReviewerAuth({Map<String, String>? env})
      : _env = env ?? Map<String, String>.from(dotenv.env);

  final Map<String, String> _env;

  static const int minTokenLength = 16;

  String get email => (_env['REVIEWER_EMAIL'] ?? '').trim();

  String get token => (_env['REVIEWER_TOKEN'] ?? '').trim();

  String get pin => (_env['REVIEWER_PIN'] ?? '').trim();

  bool get hasValidToken => token.length >= minTokenLength;

  /// Alle drie keys aanwezig én token lang genoeg.
  bool get isConfigured =>
      email.isNotEmpty && pin.isNotEmpty && hasValidToken;

  bool isReviewerEmail(String candidate) {
    if (!isConfigured) return false;
    return candidate.trim().toLowerCase() == email.toLowerCase();
  }

  bool isValidPin(String code) {
    if (!isConfigured) return false;
    return code.trim() == pin;
  }

  /// Debug-status zonder de token te printen.
  void logStatusFor(String candidateEmail) {
    if (!kDebugMode) return;

    final reasons = <String>[];
    if (email.isEmpty) reasons.add('REVIEWER_EMAIL empty');
    if (pin.isEmpty) reasons.add('REVIEWER_PIN empty');
    if (!hasValidToken) {
      reasons.add(
        'REVIEWER_TOKEN missing or too short '
        '(len=${token.length}, need>=$minTokenLength)',
      );
    }

    final configured = isConfigured;
    final match = isReviewerEmail(candidateEmail);
    debugPrint(
      '[ReviewerAuth] bypass=${configured ? "ON" : "OFF"} '
      'emailMatch=$match'
      '${configured ? "" : " reasons=${reasons.join(", ")}"}',
    );
  }
}
