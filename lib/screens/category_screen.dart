import 'package:flutter/material.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/health_status_buttons.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  void _handleStatusSelection(String status) {
    // TODO: Implement status selection handling
    print('Selected status: $status');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Categorie',
              rightIcon: Icons.menu,
              onLeftIconPressed: () => Navigator.pop(context),
              onRightIconPressed: () {/* Handle menu */},
            ),
            HealthStatusButtons(
              buttons: [
                (text: 'Evenhoevigen', icon: null, imagePath: 'assets/icons/category/evenhoevigen.png'),
                (text: 'Knaagdieren', icon: null, imagePath: 'assets/icons/category/knaagdieren.png'),
                (text: 'Roofdieren', icon: null, imagePath: 'assets/icons/category/roofdieren.png'),
                (text: 'Andere', icon: Icons.more_horiz, imagePath: null),
              ],
              onStatusSelected: _handleStatusSelection,
              title: 'Selecteer Categorie',
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: () => Navigator.pop(context),
        onNextPressed: () {
          print('Next pressed');
        },
      ),
    );
  }
}






