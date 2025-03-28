
import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/managers/screen_state_manager.dart';
import 'package:wildrapport/screens/animals_screen.dart';
import 'package:wildrapport/widgets/app_bar.dart';

class Rapporteren extends StatefulWidget {
  const Rapporteren({super.key});

  @override
  State<Rapporteren> createState() => _RapporterenState();
}

class _RapporterenState extends ScreenStateManager<Rapporteren> {
  late String selectedCategory = ''; // Initialize with empty string

  @override
  String get screenName => 'Rapporteren';

  @override
  void initState() {
    super.initState();
    // Load initial state
    final initialState = getInitialState();
    selectedCategory = initialState['selectedCategory'] as String;
  }

  @override
  Map<String, dynamic> getInitialState() => {
    'selectedCategory': '', // Provide default value
  };

  @override
  Map<String, dynamic> getCurrentState() => {
    'selectedCategory': selectedCategory,
  };

  @override
  void updateState(String key, dynamic value) {
    if (key == 'selectedCategory') {
      setState(() {
        selectedCategory = value as String;
      });
    }
  }

  void _handleReportTypeSelection(String reportType) {
    // Initialize the report
    initializeReportFlow(reportType);
    
    // Navigate to appropriate first screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimalsScreen(screenTitle: reportType),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Rapporteren',
              rightIcon: Icons.menu,
              onLeftIconPressed: () => Navigator.of(context).pop(),
              onRightIconPressed: () {
                // Handle menu button press
              },
            ),
            const SizedBox(height: 30), // App bar space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0), // Added horizontal padding
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column
                    Expanded(
                      child: Transform.translate(
                        offset: const Offset(0, -15), // Move entire left column up by 15 pixels
                        child: Column(
                          children: [
                            Expanded(
                              child: _buildReportButton(
                                context: context,
                                image: 'assets/icons/rapporteren/crop_icon.png',
                                text: 'Gewasschade',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: _buildReportButton(
                                context: context,
                                image: 'assets/icons/rapporteren/health_icon.png',
                                text: 'Diergezondheid',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right Column
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: _buildReportButton(
                              context: context,
                              image: 'assets/icons/rapporteren/accident_icon.png',
                              text: 'Verkeersongeval',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: _buildReportButton(
                              context: context,
                              image: 'assets/icons/rapporteren/sighting_icon.png',
                              text: 'Waarnemingen',
                            ),
                          ),
                        ],
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

  Widget _buildReportButton({
    required BuildContext context,
    required String image,
    required String text,
    VoidCallback? onPressed,
  }) {
    bool needsSmallerFont = [
      'Verkeersongeval', 
      'Diergezondheid', 
      'Waarnemingen',
      'Gewasschade'
    ].contains(text);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashFactory: NoSplash.splashFactory,  // Change this to prevent splash effect
          highlightColor: Colors.transparent,      // Add this to prevent highlight
          borderRadius: BorderRadius.circular(25),
          onTap: onPressed ?? (() { 
            if (text == 'Waarnemingen' || text == 'Diergezondheid') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AnimalsScreen(
                    screenTitle: text,
                  ),
                ),
              );
            }
          }),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Transform.translate(
                        offset: const Offset(0, -5), // Move icon up by 5 pixels
                        child: Image.asset(
                          image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      flex: 2,
                      child: Text(
                        text,
                        style: needsSmallerFont 
                            ? AppTextTheme.textTheme.titleMedium?.copyWith(fontSize: 16)
                            : AppTextTheme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.brown.withOpacity(0.5),
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



































