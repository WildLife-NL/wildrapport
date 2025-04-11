import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/screens/rapporteren.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/animal_list_table.dart';
import 'package:wildrapport/screens/login_overlay.dart';
import 'package:wildrapport/providers/app_state_provider.dart';

class AnimalListOverviewScreen extends StatefulWidget {
  const AnimalListOverviewScreen({super.key});

  @override
  State<AnimalListOverviewScreen> createState() => _AnimalListOverviewScreenState();
}

class _AnimalListOverviewScreenState extends State<AnimalListOverviewScreen> {
  late final AppStateProvider _appStateProvider;
  late final AnimalSightingReportingInterface _animalSightingManager;

  @override
  void initState() {
    super.initState();
    // Initialize providers in initState to avoid rebuild issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
      _animalSightingManager = Provider.of<AnimalSightingReportingInterface>(context, listen: false);
    });
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Text(
                    'Weet je zeker dat je terug wilt gaan?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brown,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Alle ingevoerde gegevens worden gewist.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          'Annuleren',
                          style: TextStyle(color: AppColors.brown),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkGreen,
                        ),
                        child: const Text(
                          'Bevestigen',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        try {
          // Clear the current animal sighting
          _animalSightingManager.clearCurrentanimalSighting();
          
          // Reset application state
          _appStateProvider.clearCurrentReport();
          
          // Navigate to reporting screen and clear the stack
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const Rapporteren(),
            ),
            (route) => false,
          );
          
          // Reset application state after navigation
          _appStateProvider.resetApplicationState(context);
        } catch (e) {
          debugPrint('Error during confirmation dialog handling: $e');
          // Handle the error appropriately
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final currentSighting = animalSightingManager.getCurrentanimalSighting();
    final hasDescription = currentSighting?.description?.isNotEmpty ?? false;

    return WillPopScope(
      onWillPop: () async {
        _showConfirmationDialog(context);
        return false; // Prevents default back button behavior
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              CustomAppBar(
                leftIcon: Icons.arrow_back_ios,
                centerText: 'Waarneming',
                rightIcon: Icons.menu,
                onLeftIconPressed: () => _showConfirmationDialog(context),
                onRightIconPressed: () {
                  debugPrint('[AnimalListOverviewScreen] Menu button pressed');
                  /* Handle menu */
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Het overzicht',
                        style: TextStyle(
                          color: AppColors.brown,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.25),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Expanded(
                        child: AnimalListTable(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomAppBar(
          onBackPressed: () => _showConfirmationDialog(context),
          onNextPressed: () {
            debugPrint('[AnimalListOverviewScreen] Next button pressed');
            // Handle next action
          },
          showBackButton: false,
          showNextButton: true,
        ),
      ),
    );
  }
}



















