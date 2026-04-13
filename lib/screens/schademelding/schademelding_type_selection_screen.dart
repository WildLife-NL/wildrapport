import 'package:flutter/material.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/screens/schademelding/schademelding_gewas_types_screen.dart';
import 'package:wildrapport/screens/schademelding/schademelding_vee_types_screen.dart';

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
  
  @override
  void initState() {
    super.initState();
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
                    side: BorderSide(
                      color: const Color(0xFF999999),
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
        }
        // TODO: Navigate to next screen for Eigendom
      },
      child: Card(
        elevation: isSelected ? 4 : 0,
        color: isSelected ? const Color(0xFFF0F4ED) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF999999),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image area with selection indicator
            SizedBox(
              height: 120,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  color: const Color(0xFFE6DCCD),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Divider line
            Container(
              height: 1,
              color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF999999),
            ),
            // Title area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                color: isSelected ? const Color(0xFFF0F4ED) : Colors.white,
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
