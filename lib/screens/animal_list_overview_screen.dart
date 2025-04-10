import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/animal_list_table.dart';

class AnimalListOverviewScreen extends StatelessWidget {
  const AnimalListOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final currentSighting = animalSightingManager.getCurrentanimalSighting();
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Waarneming',  // Updated app bar title
              rightIcon: Icons.menu,
              onLeftIconPressed: () {
                debugPrint('[AnimalListOverviewScreen] Back button pressed');
                Navigator.pop(context);
              },
              onRightIconPressed: () {
                debugPrint('[AnimalListOverviewScreen] Menu button pressed');
                /* Handle menu */
              },
            ),
            Expanded(
              child: SingleChildScrollView(
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
                    const AnimalListTable(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: () {
          debugPrint('[AnimalListOverviewScreen] Bottom back button pressed');
          Navigator.pop(context);
        },
        onNextPressed: () {
          debugPrint('[AnimalListOverviewScreen] Next button pressed');
          // Handle next action
        },
        showBackButton: false,
        showNextButton: true,
      ),
    );
  }
}



