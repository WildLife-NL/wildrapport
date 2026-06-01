import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/reporting/interaction_interface.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/screens/location/location_screen.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/enums/animal_condition.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_model.dart';
import 'package:wildrapport/screens/questionnaire/questionnaire_screen.dart';
import 'package:wildrapport/screens/shared/main_nav_screen.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/utils/interaction_pin_factory.dart';
import 'package:wildrapport/models/enums/nav_tab.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/models/animal_waarneming_models/view_count_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_gender_view_count_model.dart';
import 'package:wildrapport/constants/sighting_report_activities.dart';

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

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final sightingManager =
          context.read<AnimalSightingReportingInterface>();
      final interactionManager = context.read<InteractionInterface>();
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
            ),
          );
        }

        sighting = sighting.copyWith(
          animals: animalsToAdd,
          animalCount: widget.totalCount,
        );
        sightingManager.updateCurrentanimalSighting(sighting);
      }

      sightingManager.syncObservedAnimalsToSighting();
      final sightingForPin =
          sightingManager.getCurrentanimalSighting() ?? sighting;

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
        sightingForPin,
        response.interactionID,
      );

      await cacheSubmittedInteractionCount(
        interactionId: response.interactionID,
        sighting: sightingForPin,
      );

      if (mapPin != null) {
        context.read<MapProvider>().addOrUpdateInteraction(mapPin);
      }

      sightingManager.clearCurrentanimalSighting();

      if (!mounted) return;

      final questionCount = response.questionnaire.questions?.length ?? 0;
      final Widget targetScreen = questionCount > 0
          ? QuestionnaireScreen(
              questionnaire: response.questionnaire,
              interactionID: response.interactionID,
            )
          : const MainNavScreen(
              initialTab: NavTab.logboek,
              openRecentSightingsDirectly: true,
            );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => targetScreen),
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
                                      width: 140,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(14),
                                          bottomRight: Radius.circular(14),
                                        ),
                                      ),
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
                                      value: _getHumanActivityDisplay(sighting),
                                    ),
                                    const SizedBox(height: 14),
                                    Divider(
                                      color: Colors.grey
                                          .withValues(alpha: 0.15),
                                      height: 1,
                                    ),
                                    const SizedBox(height: 14),
                                    _infoRow(
                                      icon: Icons.pets,
                                      title: 'Activiteit van het dier',
                                      value:
                                          _getPerceivedAnimalActivityDisplay(
                                        sighting,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  children: [
                                    _infoRow(
                                      icon: Icons.trending_down,
                                      title: 'Verwacht verlies',
                                      value: sighting?.expectedLoss ??
                                          'Onbekend',
                                    ),
                                    const SizedBox(height: 14),
                                    Divider(
                                      color: Colors.grey
                                          .withValues(alpha: 0.15),
                                      height: 1,
                                    ),
                                    const SizedBox(height: 14),
                                    _infoRow(
                                      icon: Icons.warning_amber,
                                      title: 'Ernst van het ongeluk',
                                      value: sighting?.accidentSeverity ??
                                          'Onbekend',
                                    ),
                                    const SizedBox(height: 14),
                                    Divider(
                                      color: Colors.grey
                                          .withValues(alpha: 0.15),
                                      height: 1,
                                    ),
                                    const SizedBox(height: 14),
                                    _infoRow(
                                      icon: Icons.pets,
                                      title: 'Toestand dier',
                                      value: sighting
                                              ?.animalConditionDieraanrijding ??
                                          'Onbekend',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
                          backgroundColor: const Color(0xFF37A904),
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

  Widget _infoRow({
    required IconData icon,
    required String title,
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

  String _getHumanActivityDisplay(dynamic sighting) {
    final value = sighting?.humanActivity;
    final other = sighting?.humanActivityOther;

    if (value == null || value.toString().isEmpty) return 'Onbekend';

    if (SightingReportActivityCatalog.isLoaded) {
      final match = SightingReportActivityCatalog.instance.humanActivities
          .where((o) => o.apiValue == value)
          .firstOrNull;

      if (match != null) {
        if (SightingReportActivityCatalog.isOtherHuman(value) &&
            other != null &&
            other.toString().trim().isNotEmpty) {
          return '${match.labelNl}: $other';
        }
        return match.labelNl;
      }
    }

    return value.toString();
  }

  String _getPerceivedAnimalActivityDisplay(dynamic sighting) {
    final value = sighting?.perceivedAnimalActivity;
    final other = sighting?.perceivedAnimalActivityOther;

    if (value == null || value.toString().isEmpty) return 'Onbekend';

    if (SightingReportActivityCatalog.isLoaded) {
      final match = SightingReportActivityCatalog.instance.perceivedAnimalActivities
          .where((o) => o.apiValue == value)
          .firstOrNull;

      if (match != null) {
        if (SightingReportActivityCatalog.isOtherPerceivedAnimal(value) &&
            other != null &&
            other.toString().trim().isNotEmpty) {
          return '${match.labelNl}: $other';
        }
        return match.labelNl;
      }
    }

    return value.toString();
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