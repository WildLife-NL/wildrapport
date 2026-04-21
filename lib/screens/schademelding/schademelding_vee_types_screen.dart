import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/screens/schademelding/schademelding_dieren_screen.dart';
import 'package:wildrapport/utils/responsive_utils.dart';
import 'package:wildrapport/constants/app_colors.dart';

class SchademeldingVeeTypesScreen extends StatefulWidget {
  const SchademeldingVeeTypesScreen({super.key});

  @override
  State<SchademeldingVeeTypesScreen> createState() =>
      _SchademeldingVeeTypesScreenState();
}

class _SchademeldingVeeTypesScreenState
    extends State<SchademeldingVeeTypesScreen> {
  late AnimalSightingReportingInterface _sightingManager;
  String? _selectedVee;
  String? _customVeeType;
  
  final List<Map<String, String>> veeTypes = [
    {'title': 'Rund', 'image': 'assets/images/vee/rund.png'},
    {'title': 'Schaap', 'image': 'assets/images/vee/schaap.png'},
    {'title': 'Geit', 'image': 'assets/images/vee/geit.png'},
    {'title': 'Paard', 'image': 'assets/images/vee/paard.png'},
    {'title': 'Pluimvee', 'image': 'assets/images/vee/pluimvee.png'},
    {'title': 'Vark', 'image': 'assets/images/vee/vark.png'},
    {'title': 'Ander', 'image': 'ander'},
  ];

  @override
  void initState() {
    super.initState();
    _sightingManager = context.read<AnimalSightingReportingInterface>();
    
    // Load any previously selected vee type
    final currentSighting = _sightingManager.getCurrentanimalSighting();
    if (currentSighting != null && currentSighting.cropType != null) {
      final savedType = currentSighting.cropType!;
      final hasExactMatch = veeTypes.any((item) => item['title'] == savedType);
      _selectedVee = hasExactMatch ? savedType : 'Ander';
      if (!hasExactMatch) {
        _customVeeType = savedType;
      }
    }
  }

  void _handleBackNavigation() {
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    }
  }

  void _handleVeeTypeSelection(String veeType, {String? selectedTileTitle}) {
    debugPrint('[SchademeldingVeeTypes] Selected: $veeType');
    
    // Save selected vee type to provider
    final currentSighting = _sightingManager.getCurrentanimalSighting();
    if (currentSighting != null) {
      final updated = currentSighting.copyWith(
        cropType: veeType,
      );
      _sightingManager.updateCurrentanimalSighting(updated);
    }
    
    setState(() {
      _selectedVee = selectedTileTitle ?? veeType;
      if ((selectedTileTitle ?? veeType) != 'Ander') {
        _customVeeType = null;
      }
    });
    
    // Navigate to animal selection
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchademeldingDierenScreen(gewasType: veeType),
      ),
    );
  }

  Future<void> _promptCustomVeeType() async {
    final controller = TextEditingController(text: _customVeeType ?? '');
    final customValue = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ander soort vee',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Vul hieronder het soort vee in.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF8D8D8D),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: controller,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Bijv. Alpaca',
                    hintStyle: TextStyle(
                      color: Colors.black.withValues(alpha: 0.45),
                      fontSize: 13,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD0D0D0), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF999999), width: 1.2),
                    ),
                  ),
                  onSubmitted: (value) {
                    final trimmed = value.trim();
                    if (trimmed.isNotEmpty) {
                      Navigator.of(dialogContext).pop(trimmed);
                    }
                  },
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Color(0xFFB5B5B5), width: 1),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ).copyWith(
                          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                            if (states.contains(WidgetState.pressed) ||
                                states.contains(WidgetState.selected)) {
                              return const Color(0xFFF0F0F0);
                            }
                            return Colors.white;
                          }),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Annuleren'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Color(0xFFAAAAAA), width: 1),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ).copyWith(
                          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                            if (states.contains(WidgetState.pressed) ||
                                states.contains(WidgetState.selected)) {
                              return const Color(0xFFEAEAEA);
                            }
                            return Colors.white;
                          }),
                        ),
                        onPressed: () {
                          final trimmed = controller.text.trim();
                          if (trimmed.isNotEmpty) {
                            Navigator.of(dialogContext).pop(trimmed);
                          }
                        },
                        child: const Text('Verder'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || customValue == null || customValue.trim().isEmpty) {
      return;
    }

    _customVeeType = customValue.trim();
    _handleVeeTypeSelection(
      _customVeeType!,
      selectedTileTitle: 'Ander',
    );
  }

  Widget _buildVeeTile(String title, String imagePath) {
    final isSelected = _selectedVee == title;
    final isAnder = imagePath == 'ander';
    
    return GestureDetector(
      onTap: () {
        if (isAnder) {
          _promptCustomVeeType();
          return;
        }
        _handleVeeTypeSelection(title);
      },
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
                      child: isAnder
                          ? Center(
                              child: Icon(
                                Icons.add,
                                size: 60,
                                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[600],
                                weight: 3,
                              ),
                            )
                          : Image.asset(
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
            // AppBar
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Schademelding',
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
            // Header text
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 12, 0, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selecteer het soort vee:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
            ),
            // Main card container with grid
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
                                (veeTypes.length + 1) ~/ 2,
                                (index) => SizedBox(
                                  height: cardHeight,
                                  child: _buildVeeTile(
                                    veeTypes[index * 2]['title']!,
                                    veeTypes[index * 2]['image']!,
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
                                veeTypes.length ~/ 2,
                                (index) => SizedBox(
                                  height: cardHeight,
                                  child: _buildVeeTile(
                                    veeTypes[index * 2 + 1]['title']!,
                                    veeTypes[index * 2 + 1]['image']!,
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
