import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/reporting/belonging_damage_report_interface.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/models/enums/location_source.dart';
import 'package:wildrapport/models/beta_models/report_location_model.dart';
import 'package:wildrapport/providers/belonging_damage_report_provider.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/screens/shared/main_nav_screen.dart';
import 'package:wildrapport/models/enums/nav_tab.dart';
import 'package:wildrapport/providers/submitted_sightings_provider.dart';

class SchademeldingSummaryScreen extends StatefulWidget {
  const SchademeldingSummaryScreen({
    super.key,
  });

  @override
  State<SchademeldingSummaryScreen> createState() =>
      _SchademeldingSummaryScreenState();
}

class _SchademeldingSummaryScreenState
    extends State<SchademeldingSummaryScreen> {
  String _toApiEstimatedLossBucket(String? uiExpectedLoss) {
    final raw = (uiExpectedLoss ?? '').trim().toLowerCase();
    switch (raw) {
      case 'onbekend':
      case 'unknown':
      case '':
        return 'unknown';
      case '€0 - €250':
      case '0-250':
      case '€0-€250':
        return '0-250';
      case '€250 - €500':
      case '250-500':
      case '€250-€500':
        return '250-500';
      case '€500 - €1000':
      case '500-1000':
      case '€500-€1000':
        return '500-1000';
      case '€1000 - €2000':
      case '1000-2000':
      case '€1000-€2000':
        return '1000-2000';
      case '€2000 - €5000':
      case '2000-5000':
      case '€2000-€5000':
        return '2000-5000';
      case '€5000 +':
      case '5000+':
      case '€5000+':
        return '5000+';
      default:
        return 'unknown';
    }
  }

  double _parseLossToAmount(String? expectedLoss) {
    if (expectedLoss == null || expectedLoss.trim().isEmpty) return 0;
    final normalized = expectedLoss.replaceAll('.', '').replaceAll(',', '.');
    final matches = RegExp(r'\d+(\.\d+)?').allMatches(normalized).toList();
    if (matches.isEmpty) return 0;
    final last = matches.last.group(0);
    return double.tryParse(last ?? '') ?? 0;
  }

  void _syncSightingToBelongingProvider({
    required dynamic sighting,
    required BelongingDamageReportProvider damageProvider,
  }) {
    final cropFromSighting = (sighting.cropType ?? '').toString().trim();
    final existingCrop = damageProvider.impactedCrop.trim();
    final fallbackCrop = (cropFromSighting.isNotEmpty)
        ? cropFromSighting
        : (existingCrop.isNotEmpty ? existingCrop : 'Onbekend');
    if (cropFromSighting.isEmpty) {
      debugPrint(
        '[SchademeldingSubmit][WARN] sighting.cropType is empty; '
        'using fallback impactedCrop="$fallbackCrop"',
      );
    }
    damageProvider.setImpactedCrop(fallbackCrop);
    damageProvider.setDescription((sighting.additionalInfo ?? '').toString());
    damageProvider.setEstimatedLoss(_parseLossToAmount(sighting.expectedLoss));
    damageProvider.setEstimatedLossBucket(
      _toApiEstimatedLossBucket(sighting.expectedLoss),
    );
    damageProvider.setPreventiveMeasures(sighting.preventiveMeasures ?? false);
    damageProvider.setPreventiveMeasuresDescription(
      (sighting.additionalInfo ?? '').toString(),
    );
    // Keep current damage deterministic for backend if not collected explicitly.
    damageProvider.setEstimatedDamage(0);
    if (sighting.animalSelected?.animalId != null) {
      damageProvider.setSuspectedAnimal(sighting.animalSelected!.animalId!);
    }

    // Ensure impact type/value exist so buildBelongingReport can pass validation.
    final isLivestock = [
      'rund',
      'schaap',
      'geit',
      'paard',
      'pluimvee',
      'vark',
      'ree',
      'ander',
    ].contains((sighting.cropType ?? '').toString().toLowerCase());
    if (isLivestock) {
      damageProvider.setDamageCategory('livestock');
      damageProvider.setLivestockAmount(1);
    } else {
      damageProvider.setDamageCategory('crops');
      if (damageProvider.impactedArea == null || damageProvider.impactedArea! <= 0) {
        damageProvider.setImpactedAreaType('vierkante meters');
        damageProvider.setImpactedArea(1);
      }
    }

    final locations = sighting.locations ?? [];
    for (final loc in locations) {
      final reportLoc = ReportLocation(
        latitude: loc.latitude,
        longtitude: loc.longitude,
      );
      if (loc.source == LocationSource.system) {
        damageProvider.setSystemLocation(reportLoc);
      } else if (loc.source == LocationSource.manual) {
        damageProvider.setUserLocation(reportLoc);
      }
    }
  }

  void _debugDumpBeforeSubmit({
    required dynamic sighting,
    required BelongingDamageReportProvider damageProvider,
  }) {
    debugPrint('[SchademeldingSubmit][DEBUG] ===== START SUBMIT DEBUG =====');
    debugPrint(
      '[SchademeldingSubmit][DEBUG] sighting null: ${sighting == null}',
    );
    if (sighting != null) {
      try {
        final sightingJson = sighting.toJson();
        debugPrint(
          '[SchademeldingSubmit][DEBUG] sighting payload:\n${const JsonEncoder.withIndent('  ').convert(sightingJson)}',
        );
      } catch (_) {
        debugPrint(
          '[SchademeldingSubmit][DEBUG] sighting.toJson() unavailable; '
          'reportType=${sighting.reportType}, cropType=${sighting.cropType}, '
          'animal=${sighting.animalSelected?.animalName}',
        );
      }
    }
    debugPrint(
      '[SchademeldingSubmit][DEBUG] damageProvider state: '
      'category=${damageProvider.damageCategory}, '
      'impactedCrop="${damageProvider.impactedCrop}", '
      'impactedArea=${damageProvider.impactedArea}, '
      'impactedAreaType=${damageProvider.impactedAreaType}, '
      'apiImpactType=${damageProvider.apiImpactType}, '
      'apiImpactValue=${damageProvider.apiImpactValueOrNull}, '
      'suspectedSpeciesID=${damageProvider.suspectedSpeciesID}',
    );
    debugPrint(
      '[SchademeldingSubmit][DEBUG] NOTE: This screen posts via '
      'BelongingDamageReportManager.postInteraction().',
    );
    debugPrint('[SchademeldingSubmit][DEBUG] ===== END SUBMIT DEBUG =====');
  }

  void _onSubmitPressed() {
    final sightingManager = context.read<AnimalSightingReportingInterface>();
    final submittedProvider = context.read<SubmittedSightingsProvider>();
    final damageProvider = context.read<BelongingDamageReportProvider>();
    final belongingManager = context.read<BelongingDamageReportInterface>();

    try {
      // Get the current sighting data from provider
      var sighting = sightingManager.getCurrentanimalSighting();

      _debugDumpBeforeSubmit(
        sighting: sighting,
        damageProvider: damageProvider,
      );

      if (sighting != null) {
        _syncSightingToBelongingProvider(
          sighting: sighting,
          damageProvider: damageProvider,
        );

        debugPrint('[SchademeldingSubmit] Posting interaction to backend...');
        belongingManager.postInteraction().then((response) {
          if (!mounted) return;
          if (response == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Schademelding kon niet worden verstuurd. Probeer opnieuw.'),
              ),
            );
            return;
          }

          // Save to submitted sightings as local history mirror.
          submittedProvider.addSighting(sighting);

          debugPrint('[SchademeldingSubmit] Backend submit successful. interactionID=${response.interactionID}');
          sightingManager.clearCurrentanimalSighting();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const MainNavScreen(
                initialTab: NavTab.logboek,
                openRecentSightingsDirectly: true,
              ),
            ),
            (route) => false,
          );
        }).catchError((e, stackTrace) {
          debugPrint('[SchademeldingSubmit] Backend submit failed: $e');
          debugPrint('[SchademeldingSubmit] Stack trace: $stackTrace');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fout bij versturen: $e')),
          );
        });
        return;
      }
    } catch (e, stackTrace) {
      debugPrint('[SchademeldingSummary] Error submitting: $e');
      debugPrint('[SchademeldingSummary] Stack trace: $stackTrace');
    }
  }

  void _onEditPressed() {
    debugPrint('[SchademeldingSummary] Navigate to previous page');
    
    // Navigate back to previous page
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
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

  String _getCropImagePath(String cropType) {
    switch (cropType.toLowerCase()) {
      // Gewas types
      case 'maïs':
      case 'mais':
        return 'assets/images/gewas/mais.jpg';
      case 'granen':
        return 'assets/images/gewas/granen.jpg';
      case 'groente':
        return 'assets/images/gewas/groente.jpg';
      case 'fruit':
        return 'assets/images/gewas/fruit.jpg';
      case 'grasland':
        return 'assets/images/gewas/grasland.jpg';
      case 'tuin':
        return 'assets/images/gewas/tuin.jpg';
      // Vee types
      case 'rund':
        return 'assets/images/vee/rund.png';
      case 'schaap':
        return 'assets/images/vee/schaap.png';
      case 'geit':
        return 'assets/images/vee/geit.png';
      case 'paard':
        return 'assets/images/vee/paard.png';
      case 'pluimvee':
        return 'assets/images/vee/pluimvee.png';
      case 'vark':
        return 'assets/images/vee/vark.png';
      case 'ree':
        return 'assets/images/vee/ree.png';
      case 'ander':
        return 'assets/images/vee/rund.png'; // Default to rund for "ander"
      default:
        return 'assets/images/gewas/mais.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sightingManager = context.read<AnimalSightingReportingInterface>();
    final currentSighting = sightingManager.getCurrentanimalSighting();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F4),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: null,
              centerText: 'Schademelding',
              rightIcon: Icons.exit_to_app_rounded,
              onRightIconPressed: _handleExit,
              showUserIcon: false,
              useFixedText: true,
              iconColor: Colors.grey,
              textColor: Colors.black,
              fontScale: 1.4,
              iconScale: 0.85,
              userIconScale: 1.15,
            ),
            const SizedBox(height: 8),

            // Main card container
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: const Color(0xFF999999),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              'Jouw schademelding overzicht',
                              textAlign: TextAlign.center,
                              style:
                                  Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Two column layout for crop and animal
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Beschadigd (Damaged Crop)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Beschadigd:',
                                      textAlign: TextAlign.left,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black87,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                            child: Image.asset(
                                              _getCropImagePath(currentSighting?.cropType ?? 'Onbekend'),
                                              height: 120,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  height: 120,
                                                  color: Colors.grey[200],
                                                  child: const Center(
                                                    child: Icon(Icons.image),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                top: BorderSide(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.2),
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              currentSighting?.cropType ?? 'Onbekend',
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Verdachte (Suspect Animal)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Verdachte:',
                                      textAlign: TextAlign.left,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black87,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                            child: currentSighting?.animalSelected
                                                        ?.animalImagePath !=
                                                    null
                                                ? _buildAnimalImage(
                                                    currentSighting!
                                                        .animalSelected!
                                                        .animalImagePath!,
                                                  )
                                                : Container(
                                                    height: 120,
                                                    color: Colors.grey[200],
                                                    child: const Center(
                                                      child: Icon(Icons.image),
                                                    ),
                                                  ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                top: BorderSide(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.2),
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              currentSighting?.animalSelected
                                                      ?.animalName ??
                                                  'Onbekend',
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Details Section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F6F4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date and Time
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Datum & Tijd:',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      (() {
                                        final dt = currentSighting?.dateTime?.dateTime;
                                        if (dt == null) return 'Onbekend';
                                        final local = dt.toLocal();
                                        return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
                                      })(),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(
                                    color: Colors.grey.withValues(alpha: 0.2),
                                    height: 1,
                                  ),
                                ),
                                // Geschat verlies
                                Row(
                                  children: [
                                    Icon(Icons.trending_down, size: 18, color: Colors.grey[600]),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Geschat verlies:',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      currentSighting?.expectedLoss ?? 'Onbekend',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(
                                    color: Colors.grey.withValues(alpha: 0.2),
                                    height: 1,
                                  ),
                                ),
                                // Preventieve maatregelen
                                Row(
                                  children: [
                                    Icon(Icons.shield, size: 18, color: Colors.grey[600]),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Preventieve maatregelen:',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      (currentSighting?.preventiveMeasures ?? false) ? 'Ja' : 'Nee',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          if ((currentSighting?.additionalInfo ?? '').isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F6F4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Aanvullende informatie:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF7A7A7A),
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      '"${currentSighting?.additionalInfo ?? ''}"',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                    ?.copyWith(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                                ],
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

            // Bottom buttons
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _onEditPressed,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                            color: Color.fromARGB(59, 0, 0, 0),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
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
                        onPressed: _onSubmitPressed,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF37A904),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Versturen',
                          style: TextStyle(
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
    );
  }

  Widget _buildAnimalImage(String imagePath) {
    // Check if it's a network URL or asset path
    final isNetworkUrl =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    final placeholder = Container(
      height: 120,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image),
      ),
    );

    if (isNetworkUrl) {
      return Image.network(
        imagePath,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholder,
      );
    } else {
      // It's an asset path - try to load it
      try {
        return Image.asset(
          imagePath,
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => placeholder,
        );
      } catch (e) {
        // If asset loading fails, show placeholder
        return placeholder;
      }
    }
  }}