import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/screens/schademelding/schademelding_dieren_screen.dart';
import 'package:wildrapport/screens/schademelding/schademelding_gewas_types_screen.dart';
import 'package:wildrapport/screens/schademelding/schademelding_vee_types_screen.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';

class SchademeldingTypeSelectionScreen extends StatefulWidget {
  final String appBarTitle;

  const SchademeldingTypeSelectionScreen({
    super.key,
    required this.appBarTitle,
  });

  @override
  State<SchademeldingTypeSelectionScreen> createState() =>
      _SchademeldingTypeSelectionScreenState();
}

class _SchademeldingTypeSelectionScreenState
    extends State<SchademeldingTypeSelectionScreen> {
  String? _selectedType;

  void _handleBackNavigation() {
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    }
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
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 12, 0, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selecteer de getroffen categorie:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(
                      color: AppColors.borderDefault,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 240,
                            child: _buildDamageTypeCard(
                              title: 'Vee',
                              imagePath: 'assets/images/livestock.jpg',
                              isSelected: _selectedType == 'Vee',
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 240,
                            child: _buildDamageTypeCard(
                              title: 'Gewas',
                              imagePath: 'assets/images/crops.jpg',
                              isSelected: _selectedType == 'Gewas',
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 240,
                            child: _buildDamageTypeCard(
                              title: 'Eigendom',
                              imagePath: 'assets/images/property.jpg',
                              isSelected: _selectedType == 'Eigendom',
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
    );
  }

  Widget _buildDamageTypeCard({
    required String title,
    required String imagePath,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        debugPrint('[SchademeldingSpecies] Selected: $title');

        setState(() {
          _selectedType = title;
        });

        if (title == 'Gewas') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SchademeldingGewasTypesScreen(),
            ),
          );
        } else if (title == 'Vee') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SchademeldingVeeTypesScreen(),
            ),
          );
        } else if (title == 'Eigendom') {
          final sightingManager =
              context.read<AnimalSightingReportingInterface>();
          final currentSighting = sightingManager.getCurrentanimalSighting();

          if (currentSighting != null) {
            final updated = currentSighting.copyWith(
              cropType: 'Eigendom',
            );
            sightingManager.updateCurrentanimalSighting(updated);
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SchademeldingDierenScreen(
                gewasType: 'Eigendom',
              ),
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F4ED) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF4CAF50) : AppColors.borderDefault,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.12 : 0.06),
              blurRadius: isSelected ? 10 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 110,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color: Color(0xFFF3F3F3),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              height: 1,
              color:
                  isSelected ? const Color(0xFF4CAF50) : AppColors.borderDefault,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                color: isSelected ? const Color(0xFFF0F4ED) : Colors.white,
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF2E7D32)
                      : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}