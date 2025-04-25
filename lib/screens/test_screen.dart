import 'package:flutter/material.dart';
import 'package:wildrapport/widgets/animal_counting.dart';
import 'package:wildrapport/widgets/app_bar.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          leftIcon: Icons.arrow_back_ios,
          centerText: 'Test Screen',
          rightIcon: Icons.menu,
          onLeftIconPressed: () => Navigator.pop(context),
          onRightIconPressed: () {/* Handle menu */},
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimalCounting(),
          ],
        ),
      ),
    );
  }
}







