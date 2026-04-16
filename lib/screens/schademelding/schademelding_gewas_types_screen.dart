import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/utils/responsive_utils.dart';
import 'package:wildrapport/screens/schademelding/schademelding_dieren_screen.dart';

class SchademeldingGewasTypesScreen extends StatefulWidget {
  const SchademeldingGewasTypesScreen({super.key});

  @override
  State<SchademeldingGewasTypesScreen> createState() =>
      _SchademeldingGewasTypesScreenState();
}

class _SchademeldingGewasTypesScreenState
    extends State<SchademeldingGewasTypesScreen> {
  late AnimalSightingReportingInterface _sightingManager;
  String? _selectedGewas;
  
  final List<Map<String, String>> gewasTypes = [
    {'title': 'Maïs', 'image': 'assets/images/gewas/mais.jpg'},
    {'title': 'Granen', 'image': 'assets/images/gewas/granen.jpg'},
    {'title': 'Groente', 'image': 'assets/images/gewas/groente.jpg'},
    {'title': 'Fruit', 'image': 'assets/images/gewas/fruit.jpg'},
    {'title': 'Grasland', 'image': 'assets/images/gewas/grasland.jpg'},
    {'title': 'Tuin', 'image': 'assets/images/gewas/tuin.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _sightingManager = context.read<AnimalSightingReportingInterface>();
    
    // Load any previously selected gewas type
    final currentSighting = _sightingManager.getCurrentanimalSighting();
    if (currentSighting != null && currentSighting.cropType != null) {
      _selectedGewas = currentSighting.cropType;
    }
  }

  void _handleBackNavigation() {
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    }
  }

  void _handleGewasTypeSelection(String gewasType) {
    debugPrint('[SchademeldingGewasTypes] Selected: $gewasType');
    
    // Save selected gewas type to provider
    final currentSighting = _sightingManager.getCurrentanimalSighting();
    if (currentSighting != null) {
      final updated = currentSighting.copyWith(
        cropType: gewasType,
      );
      _sightingManager.updateCurrentanimalSighting(updated);
    }
    
    setState(() {
      _selectedGewas = gewasType;
    });
    
    // Navigate to animal selection
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchademeldingDierenScreen(gewasType: gewasType),
      ),
    );
  }

  Widget _buildGewasTile(String title, String imagePath) {
    final isSelected = _selectedGewas == title;
    
    return GestureDetector(
      onTap: () => _handleGewasTypeSelection(title),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Card(
          elevation: isSelected ? 4 : 3,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF999999),
              width: isSelected ? 2 : 1,
            ),
          ),
          color: isSelected ? const Color(0xFFF0F4ED) : Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image area with selection indicator
              Expanded(
                child: SizedBox.expand(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                      color: const Color(0xFFE6DCCD),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
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
              ),
              // Divider line
              Container(
                height: 1,
                color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF999999),
              ),
              // Title area
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF0F4ED) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    // Calculate the width for each column to make tiles square
    final horizontalPadding = responsive.spacing(40);
    final columnSpacing = responsive.spacing(16);
    final cardWidth =
        (responsive.width - horizontalPadding - columnSpacing) / 2;
    // Height equals width to make cards square
    final cardHeight = cardWidth;

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
                  'Selecteer gewas type:',
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
                    side: BorderSide(
                      color: const Color(0xFF999999),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column
                          Expanded(
                            child: Column(
                              children: List.generate(
                                (gewasTypes.length + 1) ~/ 2,
                                (index) => SizedBox(
                                  height: cardHeight,
                                  child: _buildGewasTile(
                                    gewasTypes[index * 2]['title']!,
                                    gewasTypes[index * 2]['image']!,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: responsive.spacing(16)),
                          // Right Column
                          Expanded(
                            child: Column(
                              children: List.generate(
                                gewasTypes.length ~/ 2,
                                (index) => SizedBox(
                                  height: cardHeight,
                                  child: _buildGewasTile(
                                    gewasTypes[index * 2 + 1]['title']!,
                                    gewasTypes[index * 2 + 1]['image']!,
                                  ),
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
    );
  }
}
