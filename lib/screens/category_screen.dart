import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/waarneming_reporting_interface.dart';
import 'package:wildrapport/models/enums/animal_category.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/selection_button_group.dart';
import 'package:wildrapport/models/waarneming_model.dart';
import 'package:wildrapport/screens/animals_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  void _handleStatusSelection(BuildContext context, String status) {
    debugPrint('[CategoryScreen] Category selected: $status');
    
    final waarnemingManager = context.read<WaarnemingReportingInterface>();
    final currentWaarneming = waarnemingManager.getCurrentWaarneming();
    
    if (currentWaarneming == null) {
      debugPrint('[CategoryScreen] ERROR: No waarneming model found when handling category selection');
      return;
    }

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

    debugPrint('[CategoryScreen] Updating category to: ${selectedCategory.toString()}');
    final updatedWaarneming = WaarnemingModel(
      animals: currentWaarneming.animals,
      condition: currentWaarneming.condition,
      category: selectedCategory,
      gender: currentWaarneming.gender,
      age: currentWaarneming.age,
      description: currentWaarneming.description,
      location: currentWaarneming.location,
      dateTime: currentWaarneming.dateTime,
      images: currentWaarneming.images,
    );
    
    // Convert to JSON and highlight changes
    final oldJson = currentWaarneming.toJson();
    final newJson = updatedWaarneming.toJson();
    final greenStart = '\x1B[32m';
    final colorEnd = '\x1B[0m';
    
    final prettyJson = newJson.map((key, value) {
      final oldValue = oldJson[key];
      final isChanged = oldValue != value;
      final prettyValue = isChanged ? '$greenStart$value$colorEnd' : value;
      return MapEntry(key, prettyValue);
    });
    
    debugPrint('[CategoryScreen] Waarneming state after update: $prettyJson');
    
    // Navigate to AnimalsScreen
    debugPrint('[CategoryScreen] Navigating to AnimalsScreen');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimalsScreen(
          appBarTitle: 'Dieren',
          waarnemingModel: updatedWaarneming,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final waarnemingManager = context.read<WaarnemingReportingInterface>();
    final currentWaarneming = waarnemingManager.getCurrentWaarneming();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Categorie',
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
        onNextPressed: () {
          debugPrint('[CategoryScreen] Next button pressed in bottom bar');
          
          // Check if a category has been selected
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
          
          // TODO: Navigate to next screen if category is selected
        },
      ),
    );
  }
}




