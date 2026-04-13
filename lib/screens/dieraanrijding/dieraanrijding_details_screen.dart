import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/screens/waarneming/animal_waarneming_summary_screen.dart';
import 'package:wildrapport/constants/design_system.dart';

class DieraanrijdingDetailsScreen extends StatefulWidget {
  final int totalCount;

  const DieraanrijdingDetailsScreen({
    super.key,
    required this.totalCount,
  });

  @override
  State<DieraanrijdingDetailsScreen> createState() =>
      _DieraanrijdingDetailsScreenState();
}

class _DieraanrijdingDetailsScreenState extends State<DieraanrijdingDetailsScreen> {
  String? _selectedExpectedLoss;
  String? _selectedAccidentSeverity;
  String? _selectedAnimalCondition;

  @override
  void initState() {
    super.initState();
    // Load existing data if it was previously saved
    final sightingManager = context.read<AnimalSightingReportingInterface>();
    final sighting = sightingManager.getCurrentanimalSighting();
    
    _selectedExpectedLoss = sighting?.expectedLoss;
    _selectedAccidentSeverity = sighting?.accidentSeverity;
    _selectedAnimalCondition = sighting?.animalConditionDieraanrijding;
  }

  void _saveDieraanrijdingDetails() {
    final sightingManager = context.read<AnimalSightingReportingInterface>();
    final sighting = sightingManager.getCurrentanimalSighting();
    
    if (sighting != null) {
      sightingManager.updateCurrentanimalSighting(
        sighting.copyWith(
          expectedLoss: _selectedExpectedLoss,
          accidentSeverity: _selectedAccidentSeverity,
          animalConditionDieraanrijding: _selectedAnimalCondition,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sightingManager = context.read<AnimalSightingReportingInterface>();
    final sighting = sightingManager.getCurrentanimalSighting();
    final selectedAnimal = sighting?.animalSelected;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F4),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App Bar
            CustomAppBar(
              centerText: 'Dieraanrijding',
              rightIcon: null,
              showUserIcon: false,
              useFixedText: true,
              onLeftIconPressed: () {
                _saveDieraanrijdingDetails();
                Navigator.pop(context);
              },
              textColor: Colors.black,
              fontScale: 1.4,
              iconScale: 1.15,
              userIconScale: 1.15,
            ),
            const SizedBox(height: 16),
            // Main card container
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: const Color(0xFF999999),
                      width: 1,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Selected animal card with green outline
                          if (selectedAnimal != null)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: SizedBox(
                                  width: 160,
                                  child: Card(
                                    elevation: 4,
                                    shadowColor: Colors.black.withValues(alpha: 0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: const BorderSide(
                                        color: Color(0xFF999999),
                                        width: 2,
                                      ),
                                    ),
                                    color: const Color(0xFFF5F6F4),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Image area
                                        Container(
                                          width: 160,
                                          height: 130,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(14),
                                              topRight: Radius.circular(14),
                                            ),
                                            color: Color(0xFFE6DCCD),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(14),
                                              topRight: Radius.circular(14),
                                            ),
                                            child: selectedAnimal.animalImagePath != null
                                                ? Image(
                                                    image: AssetImage(selectedAnimal.animalImagePath!),
                                                    fit: BoxFit.cover,
                                                  )
                                                : Center(
                                                    child: Icon(
                                                      Icons.image_not_supported_outlined,
                                                      size: 50,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        // Divider line
                                        Container(
                                          height: 1,
                                          color: const Color(0xFF999999),
                                          width: 160,
                                        ),
                                        // Name area
                                        Container(
                                          width: 160,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF5F6F4),
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(14),
                                              bottomRight: Radius.circular(14),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 12,
                                          ),
                                          child: Text(
                                            selectedAnimal.animalName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Expected loss question
                          Text(
                            'Wat is het verwachte verlies als gevolg van de schade?',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.15),
                                width: 1.2,
                              ),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedExpectedLoss,
                              isExpanded: true,
                              underline: const SizedBox(),
                              borderRadius: BorderRadius.circular(12),
                              elevation: 8,
                              dropdownColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 5.0,
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black.withValues(alpha: 0.6),
                                size: 24,
                              ),
                              hint: const Text('Onbekend'),
                              items: ['Onbekend', '€0-€250', '€250-€500', '€500-€1000', '€1000-€2000', '€2000-€5000', '€5000+']
                                  .map((value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedExpectedLoss = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Accident severity question
                          Text(
                            'Ernst van het ongeval:',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: ['Licht', 'Matig', 'Ernstig']
                                .map((option) => OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedAccidentSeverity = option;
                                    });
                                  },
                                  style: _selectedAccidentSeverity == option
                                      ? AppComponentStyles.selectionButtonSelected()
                                      : AppComponentStyles.selectionButtonUnselected(),
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedAccidentSeverity == option
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ))
                                .toList(),
                          ),
                          const SizedBox(height: 24),
                          // Animal condition question
                          Text(
                            'Toestand van het dier:',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: ['Gezond', 'Verzwakt', 'Dood', 'Onbekend']
                                .map((option) => OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedAnimalCondition = option;
                                    });
                                  },
                                  style: _selectedAnimalCondition == option
                                      ? AppComponentStyles.selectionButtonSelected()
                                      : AppComponentStyles.selectionButtonUnselected(),
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedAnimalCondition == option
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Bottom buttons
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _saveDieraanrijdingDetails();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: Colors.black.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Vorige',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Save the dieraanrijding details
                          _saveDieraanrijdingDetails();
                          
                          debugPrint('[DieraanrijdingDetailsScreen] Saving: '
                            'expectedLoss: $_selectedExpectedLoss, '
                            'accidentSeverity: $_selectedAccidentSeverity, '
                            'animalCondition: $_selectedAnimalCondition');
                          
                          // Navigate to summary screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AnimalWaarnemingSummaryScreen(
                                totalCount: widget.totalCount,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF37A904),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Volgende',
                          style: TextStyle(
                            fontSize: 16,
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
      bottomNavigationBar: const SizedBox.shrink(),
    );
  }
}
