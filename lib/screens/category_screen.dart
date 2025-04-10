import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/models/enums/animal_category.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/selection_button_group.dart';
import 'package:wildrapport/screens/animals_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late final AnimalSightingReportingInterface _animalSightingManager;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[CategoryScreen] Initializing screen');
    _animalSightingManager = context.read<AnimalSightingReportingInterface>();
    _validateanimalSighting();
  }

  void _validateanimalSighting() {
    final currentanimalSighting = _animalSightingManager.getCurrentanimalSighting();
    if (currentanimalSighting == null) {
      debugPrint('[CategoryScreen] No active animalSighting found');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geen actieve animalSighting gevonden'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  void _handleStatusSelection(BuildContext context, String status) {
    setState(() => _isLoading = true);
    
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

      debugPrint('[CategoryScreen] Updating category to: $selectedCategory');
      _animalSightingManager.updateCategory(selectedCategory);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AnimalsScreen(
            appBarTitle: 'Selecteer Dier',
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleNextPressed(BuildContext context) {
    debugPrint('[CategoryScreen] Next button pressed');
    
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final currentanimalSighting = animalSightingManager.getCurrentanimalSighting();
    
    if (currentanimalSighting?.category == null) {
      debugPrint('[CategoryScreen] Attempted to proceed without selecting category');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecteer eerst een categorie')),
      );
      return;
    }
    
    debugPrint('[CategoryScreen] Category selected, proceeding to AnimalsScreen');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimalsScreen(
          appBarTitle: 'animalSightingen',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Remove animalSighting logging from build method
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
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
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



















