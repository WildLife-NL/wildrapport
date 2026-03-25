import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wildrapport/interfaces/data_apis/interaction_api_interface.dart';
import 'package:wildrapport/managers/api_managers/interaction_manager.dart';
import 'package:wildrapport/interfaces/reporting/reportable_interface.dart';
import 'package:wildrapport/models/beta_models/interaction_model.dart';
import 'package:wildrapport/models/beta_models/interaction_response_model.dart';
import 'package:wildrapport/models/enums/interaction_type.dart';

class FakeInteractionApi implements InteractionApiInterface {
  int calls = 0;

  @override
  Future<InteractionResponse> sendInteraction(Interaction interaction) async {
    calls++;
    return InteractionResponse.empty(interactionID: 'fake');
  }
}

class FakeReportable implements Reportable {
  @override
  Map<String, dynamic> toJson() => {'ok': true};
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InteractionManager cache helpers', () {
    test('postInteraction throws if userID is missing', () async {
      SharedPreferences.setMockInitialValues({});
      final api = FakeInteractionApi();
      final mgr = InteractionManager(interactionAPI: api);

      expect(
        () => mgr.postInteraction(FakeReportable(), InteractionType.waarneming),
        throwsA(isA<Exception>()),
      );
    });
  });
}

