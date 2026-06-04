import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wildrapport/models/enums/nav_tab.dart';
import 'package:wildrapport/screens/shared/main_nav_screen.dart';
import 'package:wildrapport/services/alarm_notification_resolver.dart';
import 'package:wildrapport/utils/notification_service.dart';
import 'package:wildlifenl_authenticator_components/wildlifenl_authenticator_components.dart';

/// Opens [AlarmsScreen] when the user taps an alarm push / local notification.
class NotificationNavigationHandler {
  NotificationNavigationHandler._();

  static const String routeAlarms = 'alarms';

  static GlobalKey<NavigatorState>? _navigatorKey;
  static WildLifeNLAuthenticator? _authenticator;
  static bool _pendingOpenAlarms = false;
  static String? _pendingAlarmId;
  static bool _coldStartProcessed = false;

  static void bind({
    required GlobalKey<NavigatorState> navigatorKey,
    WildLifeNLAuthenticator? authenticator,
  }) {
    _navigatorKey = navigatorKey;
    _authenticator = authenticator;
  }

  static void installTapHandler() {
    NotificationService.onNotificationTap = handlePayload;
  }

  /// Call once per app launch (FCM terminated + local notification launch).
  static Future<void> processColdStart() async {
    if (_coldStartProcessed || kIsWeb) return;
    _coldStartProcessed = true;

    try {
      final launchPayload =
          await NotificationService.instance.getLaunchNotificationPayload();
      if (launchPayload != null) {
        handlePayload(launchPayload);
      }
    } catch (e) {
      debugPrint('[NotifNav] Launch payload failed: $e');
    }

    try {
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        handleRemoteMessage(initial);
      }
    } catch (e) {
      debugPrint('[NotifNav] getInitialMessage failed: $e');
    }
  }

  static void handleRemoteMessage(RemoteMessage message) {
    if (!_isAlarmMessage(message.data, message.notification?.body)) {
      return;
    }
    final alarmId = AlarmNotificationResolver.extractAlarmId(
      message.data,
      message.notification?.body ?? '',
    );
    scheduleOpenAlarms(alarmId: alarmId);
    unawaited(tryNavigate());
  }

  static void handlePayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) return;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) return;
      final map = Map<String, dynamic>.from(decoded);
      if (map['route']?.toString() != routeAlarms) return;
      final alarmId = map['alarmId']?.toString();
      scheduleOpenAlarms(
        alarmId: alarmId != null && alarmId.isNotEmpty ? alarmId : null,
      );
      unawaited(tryNavigate());
    } catch (e) {
      debugPrint('[NotifNav] Invalid payload "$payload": $e');
    }
  }

  static void scheduleOpenAlarms({String? alarmId}) {
    _pendingOpenAlarms = true;
    if (alarmId != null && alarmId.isNotEmpty) {
      _pendingAlarmId = alarmId;
    }
    debugPrint('[NotifNav] Scheduled open alarms (alarmId=$_pendingAlarmId)');
  }

  /// After [MainNavScreen] is shown, retry navigation if login was not ready earlier.
  static Future<void> consumePendingAfterLogin() async {
    if (!_pendingOpenAlarms) return;
    await tryNavigate();
  }

  static Future<void> tryNavigate() async {
    if (!_pendingOpenAlarms) return;

    final nav = _navigatorKey?.currentState;
    if (nav == null) {
      debugPrint('[NotifNav] Navigator not ready');
      return;
    }

    final auth = _authenticator;
    if (auth != null) {
      try {
        final loggedIn = await auth.hasValidToken();
        if (!loggedIn) {
          debugPrint('[NotifNav] User not logged in — keep pending');
          return;
        }
      } catch (e) {
        debugPrint('[NotifNav] Auth check failed: $e');
        return;
      }
    }

    _pendingOpenAlarms = false;
    _pendingAlarmId = null;

    debugPrint('[NotifNav] Navigating to alarms screen');
    nav.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const MainNavScreen(
          initialTab: NavTab.kaart,
          openAlarmsDirectly: true,
        ),
      ),
      (_) => false,
    );
  }

  static String? payloadForRemoteMessage(RemoteMessage message) {
    if (!_isAlarmMessage(message.data, message.notification?.body)) {
      return null;
    }
    final alarmId = AlarmNotificationResolver.extractAlarmId(
      message.data,
      message.notification?.body ?? '',
    );
    return _encodePayload(alarmId: alarmId);
  }

  static String? payloadForAlarmData(
    Map<String, dynamic> data, {
    String fallbackBody = '',
  }) {
    if (!_isAlarmMessage(data, fallbackBody)) return null;
    final alarmId = AlarmNotificationResolver.extractAlarmId(data, fallbackBody);
    return _encodePayload(alarmId: alarmId);
  }

  static String _encodePayload({String? alarmId}) {
    return jsonEncode({
      'route': routeAlarms,
      if (alarmId != null && alarmId.isNotEmpty) 'alarmId': alarmId,
    });
  }

  static bool _isAlarmMessage(Map<String, dynamic> data, [String? body]) {
    final bodyText = body ?? '';
    if (AlarmNotificationResolver.extractAlarmId(data, bodyText) != null) {
      return true;
    }
    if (AlarmNotificationResolver.looksLikeAlarmIdOnly(bodyText)) {
      return true;
    }
    final type = data['type']?.toString().toLowerCase();
    if (type == 'alarm') return true;
    for (final key in ['alarmID', 'alarmId', 'alarm_id']) {
      if (data.containsKey(key)) return true;
    }
    return false;
  }
}
