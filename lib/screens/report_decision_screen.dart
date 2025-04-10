import 'package:flutter/material.dart';
import 'package:wildrapport/screens/animal_amount_selection.dart';
import 'package:wildrapport/screens/animal_gender_screen.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/white_bulk_button.dart';
import 'package:wildrapport/widgets/circle_icon_container.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/models/waarneming_model.dart';

class ReportDecisionScreen extends StatelessWidget {
  final WaarnemingModel waarneming;

  const ReportDecisionScreen({
    super.key,
    required this.waarneming,
  });

  Widget _buildArrowIcon() {
    return Icon(
      Icons.arrow_forward_ios,
      color: AppColors.brown,
      size: 32,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.25),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[ReportDecisionScreen] Building screen');
    debugPrint('[ReportDecisionScreen] Current waarneming state: ${waarneming.toJson()}');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Rapporteren',
              rightIcon: Icons.menu,
              onLeftIconPressed: () {
                debugPrint('[ReportDecisionScreen] Back button pressed');
                Navigator.pop(context);
              },
              onRightIconPressed: () {
                debugPrint('[ReportDecisionScreen] Menu button pressed');
                /* Handle menu */
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'We raden u aan om onze tabel in te vullen indien er meerdere dieren zijn waargenomen',
                      textAlign: TextAlign.center,
                      style: AppTextTheme.textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                        color: AppColors.brown,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    WhiteBulkButton(
                      text: 'Naar Tabel',
                      leftWidget: const CircleIconContainer(
                        icon: Icons.table_chart,
                        iconColor: AppColors.brown,
                        size: 48,
                      ),
                      rightWidget: _buildArrowIcon(),
                      onPressed: () {
                        debugPrint('[ReportDecisionScreen] Naar Tabel button pressed');
                        // TODO: Implement navigation to table
                      },
                    ),
                    const SizedBox(height: 20),
                    WhiteBulkButton(
                      text: 'In Stappen',
                      leftWidget: const CircleIconContainer(
                        icon: Icons.list_alt,
                        iconColor: AppColors.brown,
                        size: 48,
                      ),
                      rightWidget: _buildArrowIcon(),
                      onPressed: () {
                        debugPrint('[ReportDecisionScreen] In Stappen button pressed');
                        debugPrint('[ReportDecisionScreen] Navigating to AnimalGenderScreen with waarneming: ${waarneming.toJson()}');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnimalGenderScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: () {
          debugPrint('[ReportDecisionScreen] Bottom back button pressed');
          Navigator.pop(context);
        },
        onNextPressed: () {},
        showNextButton: false,  // Hide the next button
      ),
    );
  }
}


