import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/models/animal_sighting_model.dart';
import 'package:wildrapport/screens/animal_condition_screen.dart';
import 'package:wildrapport/screens/animals_screen.dart';
import 'package:wildrapport/widgets/app_bar.dart';

class Rapporteren extends StatefulWidget {
  const Rapporteren({super.key});

  @override
  State<Rapporteren> createState() => _RapporterenState();
}

class _RapporterenState extends State<Rapporteren> {
  String selectedCategory = '';

  void _handleReportTypeSelection(String reportType) {
    setState(() {
      selectedCategory = reportType;
    });
    
    if (reportType == 'animalSightingen') {
      debugPrint('[Rapporteren] Starting animalSighting report creation process');
      debugPrint('[Rapporteren] Selected report type: $reportType');
      
      try {
        // Get the animalSightingReportingInterface instance
        final animalSightingManager = context.read<AnimalSightingReportingInterface>();
        debugPrint('[Rapporteren] Successfully obtained animalSightingReportingInterface');
        
        // Create a new animalSighting model
        final AnimalSightingModel animalSighting = animalSightingManager.createanimalSighting();
        debugPrint('[Rapporteren] Successfully created new animalSightingModel');
        debugPrint('[Rapporteren] animalSightingModel initial state: ${animalSighting.toJson()}');
        
        // Navigate directly to AnimalConditionScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AnimalConditionScreen(),
          ),
        ).then((_) {
          debugPrint('[Rapporteren] Returned from AnimalConditionScreen');
        });
        
        debugPrint('[Rapporteren] Navigation to AnimalConditionScreen initiated');
        
      } catch (e, stackTrace) {
        debugPrint('[Rapporteren] ERROR: Failed to create animalSighting report');
        debugPrint('[Rapporteren] Error details: $e');
        debugPrint('[Rapporteren] Stack trace: $stackTrace');
        
        // Show error dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('Failed to create observation report. Please try again.'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    } else {
      debugPrint('[Rapporteren] Navigating to AnimalsScreen for non-animalSighting report');
      debugPrint('[Rapporteren] Report type: $reportType');
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnimalsScreen(appBarTitle: reportType),
        ),
      );
    }
  }

  void _handleBackNavigation(BuildContext context) {
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    animalSightingManager.clearCurrentanimalSighting();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double verticalPadding = screenSize.height * 0.01;
    final double horizontalPadding = screenSize.width * 0.05;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Rapporteren',
              rightIcon: Icons.menu,
              onLeftIconPressed: () => _handleBackNavigation(context),
              onRightIconPressed: () {},
            ),
            SizedBox(height: screenSize.height * 0.03),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  children: [
                    // First row with two items
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildReportButton(
                              context: context,
                              image: 'assets/icons/rapporteren/crop_icon.png',
                              text: 'Gewasschade',
                              onPressed: () => _handleReportTypeSelection('Gewasschade'),
                            ),
                          ),
                          SizedBox(width: screenSize.width * 0.03),
                          Expanded(
                            child: _buildReportButton(
                              context: context,
                              image: 'assets/icons/rapporteren/health_icon.png',
                              text: 'Diergezondheid',
                              onPressed: () => _handleReportTypeSelection('Diergezondheid'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    // Second row with full-width animalSightingen
                    Expanded(
                      child: _buildReportButton(
                        context: context,
                        image: 'assets/icons/rapporteren/sighting_icon.png',
                        text: 'animalSightingen',
                        onPressed: () => _handleReportTypeSelection('animalSightingen'),
                        isFullWidth: true,
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

  Widget _buildReportButton({
    required BuildContext context,
    required String image,
    required String text,
    required VoidCallback onPressed,
    bool isFullWidth = false,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final double iconSize = screenSize.width * 0.25;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.all(screenSize.width * 0.04),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: iconSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          Image.asset(
                            image,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    Text(
                      text,
                      style: AppTextTheme.textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: isFullWidth 
                ? Alignment.bottomCenter 
                : Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(screenSize.width * 0.04),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.brown,
                  size: screenSize.width * 0.06,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
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
}




















