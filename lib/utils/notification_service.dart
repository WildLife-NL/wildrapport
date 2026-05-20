import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wildrapport/constants/app_colors.dart';

/// Android channel for FCM + in-app notifications. Matches AndroidManifest meta-data.
const String kPushNotificationChannelId = 'wildrapport_push';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  /// Set from [main] before [init]; invoked when user taps a local notification.
  static void Function(String? payload)? onNotificationTap;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Do not request iOS permission here — only after login via
    // [PushNotificationCoordinator] (FCM + profile update).
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          onNotificationTap?.call(payload);
        }
      },
    );
    await ensureAndroidChannel();

    _initialized = true;
  }

  /// Payload when the app was launched by tapping a notification (cold start).
  Future<String?> getLaunchNotificationPayload() async {
    if (!_initialized) await init();
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    return details?.notificationResponse?.payload;
  }

  /// System permission prompt (Android 13+: POST_NOTIFICATIONS; iOS: no-op here).
  /// On iOS, use [FirebaseMessaging.requestPermission] from the push coordinator.
  Future<bool> requestAndroidNotificationPermission() async {
    if (kIsWeb || !Platform.isAndroid) return true;
    if (!_initialized) await init();

    // Primary: permission_handler (reliable POST_NOTIFICATIONS dialog on Android 13+).
    final status = await Permission.notification.request();
    debugPrint(
      '[NotificationService] Permission.notification: $status',
    );
    if (status.isGranted || status.isLimited) {
      return true;
    }
    if (status.isPermanentlyDenied) {
      return false;
    }

    // Fallback: flutter_local_notifications.
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidImpl?.requestNotificationsPermission();
    debugPrint(
      '[NotificationService] flutter_local_notifications permission: $granted',
    );
    return granted ?? status.isGranted;
  }

  /// Android notification channel only (no runtime permission prompt).
  Future<void> ensureAndroidChannel() async {
    if (!kIsWeb && Platform.isAndroid) {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        kPushNotificationChannelId,
        'Meldingen',
        description: 'Alarmen en pushmeldingen van Wild Rapport',
        importance: Importance.high,
      );
      await androidImpl?.createNotificationChannel(channel);

      // Legacy channel (older builds / default FCM meta-data).
      const AndroidNotificationChannel legacyChannel = AndroidNotificationChannel(
        'default_channel',
        'General',
        description: 'General notifications',
        importance: Importance.high,
      );
      await androidImpl?.createNotificationChannel(legacyChannel);
    }
  }

  Future<void> show({
    required String title,
    required String body,
    Importance importance = Importance.defaultImportance,
    Priority priority = Priority.defaultPriority,
    String channelId = kPushNotificationChannelId,
    String? payload,
  }) async {
    if (!_initialized) await init();

    if (!kIsWeb && Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        debugPrint(
          '[NotificationService] Skip show — notification permission not granted',
        );
        return;
      }
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == kPushNotificationChannelId ? 'Meldingen' : 'General',
      channelDescription: 'Alarmen en meldingen',
      importance: importance,
      priority: priority,
      color: AppColors.primaryGreen,
      colorized: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: title,
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> showConveyanceNotification({
    required String messageText,
    String? animalName,
  }) async {
    String title = 'Nieuwe melding';
    if (animalName != null && animalName.isNotEmpty) {
      title = 'Melding: $animalName';
    }

    await show(
      title: title,
      body: messageText,
      importance: Importance.high,
      priority: Priority.high,
    );
  }
}
