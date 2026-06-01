import 'package:wildrapport/interfaces/data_apis/tracking_api_interface.dart';
import 'package:wildrapport/models/api_models/vicinity.dart';

/// Decides when a vicinity / tracking notice should surface as a phone notification.
///
/// Notifications fire when the user newly enters the vicinity of an animal,
/// detection or interaction — not on every tracking ping at the same spot.
class VicinityNoticePolicy {
  Set<String> _keysFromLastPing = {};
  String? _lastShownMessageKey;

  static Set<String> vicinityKeys(Vicinity? vicinity) {
    if (vicinity == null) return {};
    final keys = <String>{};
    for (final animal in vicinity.animals) {
      keys.add('animal:${animal.id}');
    }
    for (final detection in vicinity.detections) {
      keys.add('detection:${detection.id}');
    }
    for (final interaction in vicinity.interactions) {
      keys.add('interaction:${interaction.id}');
    }
    return keys;
  }

  static String messageKey(TrackingNotice notice) {
    return '${notice.severity ?? ''}|${notice.text.trim().toLowerCase()}';
  }

  /// Whether a proximity notification should be shown for this ping.
  bool shouldShowProximityNotification(TrackingNotice notice) {
    if (!notice.hasMessage) return false;

    final currentKeys = vicinityKeys(notice.vicinity);
    if (currentKeys.isNotEmpty) {
      final newlyEntered = currentKeys.difference(_keysFromLastPing);
      return newlyEntered.isNotEmpty;
    }

    final key = messageKey(notice);
    return key != _lastShownMessageKey;
  }

  /// Call after each tracking ping so the next ping can detect newly entered wildlife.
  void recordPingResult(TrackingNotice? notice) {
    _keysFromLastPing = vicinityKeys(notice?.vicinity);
  }

  void recordNotificationShown(TrackingNotice notice) {
    _lastShownMessageKey = messageKey(notice);
  }

  void reset() {
    _keysFromLastPing = {};
    _lastShownMessageKey = null;
  }
}
