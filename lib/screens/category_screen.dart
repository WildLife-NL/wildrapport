import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/waarneming_reporting_interface.dart';
import 'package:wildrapport/models/enums/animal_category.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/selection_button_group.dart';
import 'package:wildrapport/screens/animals_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  void _handleStatusSelection(BuildContext context, String status) {
    debugPrint('[CategoryScreen] Category selected: $status');
    
    final waarnemingManager = context.read<WaarnemingReportingInterface>();
    
    try {
      // Convert string to AnimalCategory enum
      AnimalCategory selectedCategory;
      switch (status.toLowerCase()) {
        case 'evenhoevigen':
          selectedCategory = AnimalCategory.evenhoevigen;
          break;
        case 'knaagdieren':
          selectedCategory = AnimalCategory.knaagdieren;
          break;
        case 'roofdieren':
          selectedCategory = AnimalCategory.roofdieren;
          break;
        default:
          selectedCategory = AnimalCategory.andere;
      }

      debugPrint('[CategoryScreen] Converting status "$status" to category: ${selectedCategory.toString()}');
      
      // Update the waarneming with the selected category using the manager
      final updatedWaarneming = waarnemingManager.updateCategory(selectedCategory);
      debugPrint('[CategoryScreen] Successfully updated category');
      debugPrint('[CategoryScreen] Updated waarneming state: ${updatedWaarneming.toJson()}');
      
      // Navigate to AnimalsScreen with the updated waarneming
      debugPrint('[CategoryScreen] Navigating to AnimalsScreen');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnimalsScreen(
            appBarTitle: 'Waarnemingen',
            waarnemingModel: updatedWaarneming,
          ),
        ),
      );
    } catch (e) {
      debugPrint('[CategoryScreen] Error updating category: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Er is een fout opgetreden bij het bijwerken van de categorie'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleNextPressed(BuildContext context) {
    debugPrint('[CategoryScreen] Next button pressed');
    
    final waarnemingManager = context.read<WaarnemingReportingInterface>();
    final currentWaarneming = waarnemingManager.getCurrentWaarneming();
    
    if (currentWaarneming?.category == null) {
      debugPrint('[CategoryScreen] Attempted to proceed without selecting category');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecteer eerst een categorie'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    debugPrint('[CategoryScreen] Category selected, proceeding to AnimalsScreen');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimalsScreen(
          appBarTitle: 'Waarnemingen',
          waarnemingModel: currentWaarneming,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final waarnemingManager = context.read<WaarnemingReportingInterface>();
    final currentWaarneming = waarnemingManager.getCurrentWaarneming();

    debugPrint('[CategoryScreen] Building screen');
    if (currentWaarneming != null) {
      debugPrint('[CategoryScreen] Current waarneming state: ${currentWaarneming.toJson()}');
    } else {
      debugPrint('[CategoryScreen] No current waarneming found');
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Waarnemingen',
              rightIcon: Icons.menu,
              onLeftIconPressed: () {
                debugPrint('[CategoryScreen] Back button pressed in app bar');
                Navigator.pop(context);
              },
              onRightIconPressed: () {
                debugPrint('[CategoryScreen] Menu button pressed');
                /* Handle menu */
              },
            ),
            SelectionButtonGroup(
              buttons: const [
                (text: 'Evenhoevigen', icon: null, imagePath: 'assets/icons/category/evenhoevigen.png'),
                (text: 'Knaagdieren', icon: null, imagePath: 'assets/icons/category/knaagdieren.png'),
                (text: 'Roofdieren', icon: null, imagePath: 'assets/icons/category/roofdieren.png'),
                (text: 'Andere', icon: Icons.more_horiz, imagePath: null),
              ],
              onStatusSelected: (status) => _handleStatusSelection(context, status),
              title: 'Selecteer Categorie',
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: () {
          debugPrint('[CategoryScreen] Back button pressed in bottom bar');
          Navigator.pop(context);
        },
        onNextPressed: () => _handleNextPressed(context),
      ),
    );
  }
}










