import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/screens/schademelding/schademelding_details_screen.dart';
import 'package:wildrapport/constants/app_colors.dart';

class SchademeldingEigendomScreen extends StatefulWidget {
  const SchademeldingEigendomScreen({super.key});

  @override
  State<SchademeldingEigendomScreen> createState() =>
      _SchademeldingEigendomScreenState();
}

class _SchademeldingEigendomScreenState
    extends State<SchademeldingEigendomScreen> {
  late AnimalSightingReportingInterface _sightingManager;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sightingManager = context.read<AnimalSightingReportingInterface>();

    final currentSighting = _sightingManager.getCurrentanimalSighting();
    if (currentSighting != null) {
      _descriptionController.text = currentSighting.description ?? '';
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
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
        description: _descriptionController.text,
      );
      _sightingManager.updateCurrentanimalSighting(updated);
    }

    Navigator.push(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => const SchademeldingDetailsScreen(),
      ),
    );
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
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
                          children: [
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                'Eigendom',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Beschrijf de schade aan uw eigendom:',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _descriptionController,
                              maxLines: 8,
                              decoration: InputDecoration(
                                hintText: 'Beschrijf de schade en situatie...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppColors.borderDefault,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppColors.borderDefault,
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
                              onChanged: (value) {
                                final currentSighting =
                                    _sightingManager.getCurrentanimalSighting();
                                if (currentSighting != null) {
                                  final updated = currentSighting.copyWith(
                                    description: value,
                                  );
                                  _sightingManager
                                      .updateCurrentanimalSighting(updated);
                                }
                              },
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
}
