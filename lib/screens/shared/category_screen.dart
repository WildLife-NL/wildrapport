import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/screens/shared/rapporteren.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/location/selection_button_group.dart';
import 'package:wildrapport/screens/waarneming/animals_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late final AnimalSightingReportingInterface _animalSightingManager;
  late final NavigationStateInterface _navigationManager;
  bool _isLoading = false;
  final purpleLog = '\x1B[35m';
  final resetLog = '\x1B[0m';

  @override
  void initState() {
    super.initState();
    debugPrint('$purpleLog[CategoryScreen] Initializing screen$resetLog');
    _animalSightingManager = context.read<AnimalSightingReportingInterface>();
    _navigationManager = context.read<NavigationStateInterface>();

    final currentState = _animalSightingManager.getCurrentanimalSighting();
    debugPrint(
      '$purpleLog[CategoryScreen] Initial animal sighting state: ${currentState?.toJson()}$resetLog',
    );
  }

  void _handleBackNavigation() {
    if (!mounted) return;

    // Clear the animal sighting data
    _animalSightingManager.clearCurrentanimalSighting();

    // Get the app state provider and clear the current report
    final appStateProvider = Provider.of<AppStateProvider>(
      context,
      listen: false,
    );
    appStateProvider.resetApplicationState(context);

    // Use the navigation manager's clearApplicationState method which should handle all cleanup
    _navigationManager.clearApplicationState(context);

    // Remove all screens and navigate to Rapporteren
    _navigationManager.pushAndRemoveUntil(context, const Rapporteren());
  }

  void _handleStatusSelection(BuildContext context, String status) {
    if (!mounted) return;
    try {
      setState(() => _isLoading = true);

      final selectedCategory = _animalSightingManager.convertStringToCategory(
        status,
      );
      _animalSightingManager.updateCategory(selectedCategory);

      if (mounted) {
        _navigationManager.dispose(); // Clean up resources
        _navigationManager.pushReplacementForward(
          context,
          const AnimalsScreen(appBarTitle: 'Selecteer Dier'),
        );
      }
    } catch (e) {
      debugPrint(
        '$purpleLog[CategoryScreen] Error updating category: $e$resetLog',
      );
      if (mounted) {
        // Check if still mounted before showing snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Er is een fout opgetreden bij het bijwerken van de categorie',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false); // Hide loading indicator
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                CustomAppBar(
                  leftIcon: Icons.arrow_back_ios,
                  centerText: 'animalSightingen',
                  rightIcon: Icons.menu,
                  onLeftIconPressed: _handleBackNavigation,
                  onRightIconPressed: () {
                    debugPrint(
                      '$purpleLog[CategoryScreen] Menu button pressed$resetLog',
                    );
                  },
                ),
                SelectionButtonGroup(
                  buttons: const [
                    (
                      text: 'Evenhoevigen',
                      icon: null,
                      imagePath: 'assets/icons/category/evenhoevigen.png',
                    ),
                    (
                      text: 'Knaagdieren',
                      icon: null,
                      imagePath: 'assets/icons/category/knaagdieren.png',
                    ),
                    (
                      text: 'Roofdieren',
                      icon: null,
                      imagePath: 'assets/icons/category/roofdieren.png',
                    ),
                    (text: 'Andere', icon: Icons.more_horiz, imagePath: null),
                  ],
                  onStatusSelected:
                      (status) => _handleStatusSelection(context, status),
                  title: 'Selecteer Categorie',
                ),
              ],
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: _handleBackNavigation,
        onNextPressed: () {},
        showNextButton: false,
      ),
    );
  }
}
