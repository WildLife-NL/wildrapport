import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/models/enums/report_type.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/providers/map_provider.dart';

import 'package:wildrapport/screens/waarneming/location_selection_screen.dart';
import 'package:wildrapport/screens/schademelding/schademelding_location_selection_screen.dart';
import 'package:wildrapport/screens/belonging/belonging_animal_screen.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/widgets/location/invisible_map_preloader.dart';
import 'package:wildrapport/managers/api_managers/interaction_types_manager.dart';
import 'package:wildrapport/models/api_models/interaction_type.dart';
import 'package:wildrapport/utils/responsive_utils.dart';

class Rapporteren extends StatefulWidget {
  const Rapporteren({super.key, this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  State<Rapporteren> createState() => _RapporterenState();
}

class _RapporterenState extends State<Rapporteren> {
  String selectedCategory = '';
  List<InteractionType>? _interactionTypes;
  bool _isLoading = true;
  bool _hasLoadedTypes = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedTypes) {
      _hasLoadedTypes = true;
      _loadInteractionTypes();
    }
  }

  Future<void> _loadInteractionTypes() async {
    final interactionTypesManager = context.read<InteractionTypesManager>();
    try {
      final types = await interactionTypesManager.ensureFetched();
      debugPrint('[Rapporteren] Loaded ${types.length} interaction types');
      for (final type in types) {
        debugPrint('[Rapporteren]   - ${type.name} (ID: ${type.id})');
      }
      if (mounted) {
        setState(() {
          _interactionTypes = types;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[Rapporteren] Error loading interaction types: $e');
      if (mounted) {
        setState(() {
          _interactionTypes = [];
          _isLoading = false;
        });
      }
    }
  }

  void _handleReportTypeSelection(InteractionType interactionType) {
    final navigationManager = context.read<NavigationStateInterface>();
    final appStateProvider = context.read<AppStateProvider>();

    debugPrint(
      '[Rapporteren] Selected interaction type: ${interactionType.name} (ID: ${interactionType.id})',
    );

    Widget nextScreen;
    ReportType selectedReportType;

    // Map interaction type name to ReportType enum
    final typeName = interactionType.name.toLowerCase();

    if (typeName == 'waarneming' || typeName.contains('sighting')) {
      selectedReportType = ReportType.waarneming;
      final animalSightingManager =
          context.read<AnimalSightingReportingInterface>();
      animalSightingManager.createanimalSighting(reportType: 'waarneming');
      nextScreen = const LocationSelectionScreen();
      _initializeMapInBackground();
    } else if (typeName == 'schademelding' ||
        typeName.contains('crop damage')) {
      selectedReportType = ReportType.gewasschade;
      final animalSightingManager =
          context.read<AnimalSightingReportingInterface>();
      animalSightingManager.createanimalSighting(reportType: 'gewasschade');
      nextScreen = const SchademeldingLocationSelectionScreen();
      _initializeMapInBackground();
    } else if (typeName == 'dieraanrijding' ||
        typeName.contains('animal collision')) {
      selectedReportType = ReportType.verkeersongeval;
      final animalSightingManager =
          context.read<AnimalSightingReportingInterface>();
      animalSightingManager.createanimalSighting(reportType: 'verkeersongeval');
      nextScreen = const LocationSelectionScreen();
      _initializeMapInBackground();
    } else {
      // Default to waarneming for unknown types
      debugPrint(
        '[Rapporteren] Unknown interaction type: ${interactionType.name}, defaulting to waarneming',
      );
      selectedReportType = ReportType.waarneming;
      final animalSightingManager =
          context.read<AnimalSightingReportingInterface>();
      animalSightingManager.createanimalSighting(reportType: 'waarneming');
      nextScreen = const LocationSelectionScreen();
      _initializeMapInBackground();
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

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    context.read<NavigationStateInterface>();

    return Scaffold(
      backgroundColor: const Color(0XFFF5F6F4),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: CustomAppBar(
              leftIcon: null,
              centerText: 'Rapporteren',
              rightIcon: null,
              showUserIcon: false,
              useFixedText: true,
              onRightIconPressed: () {},
              // make title and arrow black and larger for this screen - more on smaller screens
              iconColor: Colors.black,
              textColor: Colors.black,
              fontScale: responsive.breakpointValue<double>(
                small: 1.4,
                medium: 1.3,
                large: 1.2,
                extraLarge: 1.15,
              ),
              iconScale: 1.15,
              userIconScale: 1.15,
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: true,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.wp(5),
                  vertical: responsive.hp(1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _interactionTypes == null ||
                            _interactionTypes!.isEmpty
                        ? Center(
                          child: Text(
                            'Geen interactietypen beschikbaar',
                            style: TextStyle(
                              fontSize: responsive.fontSize(16),
                            ),
                          ),
                        )
                        : SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: responsive.wp(5),
                              vertical: responsive.hp(2),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children:
                                          _interactionTypes!.map((type) {
                                          // Map interaction types to appropriate icon paths
                                          String iconPath;
                                          final typeName =
                                              type.name.toLowerCase();
                                          if (typeName == 'waarneming' ||
                                              typeName.contains('sighting')) {
                                            iconPath =
                                                'assets/sighting.svg';
                                          } else if (typeName ==
                                                  'schademelding' ||
                                              typeName.contains(
                                                'crop damage',
                                              )) {
                                            iconPath =
                                                'assets/damage.svg';
                                          } else if (typeName ==
                                                  'dieraanrijding' ||
                                              typeName.contains(
                                                'animal collision',
                                              )) {
                                            iconPath = 'assets/collision.svg';
                                          } else {
                                            iconPath =
                                                'assets/sighting.svg'; // Default icon
                                          }

                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom: responsive.hp(2.5),
                                            ),
                                            child: SizedBox(
                                              width: responsive.wp(90),
                                              height: 140,
                                              child: GestureDetector(
                                                onTap: () =>
                                                    _handleReportTypeSelection(
                                                      type,
                                                    ),
                                                child: Card(
                                                  elevation: 2,
                                                  shadowColor: Colors.black12,
                                                  color: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(18),
                                                    side: BorderSide(
                                                      color: Colors.grey.shade300,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: responsive.wp(6),
                                                      vertical: responsive.hp(2),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          width: 60,
                                                          height: 60,
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFFF5F6F4),
                                                            borderRadius:
                                                                BorderRadius.circular(14),
                                                          ),
                                                          child: Center(
                                                            child: SvgPicture.asset(
                                                              iconPath,
                                                              width: 32,
                                                              height: 32,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: responsive.wp(5),
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment.center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                type.name,
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      responsive
                                                                          .fontSize(
                                                                    16,
                                                                  ),
                                                                  fontWeight:
                                                                      FontWeight.w600,
                                                                  color:
                                                                      Colors.black,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 4),
                                                              Text(
                                                                _getDescriptionForType(
                                                                  type.name,
                                                                ),
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      responsive
                                                                          .fontSize(
                                                                    12,
                                                                  ),
                                                                  color: Colors.grey
                                                                      .shade600,
                                                                ),
                                                                maxLines: 1,
                                                                overflow: TextOverflow
                                                                    .ellipsis,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons.arrow_forward_ios,
                                                          size: 18,
                                                          color: Colors.grey.shade400,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDescriptionForType(String typeName) {
    final name = typeName.toLowerCase();
    if (name == 'waarneming' || name.contains('sighting')) {
      return 'Dierenwaarneming melden';
    } else if (name == 'schademelding' || name.contains('crop damage')) {
      return 'Gewasschade melden';
    } else if (name == 'dieraanrijding' || name.contains('animal collision')) {
      return 'Verkeersongeval melden';
    }
    return 'Rapport indienen';
  }
}
