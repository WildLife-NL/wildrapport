import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/utils/alarm_display_utils.dart';
import 'package:wildrapport/utils/api_datetime.dart';
import 'package:wildrapport/utils/event_timestamp_extractor.dart';

void main() {
  group('extractEventTimestampFromMap', () {
    test('ignores small start/end integers', () {
      final ts = extractEventTimestampFromMap({
        'start': 1,
        'end': 2,
        'moment': '2024-06-15T14:30:00Z',
      });
      expect(ts, '2024-06-15T14:30:00Z');
    });

    test('reads nested moment map', () {
      final ts = extractEventTimestampFromMap({
        'moment': {'timestamp': '2024-06-15T14:30:00Z'},
      });
      expect(ts, '2024-06-15T14:30:00Z');
    });

    test('reads reportOfSighting moment', () {
      final ts = extractEventTimestampFromMap({
        'reportOfSighting': {
          'moment': '2024-06-15T14:30:00Z',
        },
      });
      expect(ts, '2024-06-15T14:30:00Z');
    });
  });

  group('formatAlarmTimestamp', () {
    test('rejects year 1 style values', () {
      expect(formatAlarmTimestamp('1'), '—');
      expect(formatAlarmTimestamp('start: 1'), '—');
    });
  });

  group('tryParseBackendTimestampToUtc', () {
    test('rejects small numeric strings', () {
      expect(tryParseBackendTimestampToUtc('1'), isNull);
    });
  });
}
