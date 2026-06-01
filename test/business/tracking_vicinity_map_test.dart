import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/models/api_models/interaction_query_result.dart';
import 'package:wildrapport/models/api_models/vicinity.dart';
import 'package:wildrapport/utils/tracking_vicinity_parser.dart';

void main() {
  group('TrackingVicinityParser', () {
    test('filterNearReading drops pins far from reading', () {
      final filtered = TrackingVicinityParser.filterNearReading(
        Vicinity(
          animals: [],
          detections: [],
          interactions: [
            InteractionQueryResult(
              id: 'close',
              lat: 52.0,
              lon: 5.0,
              moment: DateTime.now().toUtc(),
            ),
            InteractionQueryResult(
              id: 'far',
              lat: 52.3,
              lon: 5.0,
              moment: DateTime.now().toUtc(),
            ),
          ],
        ),
        52.0,
        5.0,
      );

      expect(filtered.interactions.length, 1);
      expect(filtered.interactions.first.id, 'close');
    });

    test('mergeReadingsList combines pins from multiple readings', () {
      final body = '''
[
  {
    "timestamp": "2026-03-25T10:00:00Z",
    "location": {"latitude": 52.0, "longitude": 5.0},
    "interactions": [
      {
        "ID": "near-old",
        "location": {"latitude": 52.001, "longitude": 5.001},
        "moment": "2026-03-25T09:00:00Z",
        "type": {"name": "waarneming"}
      }
    ]
  },
  {
    "timestamp": "2026-03-25T14:00:00Z",
    "location": {"latitude": 52.2, "longitude": 5.2},
    "interactions": [
      {
        "ID": "near-new",
        "location": {"latitude": 52.201, "longitude": 5.201},
        "moment": "2026-03-25T13:00:00Z",
        "type": {"name": "waarneming"}
      }
    ]
  }
]
''';
      final merged = TrackingVicinityParser.parseResponseBody(
        body,
        tag: 'test',
        endpoint: 'GET /tracking-readings/me/',
      );

      expect(merged.interactions.length, 2);
      expect(
        merged.interactions.map((i) => i.id).toSet(),
        {'near-old', 'near-new'},
      );
    });

    test('parseResponseBody handles single tracking reading object', () {
      final body = '''
{
  "userID": "u1",
  "timestamp": "2025-01-02T10:00:00Z",
  "location": {"latitude": 52.0, "longitude": 5.0},
  "animals": [],
  "detections": [],
  "interactions": [
    {
      "ID": "x1",
      "location": {"latitude": 52.001, "longitude": 5.001},
      "moment": "2025-01-02T09:00:00Z",
      "type": {"name": "waarneming"},
      "species": {"commonName": "Ree"}
    }
  ]
}
''';
      final vicinity = TrackingVicinityParser.parseResponseBody(
        body,
        tag: 'test',
        endpoint: 'POST /tracking-reading/',
      );
      expect(vicinity.interactions.single.id, 'x1');
    });
  });
}
