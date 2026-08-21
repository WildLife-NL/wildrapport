import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wildrapport/utils/access_scope_utils.dart';
import 'package:wildrapport/utils/reviewer_auth.dart';
import 'package:wildlifenl_login_components/wildlifenl_login_components.dart';

/// Login-wrapper met tijdelijke Play Store reviewer-bypass.
///
/// NA DE REVIEW: verwijder deze class samen met [ReviewerAuth].
class ReviewerAwareLoginService implements LoginInterface {
  ReviewerAwareLoginService(
    this._inner, {
    ReviewerAuth? reviewerAuth,
    Future<SharedPreferences> Function()? prefsLoader,
  })  : _reviewerAuth = reviewerAuth ?? ReviewerAuth(),
        _prefsLoader = prefsLoader ?? SharedPreferences.getInstance;

  final LoginInterface _inner;
  final ReviewerAuth _reviewerAuth;
  final Future<SharedPreferences> Function() _prefsLoader;

  static const String tokenKey = 'bearer_token';
  static const String scopesKey = 'scopes';

  @override
  String? validateEmail(String? email) => _inner.validateEmail(email);

  @override
  Future<bool> sendLoginCode(String email) async {
    _reviewerAuth.logStatusFor(email);
    if (_reviewerAuth.isReviewerEmail(email)) {
      // Skip server authenticate / geen mail versturen.
      return true;
    }
    return _inner.sendLoginCode(email);
  }

  @override
  Future<dynamic> verifyCode(String email, String code) async {
    if (_reviewerAuth.isReviewerEmail(email)) {
      if (!_reviewerAuth.isValidPin(code)) {
        throw Exception('Ongeldige verificatiecode');
      }
      await _persistReviewerSession();
      return {
        'token': _reviewerAuth.token,
        'reviewerBypass': true,
      };
    }
    return _inner.verifyCode(email, code);
  }

  @override
  Future<bool> resendCode(String email) async {
    _reviewerAuth.logStatusFor(email);
    if (_reviewerAuth.isReviewerEmail(email)) {
      return true;
    }
    return _inner.resendCode(email);
  }

  Future<void> _persistReviewerSession() async {
    final prefs = await _prefsLoader();
    await prefs.setString(tokenKey, _reviewerAuth.token);
    // Lokale scopes zodat authenticator.hasAccess() true is; Authorize
    // op de server valideert daarna met de echte REVIEWER_TOKEN.
    await prefs.setStringList(
      scopesKey,
      AccessScopeUtils.requiredScopes.toList(growable: false),
    );
  }

  @override
  void setVerificationVisible(bool visible) =>
      _inner.setVerificationVisible(visible);

  @override
  void setError(bool isError, [String message = '']) =>
      _inner.setError(isError, message);

  @override
  void addListener(VoidCallback listener) => _inner.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _inner.removeListener(listener);
}
