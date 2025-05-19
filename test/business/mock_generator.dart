// test/mocks/mock_api_data_service.dart

import 'package:mockito/annotations.dart';
import 'package:wildrapport/interfaces/animal_interface.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/api/auth_api_interface.dart';
import 'package:wildrapport/interfaces/api/belonging_api_interface.dart';
import 'package:wildrapport/interfaces/api/interaction_api_interface.dart';
import 'package:wildrapport/interfaces/api/profile_api_interface.dart';
import 'package:wildrapport/interfaces/api/questionnaire_api_interface.dart';
import 'package:wildrapport/interfaces/api/response_api_interface.dart';
import 'package:wildrapport/interfaces/api/species_api_interface.dart';
import 'package:wildrapport/interfaces/belonging_damage_report_interface.dart';
import 'package:wildrapport/interfaces/belonging_manager_interface.dart';
import 'package:wildrapport/interfaces/dropdown_interface.dart';
import 'package:wildrapport/interfaces/edit_state_interface.dart';
import 'package:wildrapport/interfaces/filter_interface.dart';
import 'package:wildrapport/interfaces/interaction_interface.dart';
import 'package:wildrapport/interfaces/living_lab_interface.dart';
import 'package:wildrapport/interfaces/location_screen_interface.dart';
import 'package:wildrapport/interfaces/login_interface.dart';
import 'package:wildrapport/interfaces/map/location_service_interface.dart';
import 'package:wildrapport/interfaces/map/map_service_interface.dart';
import 'package:wildrapport/interfaces/map/map_state_interface.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/interfaces/overzicht_interface.dart';
import 'package:wildrapport/interfaces/permission_interface.dart';
import 'package:wildrapport/interfaces/questionnaire_interface.dart';
import 'package:wildrapport/interfaces/reporting/common_report_fields.dart';
import 'package:wildrapport/interfaces/reporting/possesion_report_fields.dart';
import 'package:wildrapport/interfaces/reporting/reportable_interface.dart';
import 'package:wildrapport/interfaces/response_interface.dart';
import 'package:wildrapport/interfaces/screen_state_interface.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/providers/map_provider.dart';


// API interfaces Mocks
@GenerateMocks([AuthApiInterface])
@GenerateMocks([BelongingApiInterface])
@GenerateMocks([InteractionApiInterface])
@GenerateMocks([ProfileApiInterface])
@GenerateMocks([QuestionnaireApiInterface])
@GenerateMocks([ResponseApiInterface])
@GenerateMocks([SpeciesApiInterface])

// Map interfaces Mocks
@GenerateMocks([LocationServiceInterface])
@GenerateMocks([MapServiceInterface])
@GenerateMocks([MapStateInterface])

// Reporting interfaces Mocks
@GenerateMocks([CommonReportFields])
@GenerateMocks([PossesionReportFields])
@GenerateMocks([Reportable])

// Managers interfaces Mocks
@GenerateMocks([AnimalRepositoryInterface])
@GenerateMocks([AnimalSightingReportingInterface])
@GenerateMocks([BelongingDamageReportInterface])
@GenerateMocks([BelongingManagerInterface])
@GenerateMocks([DropdownInterface])
@GenerateMocks([EditStateInterface])
@GenerateMocks([CategoryInterface])
@GenerateMocks([FilterInterface])
@GenerateMocks([InteractionInterface])
@GenerateMocks([LivingLabInterface])
@GenerateMocks([LocationScreenInterface])
@GenerateMocks([LoginInterface])
@GenerateMocks([NavigationStateInterface])
@GenerateMocks([OverzichtInterface])
@GenerateMocks([PermissionInterface])
@GenerateMocks([QuestionnaireInterface])
@GenerateMocks([ResponseInterface])
@GenerateMocks([ScreenStateInterface])

//Provider Mocks
@GenerateMocks([AppStateProvider])
@GenerateMocks([MapProvider])






void main() {} // required for code generation
