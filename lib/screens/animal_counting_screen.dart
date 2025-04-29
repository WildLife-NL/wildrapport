import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/models/animal_gender_view_count_model.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/view_count_model.dart';
import 'package:wildrapport/screens/animal_condition_screen.dart';
import 'package:wildrapport/screens/animal_list_overview_screen.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/animal_counting.dart';
import 'package:wildrapport/widgets/animal_list_table.dart';

class AnimalCountingScreen extends StatefulWidget {
  const AnimalCountingScreen({super.key});

  @override
  State<AnimalCountingScreen> createState() => _AnimalCountingScreenState();
}

class _AnimalCountingScreenState extends State<AnimalCountingScreen> {
  bool _hasAddedItems = false;

  bool _areAllCategoriesComplete(BuildContext context) {
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final currentSighting = animalSightingManager.getCurrentanimalSighting();
    if (currentSighting?.animalSelected == null) return false;

    final genders = [AnimalGender.mannelijk, AnimalGender.vrouwelijk, AnimalGender.onbekend];
    
    for (var gender in genders) {
      final genderVC = currentSighting!.animalSelected!.genderViewCounts.firstWhere(
        (gvc) => gvc.gender == gender,
        orElse: () => AnimalGenderViewCount(gender: gender, viewCount: ViewCountModel()),
      );

      // Check if all age categories for this gender have counts
      if (genderVC.viewCount.pasGeborenAmount <= 0 ||
          genderVC.viewCount.onvolwassenAmount <= 0 ||
          genderVC.viewCount.volwassenAmount <= 0 ||
          genderVC.viewCount.unknownAmount <= 0) {
        return false;
      }
    }
    
    return true;
  }

  void _handleBackNavigation(BuildContext context) {
    final navigationManager = context.read<NavigationStateInterface>();
    navigationManager.pushReplacementBack(
      context,
      const AnimalConditionScreen(),
    );
  }

  void _handleAgeSelected(String age) {
    debugPrint('[AnimalCountingScreen] Selected age: $age');
  }

  void _handleAddToList(BuildContext context) {
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final currentSighting = animalSightingManager.getCurrentanimalSighting();
    if (currentSighting != null) {
      // Enable the next button as soon as we have at least one item
      setState(() {
        _hasAddedItems = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          leftIcon: Icons.arrow_back_ios,
          centerText: 'Telling toevoegen',
          rightIcon: Icons.menu,
          onLeftIconPressed: () => _handleBackNavigation(context),
          onRightIconPressed: () {},
        ),
      ),
      body: Center(
        child: AnimalCounting(
          onAddToList: () => _handleAddToList(context),
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: () => _handleBackNavigation(context),
        onNextPressed: () {
          final navigationManager = context.read<NavigationStateInterface>();
          navigationManager.pushReplacementForward(
            context,
            AnimalListOverviewScreen(),  // Removed 'const'
          );
        },
        showNextButton: _hasAddedItems,
      ),
    );
  }
}









