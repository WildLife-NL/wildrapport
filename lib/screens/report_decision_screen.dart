import 'package:flutter/material.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/white_bulk_button.dart';
import 'package:wildrapport/widgets/circle_icon_container.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';

class ReportDecisionScreen extends StatelessWidget {
  const ReportDecisionScreen({super.key});

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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Rapporteren',
              rightIcon: Icons.menu,
              onLeftIconPressed: () => Navigator.pop(context),
              onRightIconPressed: () {/* Handle menu */},
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
                        // TODO: Implement navigation to steps
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
        onBackPressed: () => Navigator.pop(context),
        onNextPressed: () {},
        showNextButton: false,  // Hide the next button
      ),
    );
  }
}





