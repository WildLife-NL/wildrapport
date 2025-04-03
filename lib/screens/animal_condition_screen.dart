import 'package:flutter/material.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/selection_button_group.dart';

class AnimalConditionScreen extends StatelessWidget {
  const AnimalConditionScreen({super.key});

  void _handleStatusSelection(String status) {
    // TODO: Implement status selection handling
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Dier Conditie',
              rightIcon: Icons.menu,
              onLeftIconPressed: () => Navigator.pop(context),
              onRightIconPressed: () {/* Handle menu */},
            ),
            SelectionButtonGroup(
              buttons: const [
                (text: 'Gezond', icon: Icons.check_circle, imagePath: null),
                (text: 'Ziek', icon: Icons.sick, imagePath: null),
                (text: 'Dood', icon: Icons.dangerous, imagePath: null),
                (text: 'Andere', icon: Icons.more_horiz, imagePath: null),
              ],
              onStatusSelected: _handleStatusSelection,
              title: 'Selecteer dier Conditie',
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: () => Navigator.pop(context),
        onNextPressed: () {
          // TODO: Implement next screen navigation
        },
      ),
    );
  }
}






