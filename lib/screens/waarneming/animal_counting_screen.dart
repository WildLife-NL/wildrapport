import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/screens/waarneming/animal_list_overview_screen.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/bottom_app_bar.dart';
import 'package:wildrapport/models/enums/animal_age.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/enums/animal_condition.dart';
import 'package:wildrapport/models/enums/animal_age_extensions.dart';
import 'package:wildrapport/models/enums/animal_gender_extensions.dart';
import 'package:wildrapport/models/enums/animal_condition_extensions.dart';
import 'package:wildrapport/models/animal_waarneming_models/observed_animal_entry.dart';

class AnimalCountingScreen extends StatefulWidget {
  const AnimalCountingScreen({super.key});

  @override
  State<AnimalCountingScreen> createState() => _AnimalCountingScreenState();
}

class _AnimalCountingScreenState extends State<AnimalCountingScreen> {
  // controls whether "Next" is enabled
  bool _hasAddedItems = false;

  // local selection state for the current line item
  AnimalAge? _selectedAge;
  AnimalGender? _selectedGender;
  AnimalCondition? _selectedCondition;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForExistingAnimals();
    });
  }

  /// If the user already added any animals earlier, unlocks "Next"
  void _checkForExistingAnimals() {
    final animalSightingManager =
        context.read<AnimalSightingReportingInterface>();
    final currentSighting = animalSightingManager.getCurrentanimalSighting();

    // This is legacy logic from your old model: it checks if there are any counts already
    if (currentSighting?.animalSelected != null &&
        currentSighting!.animalSelected!.genderViewCounts.any(
          (gvc) =>
              gvc.viewCount.pasGeborenAmount > 0 ||
              gvc.viewCount.onvolwassenAmount > 0 ||
              gvc.viewCount.volwassenAmount > 0 ||
              gvc.viewCount.unknownAmount > 0,
        )) {
      setState(() {
        _hasAddedItems = true;
      });
    }

    // NOTE: once your manager has `ObservedAnimalEntry` storage,
    // you can ALSO check manager.getObservedAnimals().isNotEmpty here.
  }

  /// Called when the big "Voeg toe aan de lijst" button is pressed.
  /// This creates one ObservedAnimalEntry and stores it in the manager.
  void _handleAddToList() {
    if (_selectedAge == null ||
        _selectedGender == null ||
        _selectedCondition == null ||
        _count <= 0) {
      // user hasn't filled everything
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vul leeftijd, geslacht, conditie en aantal in.'),
        ),
      );
      return;
    }

    final entry = ObservedAnimalEntry(
      age: _selectedAge!,
      gender: _selectedGender!,
      condition: _selectedCondition!,
      count: _count,
    );

    // Save it into the reporting manager so it's part of this waarneming
    context.read<AnimalSightingReportingInterface>().addObservedAnimal(entry);

    // After adding one batch, we:
    // - allow "Next"
    // - reset the picker so the user can add another batch if they want
    setState(() {
      _hasAddedItems = true;

      _selectedAge = null;
      _selectedGender = null;
      _selectedCondition = null;
      _count = 0;
    });
  }

  void _handleBackNavigation(BuildContext context) {
    // Simply go back without popup, keeping all added animals
    Navigator.pop(context);
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Telling toevoegen',
              rightIcon: Icons.menu,
              onLeftIconPressed: () => _handleBackNavigation(context),
              onRightIconPressed: () {},
            ),

            // Scrollable content with the selectors + button
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAgeSelector(),
                    const SizedBox(height: 24),

                    _buildGenderSelector(),
                    const SizedBox(height: 24),

                    _buildConditionSelector(),
                    const SizedBox(height: 24),

                    _buildCountSelector(),
                    const SizedBox(height: 32),

                    // "Voeg toe aan de lijst"
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleAddToList,
                        child: const Text(
                          'Voeg toe aan de lijst',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // bottom bar with BACK + NEXT
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: () => _handleBackNavigation(context),
        onNextPressed: () {
          final navigationManager = context.read<NavigationStateInterface>();
          navigationManager.pushReplacementForward(
            context,
            AnimalListOverviewScreen(),
          );
        },
        showNextButton: _hasAddedItems, // only enabled after first add
      ),
    );
  }
}

// pill UI widget used in selectors
class _PillButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _PillButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: selected ? AppColors.brown : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
