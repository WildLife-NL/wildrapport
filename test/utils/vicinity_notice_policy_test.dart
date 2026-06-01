import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/interfaces/data_apis/tracking_api_interface.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_pin.dart';
import 'package:wildrapport/models/api_models/vicinity.dart';
import 'package:wildrapport/utils/vicinity_notice_policy.dart';

void main() {
  Vicinity vicinityWithBeaver() {
    return Vicinity(
      animals: [
        AnimalPin(
          id: 'beaver-1',
          lat: 52.0,
          lon: 5.0,
          seenAt: DateTime.utc(2026, 1, 1),
          speciesName: 'Bever',
        ),
      ],
      detections: const [],
      interactions: const [],
    );
  }

  test('notifies when a new animal enters vicinity', () {
    final policy = VicinityNoticePolicy();
    final notice = TrackingNotice(
      'Let op: bever in de buurt',
      severity: 1,
      vicinity: vicinityWithBeaver(),
    );

    expect(policy.shouldShowProximityNotification(notice), isTrue);
    policy.recordPingResult(notice);
    policy.recordNotificationShown(notice);

    expect(policy.shouldShowProximityNotification(notice), isFalse);
  });

  test('notifies again after leaving and re-entering vicinity', () {
    final policy = VicinityNoticePolicy();
    final notice = TrackingNotice(
      'Let op: bever in de buurt',
      severity: 1,
      vicinity: vicinityWithBeaver(),
    );

    policy.recordPingResult(notice);
    policy.recordNotificationShown(notice);
    expect(policy.shouldShowProximityNotification(notice), isFalse);

    policy.recordPingResult(
      TrackingNotice('', vicinity: Vicinity(animals: [], detections: [], interactions: [])),
    );
    expect(policy.shouldShowProximityNotification(notice), isTrue);
  });

  test('dedupes identical message-only notices', () {
    final policy = VicinityNoticePolicy();
    final notice = TrackingNotice('Let op: bever in de buurt', severity: 1);

    expect(policy.shouldShowProximityNotification(notice), isTrue);
    policy.recordPingResult(notice);
    policy.recordNotificationShown(notice);

    expect(policy.shouldShowProximityNotification(notice), isFalse);
  });
}
