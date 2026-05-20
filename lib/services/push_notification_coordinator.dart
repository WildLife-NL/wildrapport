import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:wildrapport/firebase_options.dart';
import 'package:wildrapport/interfaces/data_apis/profile_api_interface.dart';
import 'package:wildrapport/services/fcm_message_handler.dart';
import 'package:wildrapport/utils/notification_service.dart';

/// Requests push permission only when the user is logged in, then syncs the
/// FCM token to `PUT /profile/me/`.
class PushNotificationCoordinator {
  PushNotificationCoordinator._();
  static final PushNotificationCoordinator instance =
      PushNotificationCoordinator._();

  bool _firebaseReady = false;
  bool _tokenRefreshListenerAttached = false;
  bool _messageListenersAttached = false;
  ProfileApiInterface? _profileApi;
  String? _lastSyncedToken;

  Future<void> _ensureFirebase() async {
    if (_firebaseReady) return;
    if (kIsWeb) return;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _firebaseReady = true;
    } catch (e) {
      debugPrint('[PushCoordinator] Firebase init failed: $e');
    }
  }

  void _attachTokenRefreshListener(ProfileApiInterface profileApi) {
    if (_tokenRefreshListenerAttached || kIsWeb) return;
    _profileApi = profileApi;
    _tokenRefreshListenerAttached = true;
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      debugPrint('[PushCoordinator] FCM token refreshed');
      final api = _profileApi;
      if (api == null) return;
      await _syncToken(api, token, requestPermission: false);
    });
  }

  /// Call when the user is authenticated and wants push (e.g. after login).
  Future<void> syncAfterLogin({
    required ProfileApiInterface profileApi,
    bool requestPermission = true,
    bool forceResync = false,
  }) async {
    if (kIsWeb) return;

    await _ensureFirebase();
    if (!_firebaseReady) return;

    await NotificationService.instance.ensureAndroidChannel();
    _attachTokenRefreshListener(profileApi);
    _attachMessageListeners();

    if (requestPermission) {
      // Android: system dialog (POST_NOTIFICATIONS). iOS: APNs via Firebase.
      // Denied OS permission only blocks visible banners — still register FCM on profile.
      if (!kIsWeb && Platform.isAndroid) {
        final granted =
            await NotificationService.instance.requestAndroidNotificationPermission();
        if (!granted) {
          debugPrint(
            '[PushCoordinator] Android notification permission denied '
            '(FCM token will still be synced to profile)',
          );
        } else {
          // FCM may not be ready immediately after the system dialog.
          await Future<void>.delayed(const Duration(milliseconds: 400));
        }
      }
      if (!kIsWeb && Platform.isIOS) {
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        final allowed = settings.authorizationStatus ==
                AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
        if (!allowed) {
          debugPrint(
            '[PushCoordinator] iOS notification permission denied '
            '(FCM token will still be synced to profile)',
          );
        }
      }
    }

    final token = await _obtainFcmToken();
    if (token == null) {
      debugPrint('[PushCoordinator] No FCM token to send to profile');
      return;
    }

    await _syncTokenWithRetries(
      profileApi,
      token,
      force: forceResync,
    );
  }

  Future<String?> _obtainFcmToken({int maxAttempts = 6}) async {
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      if (attempt > 1) {
        await Future<void>.delayed(Duration(milliseconds: 350 * attempt));
      }
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.isNotEmpty) {
          debugPrint(
            '[PushCoordinator] Device FCM token (attempt $attempt): '
            '${token.substring(0, math.min(12, token.length))}…',
          );
          return token;
        }
        debugPrint(
          '[PushCoordinator] getToken returned empty (attempt $attempt)',
        );
      } catch (e) {
        debugPrint('[PushCoordinator] getToken attempt $attempt failed: $e');
      }
    }
    return null;
  }

  Future<void> _syncTokenWithRetries(
    ProfileApiInterface profileApi,
    String token, {
    required bool force,
    int maxAttempts = 3,
  }) async {
    Object? lastError;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      if (attempt > 1) {
        await Future<void>.delayed(Duration(seconds: attempt));
      }
      try {
        await _syncToken(
          profileApi,
          token,
          requestPermission: false,
          force: force || attempt > 1,
        );
        return;
      } catch (e) {
        lastError = e;
        debugPrint(
          '[PushCoordinator] Profile FCM sync attempt $attempt failed: $e',
        );
      }
    }
    if (lastError != null) {
      debugPrint('[PushCoordinator] All FCM profile sync attempts failed');
      if (lastError is Exception) {
        throw lastError;
      }
      throw Exception('$lastError');
    }
  }

  /// Clears the token on the server when the user disables notifications.
  Future<void> clearTokenOnServer(ProfileApiInterface profileApi) async {
    await _syncToken(profileApi, null, requestPermission: false);
  }

  /// Current FCM token on this device (null if unavailable / not initialized).
  static Future<String?> getDeviceFcmToken() async {
    if (kIsWeb) return null;
    try {
      await instance._ensureFirebase();
      if (!instance._firebaseReady) return null;
      return FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('[PushCoordinator] getDeviceFcmToken failed: $e');
      return null;
    }
  }

  void _attachMessageListeners() {
    if (_messageListenersAttached || kIsWeb) return;
    _messageListenersAttached = true;
    attachFirebaseMessageListeners();
  }

  Future<void> _syncToken(
    ProfileApiInterface profileApi,
    String? token, {
    required bool requestPermission,
    bool force = false,
  }) async {
    if (!force && token == _lastSyncedToken) return;

    final updated =
        await profileApi.updateFirebaseCloudMessagingToken(token);
    _lastSyncedToken = token;
    final onProfile = updated.firebaseCloudMessagingToken;
    debugPrint(
      '[PushCoordinator] Profile FCM '
      '${token == null ? 'cleared' : 'saved on server'} '
      '(response ${onProfile == null ? 'field empty' : 'ok'})',
    );
  }
}
