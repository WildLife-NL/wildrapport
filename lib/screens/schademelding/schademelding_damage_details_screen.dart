import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/screens/schademelding/schademelding_summary_screen.dart';

class SchademeldingDamageDetailsScreen extends StatefulWidget {
  final String gewasType;

  const SchademeldingDamageDetailsScreen({super.key, required this.gewasType});

  @override
  State<SchademeldingDamageDetailsScreen> createState() =>
      _SchademeldingDamageDetailsScreenState();
}

class _SchademeldingDamageDetailsScreenState
    extends State<SchademeldingDamageDetailsScreen> {
  late AnimalSightingReportingInterface _sightingManager;
  String _selectedExpectedLoss = 'Onbekend';
  bool? _preventiveMeasures;
  final TextEditingController _additionalInfoController =
      TextEditingController();

  final List<String> _expectedLossOptions = [
    'Onbekend',
    '€0 - €250',
    '€250 - €500',
    '€500 - €1000',
    '€1000 - €2000',
    '€5000 +',
  ];

  @override
  void initState() {
    super.initState();
    _sightingManager = context.read<AnimalSightingReportingInterface>();
    
    // Load any previously saved data
    final currentSighting = _sightingManager.getCurrentanimalSighting();
    if (currentSighting != null) {
      _selectedExpectedLoss = currentSighting.expectedLoss ?? 'Onbekend';
      _preventiveMeasures = currentSighting.preventiveMeasures;
      _additionalInfoController.text = currentSighting.additionalInfo ?? '';
    }
  }

  @override
  void dispose() {
    _additionalInfoController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_preventiveMeasures == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecteer a.u.b. ja of nee voor preventieve maatregelen')),
      );
      return;
    }

    // Save data to sighting manager
    final currentSighting = _sightingManager.getCurrentanimalSighting();
    if (currentSighting != null) {
      final updated = currentSighting.copyWith(
        expectedLoss: _selectedExpectedLoss,
        preventiveMeasures: _preventiveMeasures,
        additionalInfo: _additionalInfoController.text,
      );
      _sightingManager.updateCurrentanimalSighting(updated);
    }

    final navigationManager = context.read<NavigationStateInterface>();

    debugPrint(
      '[SchademeldingDamageDetails] Expected Loss: $_selectedExpectedLoss, '
      'Preventive Measures: $_preventiveMeasures, '
      'Additional Info: ${_additionalInfoController.text}',
    );

    // Navigate to summary screen
    navigationManager.pushForward(
      context,
      const SchademeldingSummaryScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F4),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: null,
              centerText: 'Schademelding',
              rightIcon: null,
              showUserIcon: false,
              useFixedText: true,
              onLeftIconPressed: null,
              iconColor: Colors.black,
              textColor: Colors.black,
              fontScale: 1.4,
              iconScale: 1.15,
              userIconScale: 1.15,
            ),
            const SizedBox(height: 8),

            // Main card container
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          
                          const SizedBox(height: 24),

                          // Expected Loss Dropdown
                          Text(
                            'Wat is het verwachte verlies als gevolg van de schade?',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFCCCCCC),
                                width: 1,
                              ),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                canvasColor: Colors.white,
                                highlightColor: const Color(0xFFE8ECE6),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedExpectedLoss,
                                isExpanded: true,
                                underline: const SizedBox(),
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                items: _expectedLossOptions.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedExpectedLoss = newValue;
                                    });
                                    // Save to sighting manager
                                    final currentSighting = _sightingManager.getCurrentanimalSighting();
                                    if (currentSighting != null) {
                                      final updated = currentSighting.copyWith(
                                        expectedLoss: newValue,
                                      );
                                      _sightingManager.updateCurrentanimalSighting(updated);
                                    }
                                  }
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Preventive Measures Question
                          Text(
                            'Heeft u preventieve maatregelen genomen?',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildOptionButton(
                                  label: 'Nee',
                                  isSelected: _preventiveMeasures == false,
                                  onPressed: () {
                                    setState(() {
                                      _preventiveMeasures = false;
                                    });
                                    // Save to sighting manager
                                    final currentSighting = _sightingManager.getCurrentanimalSighting();
                                    if (currentSighting != null) {
                                      final updated = currentSighting.copyWith(
                                        preventiveMeasures: false,
                                      );
                                      _sightingManager.updateCurrentanimalSighting(updated);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildOptionButton(
                                  label: 'Ja',
                                  isSelected: _preventiveMeasures == true,
                                  onPressed: () {
                                    setState(() {
                                      _preventiveMeasures = true;
                                    });
                                    // Save to sighting manager
                                    final currentSighting = _sightingManager.getCurrentanimalSighting();
                                    if (currentSighting != null) {
                                      final updated = currentSighting.copyWith(
                                        preventiveMeasures: true,
                                      );
                                      _sightingManager.updateCurrentanimalSighting(updated);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Additional Information Text Area
                          Text(
                            'Meer informatie?',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _additionalInfoController,
                              maxLines: 6,
                              onChanged: (value) {
                                // Save to sighting manager on each change
                                final currentSighting = _sightingManager.getCurrentanimalSighting();
                                if (currentSighting != null) {
                                  final updated = currentSighting.copyWith(
                                    additionalInfo: value,
                                  );
                                  _sightingManager.updateCurrentanimalSighting(updated);
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Typ hier...',
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontSize: 14,
                                      color: const Color(0xFFB3B3B3),
                                    ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                            ),
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
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                            color: Color.fromARGB(59, 0, 0, 0),
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
                        onPressed: _onNextPressed,
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
    );
  }

  Widget _buildOptionButton({
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(
          color: isSelected
              ? const Color(0xFF333333)
              : Colors.black.withValues(alpha: 0.25),
          width: isSelected ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: isSelected
            ? const Color(0xFF333333)
            : Colors.white,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
