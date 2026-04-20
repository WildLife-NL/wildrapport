import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/screens/schademelding/schademelding_summary_screen.dart';

class SchademeldingDetailsScreen extends StatefulWidget {
  const SchademeldingDetailsScreen({super.key});

  @override
  State<SchademeldingDetailsScreen> createState() => _SchademeldingDetailsScreenState();
}

class _SchademeldingDetailsScreenState extends State<SchademeldingDetailsScreen> {
  late AnimalSightingReportingInterface _sightingManager;
  String _selectedExpectedLoss = '€0-€250';
  bool _preventiveMeasures = false;
  final TextEditingController _additionalInfoController = TextEditingController();

  final List<String> _expectedLossOptions = <String>[
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
      _selectedExpectedLoss = currentSighting.expectedLoss ?? '€0-€250';
      _preventiveMeasures = currentSighting.preventiveMeasures ?? false;
      _additionalInfoController.text = currentSighting.additionalInfo ?? '';
    }
  }

  @override
  void dispose() {
    _additionalInfoController.dispose();
    super.dispose();
  }

  void _handleBackNavigation() {
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    }
  }

  void _onNextPressed() {
    final currentSighting = _sightingManager.getCurrentanimalSighting();
    if (currentSighting != null) {
      final updated = currentSighting.copyWith(
        expectedLoss: _selectedExpectedLoss,
        preventiveMeasures: _preventiveMeasures,
        additionalInfo: _additionalInfoController.text,
      );
      _sightingManager.updateCurrentanimalSighting(updated);
    }

    Navigator.push(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => const SchademeldingSummaryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F4),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              CustomAppBar(
                leftIcon: Icons.arrow_back_ios,
                centerText: 'Schademelding',
                rightIcon: null,
                showUserIcon: false,
                useFixedText: true,
                onLeftIconPressed: _handleBackNavigation,
                iconColor: Colors.black,
                textColor: Colors.black,
                fontScale: 1.4,
                iconScale: 1.15,
                userIconScale: 1.15,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: AppColors.borderDefault,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
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
                                  color: AppColors.borderDefault,
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
                              'Heeft u preventieve maatregelen genomen?',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: _buildToggleButton(
                                    label: 'Nee',
                                    isSelected: !_preventiveMeasures,
                                    onPressed: () {
                                      setState(() {
                                        _preventiveMeasures = false;
                                      });
                                      final currentSighting =
                                          _sightingManager.getCurrentanimalSighting();
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
                                  child: _buildToggleButton(
                                    label: 'Ja',
                                    isSelected: _preventiveMeasures,
                                    onPressed: () {
                                      setState(() {
                                        _preventiveMeasures = true;
                                      });
                                      final currentSighting =
                                          _sightingManager.getCurrentanimalSighting();
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
                            Text(
                              'Meer informatie (optioneel):',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _additionalInfoController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'Beschrijf de schade en situatie...',
                                filled: true,
                                fillColor: const Color.fromARGB(255, 255, 255, 255),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFCCCCCC),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFCCCCCC),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF4CAF50),
                                    width: 1.2,
                                  ),
                                ),
                              ),
                              onChanged: (String value) {
                                final currentSighting =
                                    _sightingManager.getCurrentanimalSighting();
                                if (currentSighting != null) {
                                  final updated = currentSighting.copyWith(
                                    additionalInfo: value,
                                  );
                                  _sightingManager.updateCurrentanimalSighting(updated);
                                }
                              },
                            ),
                            const SizedBox(height: 24),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: _onNextPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4CAF50),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton({
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
              : Colors.black.withValues(alpha: 0.25),
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
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
