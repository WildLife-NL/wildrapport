import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/models/enums/report_type.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/providers/interaction_type_provider.dart';
import 'package:wildrapport/screens/waarneming/animals_screen.dart';
import 'package:wildrapport/screens/shared/category_screen.dart';
import 'package:wildrapport/screens/shared/overzicht_screen.dart';
import 'package:wildrapport/screens/belonging/belonging_damages_screen.dart';
import 'package:wildrapport/screens/traffic_accident/traffic_accident_details_screen.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/widgets/location/invisible_map_preloader.dart';
import 'package:wildrapport/widgets/questionnaire/report_button.dart';

class Rapporteren extends StatefulWidget {
  const Rapporteren({super.key});

  @override
  State<Rapporteren> createState() => _RapporterenState();
}

class _RapporterenState extends State<Rapporteren> {
  String selectedCategory = '';

  void _handleReportTypeSelection(int interactionTypeId, String displayName) {
    final navigationManager = context.read<NavigationStateInterface>();
    final appStateProvider = context.read<AppStateProvider>();

    Widget nextScreen;
    ReportType selectedReportType;

    // Map interaction type ID to internal logic
    // ID 1 = Waarneming, ID 2 = Gewasschade, ID 3 = Verkeersongeval
    switch (interactionTypeId) {
      case 1: // Waarneming / Animal Sightings
        debugPrint('[Rapporteren] Animal sighting selected, initializing map');
        selectedReportType = ReportType.waarneming;
        // Create animal sighting report and save it in provider
        final animalSightingManager =
            context.read<AnimalSightingReportingInterface>();
        animalSightingManager.createanimalSighting();
        // Skip condition screen and go directly to category screen
        nextScreen = const CategoryScreen();
        _initializeMapInBackground();
        break;
      case 2: // Gewasschade / Crop Damage
        debugPrint('[Rapporteren] Gewasschade selected, initializing map');
        selectedReportType = ReportType.gewasschade;
        nextScreen = BelongingDamagesScreen();
        _initializeMapInBackground();
        break;
      case 3: // Verkeersongeval / Traffic Accident
        debugPrint('[Rapporteren] Verkeersongeval selected, initializing map');
        selectedReportType = ReportType.verkeersongeval;
        // Navigate to traffic accident details screen first
        nextScreen = const TrafficAccidentDetailsScreen();
        _initializeMapInBackground();
        break;
      case 4: // Diergezondheid / Animal Health (if exists)
        debugPrint('[Rapporteren] $displayName selected, initializing map');
        selectedReportType = ReportType.verkeersongeval;
        nextScreen = AnimalsScreen(appBarTitle: displayName);
        _initializeMapInBackground();
        break;
      default:
        throw Exception('Unknown interaction type ID: $interactionTypeId');
    }

    // Initialize the report in the app state
    appStateProvider.initializeReport(selectedReportType);

    // Use push instead of pushReplacement
    navigationManager.pushForward(context, nextScreen);
  }

  void _initializeMapInBackground() {
    if (!mounted) return;

    final mapProvider = context.read<MapProvider>();
    debugPrint(
      '[Rapporteren] Current map initialization status: ${mapProvider.isInitialized}',
    );

    if (!mapProvider.isInitialized) {
      try {
        const InvisibleMapPreloader();
        debugPrint('[Rapporteren] Invisible map preloader initialized');
      } catch (e) {
        debugPrint(
          '[Rapporteren] Error preloading invisible map: ${e.toString()}',
        );
      }
      debugPrint('[Rapporteren] Starting background map initialization');
      mapProvider
          .initialize()
          .then((_) {
            debugPrint('[Rapporteren] Background map initialization completed');
          })
          .catchError((error) {
            debugPrint(
              '[Rapporteren] Error in background map initialization: $error',
            );
          });
    } else {
      debugPrint('[Rapporteren] Map already initialized, skipping');
    }
  }

  void _handleBackNavigation(BuildContext context) {
    final navigationManager = context.read<NavigationStateInterface>();
    navigationManager.pushAndRemoveUntil(context, const OverzichtScreen());
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double verticalPadding = screenSize.height * 0.01;
    final double horizontalPadding = screenSize.width * 0.05;
    context.read<NavigationStateInterface>();

    final interactionTypeProvider = context.watch<InteractionTypeProvider>();

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Rapporteren',
              rightIcon: Icons.menu,
              onLeftIconPressed: () => _handleBackNavigation(context),
              onRightIconPressed: () {},
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: _buildContent(
                  context,
                  screenSize,
                  interactionTypeProvider,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Size screenSize,
    InteractionTypeProvider provider,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${provider.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Retry loading - would need to add retry method to manager
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please restart the app to retry'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.interactionTypes.isEmpty) {
      return const Center(child: Text('No interaction types available'));
    }

    // Map icon paths for each interaction type ID
    final Map<int, String> iconPaths = {
      1: 'assets/icons/rapporteren/sighting_icon.png', // Waarneming
      2: 'assets/icons/rapporteren/crop_icon.png', // Gewasschade
      3: 'assets/icons/rapporteren/accident_icon.png', // Verkeersongeval
      4: 'assets/icons/rapporteren/health_icon.png', // Diergezondheid (if exists)
    };

    // Build grid of buttons dynamically
    final types = provider.interactionTypes;
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              if (types.length > 0)
                Expanded(
                  child: ReportButton(
                    image: iconPaths[types[0].id] ??
                        'assets/icons/rapporteren/sighting_icon.png',
                    text: types[0].name,
                    onPressed: () => _handleReportTypeSelection(
                      types[0].id,
                      types[0].name,
                    ),
                  ),
                ),
              if (types.length > 1) ...[
                SizedBox(width: screenSize.width * 0.02),
                Expanded(
                  child: ReportButton(
                    image: iconPaths[types[1].id] ??
                        'assets/icons/rapporteren/crop_icon.png',
                    text: types[1].name,
                    onPressed: () => _handleReportTypeSelection(
                      types[1].id,
                      types[1].name,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (types.length > 2) SizedBox(height: screenSize.height * 0.02),
        if (types.length > 2)
          Expanded(
            child: Row(
              children: [
                if (types.length > 2)
                  Expanded(
                    child: ReportButton(
                      image: iconPaths[types[2].id] ??
                          'assets/icons/rapporteren/accident_icon.png',
                      text: types[2].name,
                      onPressed: () => _handleReportTypeSelection(
                        types[2].id,
                        types[2].name,
                      ),
                    ),
                  ),
                if (types.length > 3) ...[
                  SizedBox(width: screenSize.width * 0.02),
                  Expanded(
                    child: ReportButton(
                      image: iconPaths[types[3].id] ??
                          'assets/icons/rapporteren/health_icon.png',
                      text: types[3].name,
                      onPressed: () => _handleReportTypeSelection(
                        types[3].id,
                        types[3].name,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
