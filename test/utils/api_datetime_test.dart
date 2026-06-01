import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/utils/api_datetime.dart';

void main() {
  group('parseBackendTimestampToUtc', () {
    test('naive ISO is interpreted as UTC', () {
      final utc = parseBackendTimestampToUtc('2024-06-01T12:30:00');
      expect(utc.isUtc, isTrue);
      expect(utc.hour, 12);
      expect(utc.minute, 30);
    });

    test('Z suffix is parsed as UTC', () {
      final utc = parseBackendTimestampToUtc('2024-06-01T10:30:00Z');
      expect(utc.hour, 10);
    });

    test('offset suffix converts to UTC', () {
      final utc = parseBackendTimestampToUtc('2024-06-01T14:30:00+02:00');
      expect(utc.hour, 12);
    });

    test('space-separated datetime is parsed', () {
      final utc = tryParseBackendTimestampToUtc('2024-06-15 12:30:00');
      expect(utc, isNotNull);
      expect(utc!.year, 2024);
      expect(utc.hour, 12);
    });
  });

  group('parseApiMomentToUtc', () {
    test('naive ISO is treated as local wall-clock', () {
      final utc = parseApiMomentToUtc('2024-06-01T12:30:00');
      expect(utc.isUtc, isTrue);
    });
  });
}
