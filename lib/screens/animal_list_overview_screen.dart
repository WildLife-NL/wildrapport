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
import 'package:wildrapport/interfaces/navigation_state_interface.dart';

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

  void _handleConfirmedNavigation(BuildContext context) {
    try {
      final navigationManager = context.read<NavigationStateInterface>();
      navigationManager.resetToHome(context);
    } catch (e) {
      debugPrint('Error during navigation: $e');
    }
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Waarneming annuleren?'),
          content: const Text('Weet je zeker dat je deze waarneming wilt annuleren?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Nee'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _handleConfirmedNavigation(context);
              },
              child: const Text('Ja'),
            ),
          ],
        );
      },
    );
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






















