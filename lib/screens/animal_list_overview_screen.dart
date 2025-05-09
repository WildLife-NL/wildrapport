import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/permission_interface.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/screens/animal_counting_screen.dart';
import 'package:wildrapport/screens/location_screen.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/animal_list_table.dart';

class AnimalListOverviewScreen extends StatelessWidget {
  AnimalListOverviewScreen({super.key});

  final _animalListTableKey = GlobalKey<AnimalListTableState>();

  @override
  Widget build(BuildContext context) {
    final animalSightingManager =
        context.read<AnimalSightingReportingInterface>();
    animalSightingManager.getCurrentanimalSighting();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Waarneming',
              rightIcon: Icons.menu,
              onLeftIconPressed: () {
                final navigationManager =
                    context.read<NavigationStateInterface>();
                navigationManager.pushAndRemoveUntil(
                  context,
                  const AnimalCountingScreen(),
                );
              },
              onRightIconPressed: () {
                debugPrint('[AnimalListOverviewScreen] Menu button pressed');
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
                            color: Colors.black.withValues(alpha: 0.25),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: AnimalListTable(key: _animalListTableKey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: () {
          final navigationManager = context.read<NavigationStateInterface>();
          navigationManager.pushAndRemoveUntil(
            context,
            const AnimalCountingScreen(),
          );
        },
        onNextPressed: () async {
          // Save any pending changes before navigation
          _animalListTableKey.currentState?.saveChanges();

          final permissionManager = context.read<PermissionInterface>();
          final navigationManager = context.read<NavigationStateInterface>();
          final animalSightingManager =
              context.read<AnimalSightingReportingInterface>();

          // Get the description from AnimalListTable
          final description =
              _animalListTableKey.currentState?.getDescription() ?? '';
          animalSightingManager.updateDescription(description);

          final currentSighting =
              animalSightingManager.getCurrentanimalSighting();
          debugPrint(
            '[AnimalListOverviewScreen] Current animal sighting state: ${currentSighting?.toJson()}',
          );

          final hasPermission = await permissionManager.isPermissionGranted(
            PermissionType.location,
          );
          debugPrint(
            '[AnimalListOverviewScreen] Location permission status: $hasPermission',
          );

          if (context.mounted) {
            navigationManager.pushReplacementForward(
              context,
              const LocationScreen(),
            );
          }
        },
        showBackButton: true,
        showNextButton: true,
      ),
    );
  }
}
