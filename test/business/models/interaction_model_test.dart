import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wildrapport/models/enums/interaction_type.dart';
import '../mock_generator.mocks.dart';

void main() {
  late MockInteraction mockInteraction;
  late MockReportable mockReport;

  setUp(() {
    mockInteraction = MockInteraction();
    mockReport = MockReportable();
    
    // Setup default behavior
    when(mockInteraction.userID).thenReturn('user-456');
    when(mockInteraction.interactionType).thenReturn(InteractionType.waarneming);
    when(mockInteraction.report).thenReturn(mockReport);
    when(mockReport.toJson()).thenReturn({'test': 'data'});
  });

  group('Interaction Model Tests', () {
    test('should have correct properties', () {
      // Verify the properties
      expect(mockInteraction.userID, 'user-456');
      expect(mockInteraction.interactionType, InteractionType.waarneming);
      expect(mockInteraction.report, mockReport);
    });

    test('toJson should return correct map', () {
      // Setup mock behavior for toJson
      when(mockInteraction.toJson()).thenReturn({
        'userID': 'user-456',
        'interactionType': 'waarneming',
        'report': {'test': 'data'},
      });
      
      // Verify
      final json = mockInteraction.toJson();
      expect(json['userID'], 'user-456');
      expect(json['interactionType'], 'waarneming');
      expect(json['report'], {'test': 'data'});
    });
  });
}

