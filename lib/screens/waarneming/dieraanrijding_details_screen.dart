import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/screens/waarneming/animal_waarneming_summary_screen.dart';
import 'package:wildrapport/constants/app_colors.dart';

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

class _DieraanrijdingDetailsScreenState
    extends State<DieraanrijdingDetailsScreen> {
  late AnimalSightingReportingInterface _sightingManager;
  String _selectedSeverity = 'Licht';
  String _selectedCondition = 'Gezond';
  String _selectedExpectedLoss = '€0-€250';
  final TextEditingController _additionalInfoController =
      TextEditingController();

  final List<String> _severityOptions = [
    'Licht',
    'Matig',
    'Ernstig',
  ];

  final List<String> _conditionOptions = [
    'Gezond',
    'Gewond',
    'Dood',
  ];

  final List<String> _expectedLossOptions = [
    '€0-€250',
    '€250-€500',
    '€500-€1000',
    '€1000-€2000',
    '€2000-€5000',
    '€5000+',
  ];

  @override
  void initState() {
    super.initState();
    _sightingManager = context.read<AnimalSightingReportingInterface>();

    final currentSighting = _sightingManager.getCurrentanimalSighting();
    if (currentSighting != null) {
      _selectedSeverity = currentSighting.accidentSeverity ?? 'Licht';
      _selectedCondition =
          currentSighting.animalConditionDieraanrijding ?? 'Gezond';
      _selectedExpectedLoss = currentSighting.expectedLoss ?? '€0-€250';
      _additionalInfoController.text = currentSighting.additionalInfo ?? '';
    }
  }

  @override
  void dispose() {
    _additionalInfoController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    final currentSighting = _sightingManager.getCurrentanimalSighting();
    if (currentSighting != null) {
      final updated = currentSighting.copyWith(
        accidentSeverity: _selectedSeverity,
        animalConditionDieraanrijding: _selectedCondition,
        expectedLoss: _selectedExpectedLoss,
        additionalInfo: _additionalInfoController.text,
      );
      _sightingManager.updateCurrentanimalSighting(updated);
    }

    debugPrint(
      '[DieraanrijdingDetails] Severity: $_selectedSeverity, '
      'Condition: $_selectedCondition, '
      'Expected Loss: $_selectedExpectedLoss, '
      'Additional Info: ${_additionalInfoController.text}',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimalWaarnemingSummaryScreen(
          totalCount: widget.totalCount,
        ),
      ),
    );
  }

  void _handleBackNavigation() {
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F4),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              CustomAppBar(
                leftIcon: Icons.arrow_back_ios,
                centerText: 'Dieraanrijding',
                rightIcon: null,
                showUserIcon: false,
                useFixedText: true,
                onLeftIconPressed: _handleBackNavigation,
                iconColor: AppColors.textPrimary,
                textColor: AppColors.textPrimary,
                fontScale: 1.4,
                iconScale: 1.15,
                userIconScale: 1.15,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(
                        color: Color(0xFF999999),
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
                                      final currentSighting =
                                          _sightingManager.getCurrentanimalSighting();
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
                            Text(
                              'Ernst van het ongeluk:',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _severityOptions.map((severity) {
                                return _buildOptionButton(
                                  label: severity,
                                  isSelected: _selectedSeverity == severity,
                                  onPressed: () {
                                    setState(() {
                                      _selectedSeverity = severity;
                                    });
                                    final currentSighting =
                                        _sightingManager.getCurrentanimalSighting();
                                    if (currentSighting != null) {
                                      final updated = currentSighting.copyWith(
                                        accidentSeverity: severity,
                                      );
                                      _sightingManager.updateCurrentanimalSighting(updated);
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Toestand van het dier:',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _conditionOptions.map((condition) {
                                return _buildOptionButton(
                                  label: condition,
                                  isSelected: _selectedCondition == condition,
                                  onPressed: () {
                                    setState(() {
                                      _selectedCondition = condition;
                                    });
                                    final currentSighting =
                                        _sightingManager.getCurrentanimalSighting();
                                    if (currentSighting != null) {
                                      final updated = currentSighting.copyWith(
                                        animalConditionDieraanrijding: condition,
                                      );
                                      _sightingManager.updateCurrentanimalSighting(updated);
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 32),
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
                                  final currentSighting =
                                      _sightingManager.getCurrentanimalSighting();
                                  if (currentSighting != null) {
                                    final updated = currentSighting.copyWith(
                                      additionalInfo: value,
                                    );
                                    _sightingManager.updateCurrentanimalSighting(updated);
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'Typ hier...',
                                  hintStyle:
                                      Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontSize: 14,
                                            color: const Color(0xFFB3B3B3),
                                          ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _handleBackNavigation,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(
                              color: Color.fromARGB(59, 0, 0, 0),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            foregroundColor:
                                const Color.fromARGB(255, 0, 0, 0),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: BorderSide(
          color: isSelected
              ? const Color(0xFF333333)
              : AppColors.textPrimary.withValues(alpha: 0.25),
          width: isSelected ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor:
            isSelected ? const Color(0xFF333333) : Colors.white,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }
}
