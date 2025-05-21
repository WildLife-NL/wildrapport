// test/mocks/mock_api_data_service.dart

import 'package:mockito/annotations.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_interface.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/data_apis/auth_api_interface.dart';
import 'package:wildrapport/interfaces/data_apis/belonging_api_interface.dart';
import 'package:wildrapport/interfaces/data_apis/interaction_api_interface.dart';
import 'package:wildrapport/interfaces/data_apis/profile_api_interface.dart';
import 'package:wildrapport/interfaces/data_apis/questionnaire_api_interface.dart';
import 'package:wildrapport/interfaces/data_apis/response_api_interface.dart';
import 'package:wildrapport/interfaces/data_apis/species_api_interface.dart';
import 'package:wildrapport/interfaces/reporting/belonging_damage_report_interface.dart';
import 'package:wildrapport/interfaces/other/belonging_manager_interface.dart';
import 'package:wildrapport/interfaces/filters/dropdown_interface.dart';
import 'package:wildrapport/interfaces/state/edit_state_interface.dart';
import 'package:wildrapport/interfaces/filters/filter_interface.dart';
import 'package:wildrapport/interfaces/reporting/interaction_interface.dart';
import 'package:wildrapport/interfaces/location/living_lab_interface.dart';
import 'package:wildrapport/interfaces/location/location_screen_interface.dart';
import 'package:wildrapport/interfaces/other/login_interface.dart';
import 'package:wildrapport/interfaces/map/location_service_interface.dart';
import 'package:wildrapport/interfaces/map/map_service_interface.dart';
import 'package:wildrapport/interfaces/map/map_state_interface.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/interfaces/other/overzicht_interface.dart';
import 'package:wildrapport/interfaces/other/permission_interface.dart';
import 'package:wildrapport/interfaces/reporting/questionnaire_interface.dart';
import 'package:wildrapport/interfaces/reporting/common_report_fields.dart';
import 'package:wildrapport/interfaces/reporting/possesion_report_fields.dart';
import 'package:wildrapport/interfaces/reporting/reportable_interface.dart';
import 'package:wildrapport/interfaces/reporting/response_interface.dart';
import 'package:wildrapport/interfaces/state/screen_state_interface.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
@GenerateMocks([AnimalManagerInterface])

// Add these new mocks
@GenerateMocks([BuildContext])
@GenerateMocks([SharedPreferences])

void main() {} // required for code generation
