import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/screens/shared/main_nav_screen.dart';
import 'package:wildrapport/models/enums/nav_tab.dart';
import 'package:wildrapport/providers/submitted_sightings_provider.dart';
import 'package:wildrapport/constants/app_colors.dart';

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


  void _onSubmitPressed() {
    final sightingManager = context.read<AnimalSightingReportingInterface>();
    final submittedProvider = context.read<SubmittedSightingsProvider>();

    try {
      // Get the current sighting data from provider
      var sighting = sightingManager.getCurrentanimalSighting();
      
      if (sighting != null) {
        // Save to submitted sightings
        submittedProvider.addSighting(sighting);
        
        debugPrint('[SchademeldingSummary] Schademelding: ${sighting.reportType}, Gewas: ${sighting.cropType}');
        
        // Clear the current sighting
        sightingManager.clearCurrentanimalSighting();
        
        debugPrint('[SchademeldingSummary] Schademelding saved and navigating to logbook');
        
        // Navigate to logbook with recent sightings shown directly
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainNavScreen(
              initialTab: NavTab.logboek,
              openRecentSightingsDirectly: true,
            ),
          ),
          (route) => false,
        );
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

  String? _getCropImagePath(String cropType) {
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
      case 'runderen':
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
        return null;
        //Eigendom
      case 'eigendom':
      return 'assets/images/property.jpg';
      default:
        return null;
      
      
    }
  }

  Widget _buildCropTypeImage(String cropType) {
    final imagePath = _getCropImagePath(cropType);

    if (imagePath == null) {
      return Container(
        height: 120,
        width: double.infinity,
        color: const Color(0xFFECECEC),
        child: const Center(
          child: Icon(
            Icons.pets,
            size: 42,
            color: Color(0xFF7A7A7A),
          ),
        ),
      );
    }

    return Image.asset(
      imagePath,
      height: 120,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 120,
          color: const Color(0xFFECECEC),
          child: const Center(
            child: Icon(
              Icons.pets,
              size: 42,
              color: Color(0xFF7A7A7A),
            ),
          ),
        );
      },
    );
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
              textColor: AppColors.textPrimary,
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
                                            child: _buildCropTypeImage(
                                              currentSighting?.cropType ?? 'Onbekend',
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
                                                    color: AppColors.textPrimary
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
                                  // Date and Time
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0F0F0),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.calendar_today, size: 18, color: Colors.grey[700]),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Datum & Tijd',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              currentSighting?.dateTime?.dateTime != null
                                                  ? '${currentSighting!.dateTime!.dateTime!.toLocal().year}-${currentSighting!.dateTime!.dateTime!.toLocal().month.toString().padLeft(2, '0')}-${currentSighting!.dateTime!.dateTime!.toLocal().day.toString().padLeft(2, '0')} ${currentSighting!.dateTime!.dateTime!.toLocal().hour.toString().padLeft(2, '0')}:${currentSighting!.dateTime!.dateTime!.toLocal().minute.toString().padLeft(2, '0')}'
                                                  : 'Onbekend',
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
                                  // Geschat verlies
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
                                              'Geschat verlies',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              currentSighting?.expectedLoss ?? 'Onbekend',
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
                                  // Preventieve maatregelen
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0F0F0),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.shield, size: 18, color: Colors.grey[700]),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Preventieve maatregelen',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              (currentSighting?.preventiveMeasures ?? false) ? 'Ja' : 'Nee',
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

                          if ((currentSighting?.additionalInfo ?? '').isNotEmpty) ...[
                            const SizedBox(height: 24),
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
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(minHeight: 120),
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
                                            child: Icon(Icons.note, size: 18, color: Colors.grey[700]),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Aanvullende informatie',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  '"${currentSighting?.additionalInfo ?? ''}"',
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                    fontStyle: FontStyle.italic,
                                                    fontFamily: 'monospace',
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