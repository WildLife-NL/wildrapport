import 'package:mockito/annotations.dart';
import 'package:wildrapport/interfaces/api/auth_api_interface.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/interfaces/login_interface.dart';

@GenerateMocks([AuthApiInterface, NavigationStateInterface])
@GenerateMocks(
  [LoginInterface],
  customMocks: [MockSpec<LoginInterface>(as: #MockLoginManager)],
)
void main() {}
