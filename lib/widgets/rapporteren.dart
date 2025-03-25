
import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/screens/animals_screen.dart';
import 'package:wildrapport/widgets/app_bar.dart';

class Rapporteren extends StatelessWidget {
  const Rapporteren({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_forward_ios,
              centerText: 'Rapporteren',
              rightIcon: Icons.menu,
              onLeftIconPressed: () {
                // Handle back button press
              },
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
          borderRadius: BorderRadius.circular(25),
          onTap: onPressed ?? (() { 
            if (text == 'Waarnemingen' || text == 'Diergezondheid') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AnimalsScreen(),
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












