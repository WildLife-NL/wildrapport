import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/reporting/interaction_interface.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/screens/location/location_screen.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/enums/animal_condition.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_model.dart';
import 'package:wildrapport/screens/shared/main_nav_screen.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/utils/interaction_pin_factory.dart';
import 'package:wildrapport/models/enums/nav_tab.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/models/animal_waarneming_models/view_count_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_gender_view_count_model.dart';
import 'package:wildrapport/providers/submitted_sightings_provider.dart';
<<<<<<< HEAD
import 'package:wildrapport/config/app_config.dart';
import 'package:wildrapport/constants/sighting_report_activities.dart';
=======
//import 'package:wildrapport/screens/waarneming/animal_activity_screen.dart';
>>>>>>> f1e6c1c (feat: add animal activity input page)

class AnimalWaarnemingSummaryScreen extends StatefulWidget {
  final int totalCount;

  const AnimalWaarnemingSummaryScreen({
    super.key,
    required this.totalCount,
  });

  @override
  State<AnimalWaarnemingSummaryScreen> createState() =>
      _AnimalWaarnemingSummaryScreenState();
}

class _AnimalWaarnemingSummaryScreenState
    extends State<AnimalWaarnemingSummaryScreen> {
  bool _isSubmitting = false;
<<<<<<< HEAD
  bool _activitiesHydrated = false;
  bool _schemaLoading = true;
  String? _schemaError;
  String _humanActivity = SightingReportActivityCatalog.defaultHumanActivity;
  String _perceivedAnimalActivity =
      SightingReportActivityCatalog.defaultPerceivedAnimalActivity;
  final TextEditingController _humanActivityOtherController =
      TextEditingController();
  final TextEditingController _perceivedAnimalActivityOtherController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadActivitySchema();
  }

  @override
  void dispose() {
    _humanActivityOtherController.dispose();
    _perceivedAnimalActivityOtherController.dispose();
    super.dispose();
  }

  Future<void> _loadActivitySchema() async {
    try {
      await SightingReportActivityCatalog.load(AppConfig.shared.apiClient);
      if (!mounted) return;
      setState(() {
        _schemaLoading = false;
        _schemaError = null;
      });
      _hydrateActivitiesFromSighting();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _schemaLoading = false;
        _schemaError = e.toString();
      });
    }
  }

  void _hydrateActivitiesFromSighting() {
    if (_activitiesHydrated || !SightingReportActivityCatalog.isLoaded) return;
    final sighting =
        context.read<AnimalSightingReportingInterface>().getCurrentanimalSighting();
    _humanActivity = SightingReportActivityCatalog.normalizeHuman(
      sighting?.humanActivity,
    );
    _perceivedAnimalActivity = SightingReportActivityCatalog.normalizePerceivedAnimal(
      sighting?.perceivedAnimalActivity,
    );
    _humanActivityOtherController.text = sighting?.humanActivityOther ?? '';
    _perceivedAnimalActivityOtherController.text =
        sighting?.perceivedAnimalActivityOther ?? '';
    _activitiesHydrated = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _hydrateActivitiesFromSighting();
  }
=======
>>>>>>> f1e6c1c (feat: add animal activity input page)

  void _validateActivityFields() {
    if (SightingReportActivityCatalog.isOtherHuman(_humanActivity) &&
        _humanActivityOtherController.text.trim().isEmpty) {
      throw Exception('Vul je activiteit in bij "Anders, namelijk ..."');
    }
    if (SightingReportActivityCatalog.isOtherPerceivedAnimal(
          _perceivedAnimalActivity,
        ) &&
        _perceivedAnimalActivityOtherController.text.trim().isEmpty) {
      throw Exception(
        'Vul de activiteit van het dier in bij "Anders, namelijk ..."',
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final sightingManager =
          context.read<AnimalSightingReportingInterface>();
      final interactionManager = context.read<InteractionInterface>();
      final submittedProvider = context.read<SubmittedSightingsProvider>();
      var sighting = sightingManager.getCurrentanimalSighting();

      if (sighting == null) return;

      if (sighting.locations == null || sighting.locations!.isEmpty) {
        throw Exception('Geen locatie geselecteerd');
      }

      if (sighting.dateTime?.dateTime == null) {
        throw Exception('Geen datum/tijd geselecteerd');
      }

      if ((sighting.animals?.isEmpty ?? true) &&
          sighting.animalSelected != null &&
          widget.totalCount > 0) {
        final animalsToAdd = <AnimalModel>[];

        for (int i = 0; i < widget.totalCount; i++) {
          final unknownViewCount = ViewCountModel()..unknownAmount = 1;

          animalsToAdd.add(
            AnimalModel(
              animalId: sighting.animalSelected!.animalId,
              animalImagePath: sighting.animalSelected!.animalImagePath,
              animalName: sighting.animalSelected!.animalName,
              category: sighting.animalSelected!.category,
              genderViewCounts: [
                AnimalGenderViewCount(
                  gender: AnimalGender.onbekend,
                  viewCount: unknownViewCount,
                ),
              ],
              condition: AnimalCondition.onbekend,
<<<<<<< HEAD
            ));
          }
          sighting = sighting.copyWith(animals: animalsToAdd);
          sightingManager.updateCurrentanimalSighting(sighting);
        }

        // Make sure grouped/edited animal entries are synced before sending.
        sightingManager.syncObservedAnimalsToSighting();

        _validateActivityFields();

        sighting = sighting.copyWith(
          humanActivity: _humanActivity,
          humanActivityOther: _humanActivityOtherController.text.trim(),
          perceivedAnimalActivity: _perceivedAnimalActivity,
          perceivedAnimalActivityOther:
              _perceivedAnimalActivityOtherController.text.trim(),
        );
        sightingManager.updateCurrentanimalSighting(sighting);

        // Real submit to backend via the same interaction pipeline.
        final response = await submitReport(
          sightingManager,
          interactionManager,
          context,
        );
        if (response == null) {
          throw Exception(
            'Geen verbinding of verzenden mislukt. Controleer internet en probeer opnieuw.',
=======
            ),
>>>>>>> f1e6c1c (feat: add animal activity input page)
          );
        }

        sighting = sighting.copyWith(animals: animalsToAdd);
        sightingManager.updateCurrentanimalSighting(sighting);
      }

      sightingManager.syncObservedAnimalsToSighting();

      final response = await submitReport(
        sightingManager,
        interactionManager,
        context,
      );

      if (response == null) {
        throw Exception(
          'Geen verbinding of verzenden mislukt. Controleer internet en probeer opnieuw.',
        );
      }

      final mapPin = interactionPinFromSighting(
        sighting,
        response.interactionID,
      );

      if (mapPin != null) {
        context.read<MapProvider>().addOrUpdateInteraction(mapPin);
      }

      submittedProvider.addSighting(sighting);
      sightingManager.clearCurrentanimalSighting();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MainNavScreen(
            initialTab: NavTab.logboek,
            openRecentSightingsDirectly: true,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Versturen mislukt: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _handleExit() {
    final sightingManager = context.read<AnimalSightingReportingInterface>();
    sightingManager.clearCurrentanimalSighting();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const MainNavScreen(
          initialTab: NavTab.rapporten,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sightingManager = context.read<AnimalSightingReportingInterface>();
    final sighting = sightingManager.getCurrentanimalSighting();
    final selectedAnimal = sighting?.animalSelected;

    final appBarTitle = sighting?.reportType == 'verkeersongeval'
        ? 'Dieraanrijding'
        : 'Waarneming';

    if (selectedAnimal == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F6F4),
        body: Center(
          child: Text('No animal selected'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F4),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomAppBar(
              centerText: appBarTitle,
              rightIcon: Icons.exit_to_app_rounded,
              onRightIconPressed: _handleExit,
              showUserIcon: false,
              useFixedText: true,
              textColor: AppColors.textPrimary,
              iconColor: Colors.grey,
              fontScale: 1.4,
              iconScale: 0.85,
              userIconScale: 1.15,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(
                      color: Color(0xFF999999),
                      width: 1,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Overzicht',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),

                          Center(
                            child: SizedBox(
                              width: 140,
                              child: Card(
                                shadowColor:
                                    const Color.fromARGB(133, 0, 0, 0)
                                        .withValues(alpha: 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(
                                    color: Color(0xFF999999),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 140,
                                      height: 120,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(14),
                                          topRight: Radius.circular(14),
                                        ),
                                        child: selectedAnimal.animalImagePath !=
                                                null
                                            ? Image(
                                                image: AssetImage(
                                                  selectedAnimal
                                                      .animalImagePath!,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                            : Center(
                                                child: Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                  size: 50,
                                                  color: Colors.grey[400],
                                                ),
                                              ),
                                      ),
                                    ),
                                    Container(
                                      height: 1,
                                      color: const Color(0xFF999999),
                                      width: 140,
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(14),
                                        bottomRight: Radius.circular(14),
                                      ),
                                    ),            
                                      width: 140,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 12,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            selectedAnimal.animalName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.textPrimary,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _getConditionDisplay(
                                              sighting?.animals?.isNotEmpty ==
                                                      true
                                                  ? sighting!
                                                      .animals!.first.condition
                                                  : AnimalCondition.onbekend,
                                            ),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[600],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Aantal: ${widget.totalCount}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Color(0xFFE8E8E8),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ..._buildAnimalDetailsList(
                                    sighting?.animals,
                                    widget.totalCount,
                                    sighting?.animalSelected,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Color(0xFFE8E8E8),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _infoRow(
                                    icon: Icons.location_on,
                                    title: 'Locatie',
                                    value:
                                        _getLocationDisplay(sighting?.locations),
                                  ),
                                  const SizedBox(height: 14),
                                  Divider(
                                    color:
                                        Colors.grey.withValues(alpha: 0.15),
                                    height: 1,
                                  ),
                                  const SizedBox(height: 14),
                                  _infoRow(
                                    icon: Icons.calendar_today,
                                    title: 'Datum & Tijd',
                                    value:
                                        _getDateTimeDisplay(sighting?.dateTime),
                                  ),
                                ],
                              ),
                            ),
                          ),
<<<<<<< HEAD
                          // Dieraanrijding specific details
                          if (sighting?.reportType == 'verkeersongeval') ...[
                            const SizedBox(height: 16),
                            Card(
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Color(0xFFE8E8E8),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0F0F0),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.trending_down, size: 18, color: Colors.grey[700]),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Verwacht verlies',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                sighting?.expectedLoss ?? 'Onbekend',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Divider(
                                      color: Colors.grey.withValues(alpha: 0.15),
                                      height: 1,
                                      thickness: 1,
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0F0F0),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.warning_amber, size: 18, color: Colors.grey[700]),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Ernst van het ongeluk',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                sighting?.accidentSeverity ?? 'Onbekend',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Divider(
                                      color: Colors.grey.withValues(alpha: 0.15),
                                      height: 1,
                                      thickness: 1,
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0F0F0),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.pets, size: 18, color: Colors.grey[700]),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Toestand dier',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                sighting?.animalConditionDieraanrijding ?? 'Onbekend',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          if (sighting?.reportType != 'verkeersongeval') ...[
                            const SizedBox(height: 16),
                            Card(
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Color(0xFFE8E8E8),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'Activiteit',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (_schemaLoading)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    else if (_schemaError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              'Activiteiten laden mislukt: $_schemaError',
                                              style: TextStyle(
                                                color: Colors.red[700],
                                                fontSize: 13,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _schemaLoading = true;
                                                  _schemaError = null;
                                                  _activitiesHydrated = false;
                                                });
                                                _loadActivitySchema();
                                              },
                                              child: const Text('Opnieuw proberen'),
                                            ),
                                          ],
                                        ),
                                      )
                                    else ...[
                                      const SizedBox(height: 12),
                                      _activityDropdown(
                                        label: 'Jouw activiteit',
                                        value: _humanActivity,
                                        options: SightingReportActivityCatalog
                                            .instance
                                            .humanActivities,
                                        onChanged: (v) => setState(
                                          () => _humanActivity = v,
                                        ),
                                      ),
                                      if (SightingReportActivityCatalog
                                          .isOtherHuman(_humanActivity)) ...[
                                        const SizedBox(height: 8),
                                        _activityOtherField(
                                          controller:
                                              _humanActivityOtherController,
                                          hint: 'Jouw activiteit (anders)',
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      _activityDropdown(
                                        label: 'Activiteit van het dier',
                                        value: _perceivedAnimalActivity,
                                        options: SightingReportActivityCatalog
                                            .instance
                                            .perceivedAnimalActivities,
                                        onChanged: (v) => setState(
                                          () => _perceivedAnimalActivity = v,
                                        ),
                                      ),
                                      if (SightingReportActivityCatalog
                                          .isOtherPerceivedAnimal(
                                        _perceivedAnimalActivity,
                                      )) ...[
                                        const SizedBox(height: 8),
                                        _activityOtherField(
                                          controller:
                                              _perceivedAnimalActivityOtherController,
                                          hint:
                                              'Activiteit van het dier (anders)',
                                        ),
                                      ],
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
=======

                        if (sighting?.reportType != 'verkeersongeval') ...[
  const SizedBox(height: 16),
  Card(
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(
        color: Color(0xFFE8E8E8),
        width: 1,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _infoRow(
            icon: Icons.person,
            title: 'Jouw activiteit',
            value: sighting?.humanActivity ?? 'Onbekend',
          ),
          const SizedBox(height: 14),
          Divider(
            color: Colors.grey.withValues(alpha: 0.15),
            height: 1,
          ),
          const SizedBox(height: 14),
          _infoRow(
            icon: Icons.pets,
            title: 'Activiteit van het dier',
            value: sighting?.perceivedAnimalActivity ?? 'Onbekend',
          ),
        ],
      ),
    ),
  ),
], 
>>>>>>> f1e6c1c (feat: add animal activity input page)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                            color: Color(0xFF999999),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Vorige',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Color(0xFF37A904),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          _isSubmitting
                              ? 'Bezig met versturen...'
                              : 'Versturen',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const SizedBox.shrink(),
    );
  }

<<<<<<< HEAD
  Widget _activityOtherField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF999999)),
        ),
      ),
    );
  }

  Widget _activityDropdown({
    required String label,
=======
  Widget _infoRow({
    required IconData icon,
    required String title,
>>>>>>> f1e6c1c (feat: add animal activity input page)
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.grey[700]),
        ),
<<<<<<< HEAD
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: options.any((o) => o.apiValue == value)
              ? value
              : (options.isNotEmpty
                  ? options.first.apiValue
                  : value),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF999999)),
            ),
          ),
          selectedItemBuilder: (context) => options
              .map(
                (o) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    o.labelNl,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              )
              .toList(),
          items: options
              .map(
                (o) => DropdownMenuItem(
                  value: o.apiValue,
                  child: Text(
                    o.labelNl,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
=======
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
>>>>>>> f1e6c1c (feat: add animal activity input page)
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAnimalDetailsList(
    List? animals,
    int totalCount,
    AnimalModel? templateAnimal,
  ) {
    final details = <Widget>[];

    List effectiveAnimals = animals ?? [];

    if (effectiveAnimals.isEmpty &&
        templateAnimal != null &&
        totalCount > 0) {
      final unknownViewCount = ViewCountModel()..unknownAmount = 1;

      effectiveAnimals = List.generate(
        totalCount,
        (_) => AnimalModel(
          animalId: templateAnimal.animalId,
          animalImagePath: templateAnimal.animalImagePath,
          animalName: templateAnimal.animalName,
          category: templateAnimal.category,
          genderViewCounts: [
            AnimalGenderViewCount(
              gender: AnimalGender.onbekend,
              viewCount: unknownViewCount,
            ),
          ],
          condition: AnimalCondition.onbekend,
        ),
      );
    }

    if (effectiveAnimals.isEmpty) {
      return const [
        Center(
          child: Text(
            'Geen dier details beschikbaar',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ];
    }

    int animalIndex = 1;
    int totalEntries = 0;

    for (final animal in effectiveAnimals) {
      if (animal?.genderViewCounts != null) {
        totalEntries += animal.genderViewCounts.length as int;
      }
    }

    int currentCount = 0;

    for (final animal in effectiveAnimals) {
      if (animal?.genderViewCounts == null ||
          animal.genderViewCounts.isEmpty) {
        continue;
      }

      String conditionLabel = 'Onbekend';

      if (animal.condition != null) {
        switch (animal.condition) {
          case AnimalCondition.gezond:
            conditionLabel = 'Gezond';
            break;
          case AnimalCondition.gewond:
            conditionLabel = 'Gewond';
            break;
          case AnimalCondition.dood:
            conditionLabel = 'Dood';
            break;
          default:
            conditionLabel = 'Onbekend';
        }
      }

      for (final genderViewCount in animal.genderViewCounts) {
        final gender = _getGenderDisplay(genderViewCount.gender);
        final viewCount = genderViewCount.viewCount;

        String age = 'Onbekend';

        if (viewCount.pasGeborenAmount > 0) {
          age = 'Pas geboren';
        } else if (viewCount.onvolwassenAmount > 0) {
          age = 'Jong';
        } else if (viewCount.volwassenAmount > 0) {
          age = 'Volwassen';
        }

        details.add(
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.pets, size: 18, color: Colors.grey[700]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dier $animalIndex',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Conditie: $conditionLabel\nGeslacht: $gender\nLeeftijd: $age',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        currentCount++;

        if (currentCount < totalEntries) {
          details.add(const SizedBox(height: 14));
          details.add(
            Divider(
              color: Colors.grey.withValues(alpha: 0.15),
              height: 1,
            ),
          );
          details.add(const SizedBox(height: 14));
        }

        animalIndex++;
      }
    }

    return details;
  }

  String _getGenderDisplay(AnimalGender gender) {
    switch (gender) {
      case AnimalGender.mannelijk:
        return 'Mannelijk';
      case AnimalGender.vrouwelijk:
        return 'Vrouwelijk';
      case AnimalGender.onbekend:
        return 'Onbekend';
    }
  }

  String _getConditionDisplay(AnimalCondition? condition) {
    switch (condition) {
      case AnimalCondition.gezond:
        return 'Conditie: Gezond';
      case AnimalCondition.gewond:
        return 'Conditie: Gewond';
      case AnimalCondition.dood:
        return 'Conditie: Dood';
      case AnimalCondition.onbekend:
      default:
        return 'Conditie: Onbekend';
    }
  }

  String _getLocationDisplay(List? locations) {
    if (locations?.isEmpty != false) return 'Locatie nog niet ingesteld';

    final loc = locations!.first;

    if (loc.streetName != null && loc.houseNumber != null) {
      return '${loc.streetName} ${loc.houseNumber}, ${loc.cityName ?? ""}';
    } else if (loc.streetName != null) {
      return '${loc.streetName}, ${loc.cityName ?? ""}';
    } else if (loc.cityName != null) {
      return loc.cityName!;
    }

    if (loc.latitude != null && loc.longitude != null) {
      return '${loc.latitude?.toStringAsFixed(2)}, ${loc.longitude?.toStringAsFixed(2)}';
    }

    return 'Locatie nog niet ingesteld';
  }

  String _getDateTimeDisplay(dynamic dateTimeModel) {
    if (dateTimeModel == null) return 'Datum en tijd nog niet ingesteld';

    try {
      final dt = dateTimeModel.dateTime as DateTime?;
      if (dt == null) return 'Datum en tijd nog niet ingesteld';

      final date =
          '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
      final time =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

      return '$date | $time';
    } catch (e) {
      return 'Datum en tijd nog niet ingesteld';
    }
  }
}