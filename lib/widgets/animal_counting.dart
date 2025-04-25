import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/widgets/counter_widget.dart';
import 'package:wildrapport/widgets/white_bulk_button.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/widgets/count_bar.dart';
import 'package:wildrapport/widgets/validation_overlay.dart';

class AnimalCounting extends StatefulWidget {
  final Function(String)? onAgeSelected;
  final VoidCallback? onAddToList;

  const AnimalCounting({
    super.key,
    this.onAgeSelected,
    this.onAddToList,
  });

  @override
  State<AnimalCounting> createState() => _AnimalCountingState();
}

class _AnimalCountingState extends State<AnimalCounting> {
  String? selectedAge;
  String? selectedGender;
  int currentCount = 0;

  @override
  void initState() {
    super.initState();
    _logCurrentAnimalSighting();
  }

  void _logCurrentAnimalSighting() {
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final currentSighting = animalSightingManager.getCurrentanimalSighting();
    
    debugPrint('[AnimalCounting] Current animal sighting:');
    debugPrint('[AnimalCounting] Selected animal: ${currentSighting?.animalSelected?.animalName}');
    debugPrint('[AnimalCounting] Animal ID: ${currentSighting?.animalSelected?.animalId}');
    debugPrint('[AnimalCounting] Category: ${currentSighting?.category}');
    debugPrint('[AnimalCounting] Description: ${currentSighting?.description}');
    debugPrint('[AnimalCounting] Location: ${currentSighting?.location?.toJson()}');
    debugPrint('[AnimalCounting] DateTime: ${currentSighting?.dateTime?.toJson()}');
    debugPrint('[AnimalCounting] Full state: ${currentSighting?.toJson()}');
  }

  void _handleCountChanged(String name, int count) {
    setState(() {
      currentCount = count;
    });
    debugPrint('[AnimalCounting] Count changed to: $count');
  }

  void _validateAndAddToList(BuildContext context) {
    debugPrint('[AnimalCounting] Validating before adding to list');
    List<String> errors = [];

    if (selectedAge == null) {
      errors.add('Selecteer een leeftijd');
    }

    if (selectedGender == null) {
      errors.add('Selecteer een geslacht');
    }

    if (currentCount <= 0) {
      errors.add('Voer een aantal groter dan 0 in');
    }

    if (errors.isNotEmpty) {
      debugPrint('[AnimalCounting] Validation failed: ${errors.join(", ")}');
      showDialog(
        context: context,
        builder: (context) => ValidationOverlay(messages: errors),
      );
      return;
    }

    debugPrint('[AnimalCounting] Validation successful, adding to list');
    widget.onAddToList?.call();
    _logCurrentAnimalSighting();
  }

  void _handleAgeSelection(String age) {
    debugPrint('[AnimalCounting] Selected age: $age');
    setState(() {
      if (selectedAge == age) {
        selectedAge = null; // Deselect if already selected
      } else {
        selectedAge = age;
      }
    });
    widget.onAgeSelected?.call(age);
    _logCurrentAnimalSighting();
  }

  void _handleGenderSelection(String gender) {
    debugPrint('[AnimalCounting] Selected gender: $gender');
    setState(() {
      if (selectedGender == gender) {
        selectedGender = null; // Deselect if already selected
      } else {
        selectedGender = gender;
      }
    });
    _logCurrentAnimalSighting();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24), // Added horizontal padding
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader('Leeftijd'),
                          _buildAgeButton(
                            "Onbekend",
                            icon: Icons.cancel_outlined,
                          ),
                          const SizedBox(height: 8),
                          _buildAgeButton("<6 maanden"),
                          const SizedBox(height: 8),
                          _buildAgeButton("Onvolwassen"),
                          const SizedBox(height: 8),
                          _buildAgeButton("Volwassen"),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader('Geslacht'),
                          _buildGenderButton(
                            "Onbekend",
                            icon: Icons.cancel_outlined,
                          ),
                          const SizedBox(height: 8),
                          _buildGenderButton(
                            "Mannelijk",
                            icon: Icons.male,
                            tintColor: AppColors.brown,
                          ),
                          const SizedBox(height: 8),
                          _buildGenderButton(
                            "Vrouwelijk",
                            icon: Icons.female,
                            tintColor: AppColors.brown,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24), // Updated padding
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader('Aantal'),
                  const SizedBox(height: 8),
                  AnimalCounter(
                    name: "Example",
                    height: 49,
                    onCountChanged: _handleCountChanged,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 350,
                    child: WhiteBulkButton(
                      text: "Voeg toe aan de lijst",
                      showIcon: false,
                      height: 85,
                      onPressed: () => _validateAndAddToList(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.brown,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeButton(String text, {IconData? icon, Color? tintColor}) {
    final bool isSelected = text == selectedAge;
    
    Widget? leftWidget;
    if (icon != null) {
      leftWidget = Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Icon(
          icon,
          size: 36,
          color: tintColor ?? AppColors.brown,
        ),
      );
    }

    return WhiteBulkButton(
      text: text,
      height: 64.5,
      showIcon: false,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      textAlign: icon != null ? TextAlign.left : TextAlign.center,
      leftWidget: leftWidget,
      backgroundColor: isSelected ? AppColors.lightGreen : null,
      onPressed: () => _handleAgeSelection(text),
    );
  }

  Widget _buildGenderButton(String text, {IconData? icon, Color? tintColor}) {
    final bool isSelected = text == selectedGender;
    
    Widget? leftWidget;
    if (icon != null) {
      leftWidget = Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Icon(
          icon,
          size: 36,
          color: tintColor ?? AppColors.brown,
        ),
      );
    }

    return WhiteBulkButton(
      text: text,
      height: 64.5,
      showIcon: false,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      textAlign: icon != null ? TextAlign.left : TextAlign.center,
      leftWidget: leftWidget,
      backgroundColor: isSelected ? AppColors.lightGreen : null,
      onPressed: () => _handleGenderSelection(text),
    );
  }
}





























