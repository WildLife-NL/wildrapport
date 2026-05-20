import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wildrapport/firebase_options.dart';
import 'package:wildrapport/services/alarm_notification_resolver.dart';
import 'package:wildrapport/services/notification_navigation_handler.dart';
import 'package:wildrapport/utils/notification_service.dart';

/// Background FCM (app terminated / background). Must be top-level.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('[FCM] dotenv load in background failed: $e');
  }
  await NotificationService.instance.init();
  await _showRemoteMessageAsNotification(message);
}

/// Parses FCM notification + data payloads (backend may send either).
({String title, String body}) _parseRemoteMessage(RemoteMessage message) {
  final notification = message.notification;
  if (notification != null &&
      ((notification.title?.isNotEmpty ?? false) ||
          (notification.body?.isNotEmpty ?? false))) {
    return (
      title: notification.title ?? 'Wild Rapport',
      body: notification.body ?? 'Nieuwe melding',
    );
  }

  final data = message.data;
  String readString(String key) {
    final value = data[key];
    if (value == null) return '';
    return value.toString().trim();
  }

  final title = [
    readString('title'),
    readString('Title'),
    readString('subject'),
    readString('alarmTitle'),
  ].firstWhere((s) => s.isNotEmpty, orElse: () => 'Wild Rapport');

  final body = [
    readString('body'),
    readString('Body'),
    readString('message'),
    readString('text'),
    readString('content'),
    readString('alarmMessage'),
    readString('alarmBody'),
  ].firstWhere((s) => s.isNotEmpty, orElse: () => '');

  if (body.isNotEmpty) {
    return (title: title, body: body);
  }

  // Data-only message without known keys — still surface something visible.
  if (data.isNotEmpty) {
    final summary = data.entries
        .where((e) => e.value != null && e.value.toString().isNotEmpty)
        .map((e) => '${e.key}: ${e.value}')
        .take(2)
        .join('\n');
    return (
      title: title,
      body: summary.isEmpty ? 'Nieuwe melding' : summary,
    );
  }

  return (title: title, body: '');
}

Future<void> _showRemoteMessageAsNotification(RemoteMessage message) async {
  var parsed = _parseRemoteMessage(message);

  final alarmResolved = await AlarmNotificationResolver.resolve(
    data: message.data,
    fallbackTitle: parsed.title,
    fallbackBody: parsed.body,
  );
  if (alarmResolved != null) {
    parsed = alarmResolved;
  } else if (AlarmNotificationResolver.looksLikeAlarmIdOnly(parsed.body)) {
    parsed = (
      title: 'Wild Rapport',
      body: 'Nieuw alarm — open de app voor details.',
    );
  }

  if (parsed.body.isEmpty && parsed.title == 'Wild Rapport') {
    debugPrint(
      '[FCM] Message ignored (no title/body/data): id=${message.messageId} '
      'data=${message.data}',
    );
    return;
  }

  debugPrint(
    '[FCM] Showing push: title="${parsed.title}" body="${parsed.body}" '
    'data=${message.data}',
  );

  final payload = NotificationNavigationHandler.payloadForRemoteMessage(message) ??
      (alarmResolved != null
          ? NotificationNavigationHandler.payloadForAlarmData(
              message.data,
              fallbackBody: parsed.body,
            )
          : null);

  await NotificationService.instance.show(
    title: parsed.title,
    body: parsed.body.isEmpty ? 'Nieuwe melding' : parsed.body,
    importance: Importance.high,
    priority: Priority.high,
    channelId: kPushNotificationChannelId,
    payload: payload,
  );
}

/// Foreground + tap handlers. Call once after Firebase is ready (logged-in session).
void attachFirebaseMessageListeners() {
  if (kIsWeb) return;

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    debugPrint('[FCM] onMessage (foreground): ${message.messageId}');
    await _showRemoteMessageAsNotification(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('[FCM] Opened from notification: ${message.data}');
    NotificationNavigationHandler.handleRemoteMessage(message);
  });
}
