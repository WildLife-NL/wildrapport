
import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';

class Rapporteren extends StatelessWidget {
  const Rapporteren({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60), // App bar space
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
                                image: 'assets/icons/report.png',
                                text: 'Rapport 1',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: _buildReportButton(
                                image: 'assets/icons/report.png',
                                text: 'Rapport 3',
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
                              image: 'assets/icons/report.png',
                              text: 'Rapport 2',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: _buildReportButton(
                              image: 'assets/icons/report.png',
                              text: 'Rapport 4',
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
    required String image,
    required String text,
    VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
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
          onTap: onPressed,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Image.asset(
                        image,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      flex: 2,
                      child: Text(
                        text,
                        style: AppTextTheme.textTheme.titleMedium,
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


