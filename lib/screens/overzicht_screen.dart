import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/widgets/overzicht/top_container.dart';
import 'package:wildrapport/widgets/overzicht/action_buttons.dart';
import 'package:wildrapport/screens/rapporteren.dart';

class OverzichtScreen extends StatelessWidget {
  const OverzichtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationManager = context.read<NavigationStateInterface>();

    return Scaffold(
      body: Column(
        children: [
          const TopContainer(
            userName: 'John Doe',
            height: 285.0,
            welcomeFontSize: 20.0,
            usernameFontSize: 24.0,
          ),
          const SizedBox(height: 24),
          ActionButtons(
            buttons: [
              (
                text: 'RapportenKaart',
                icon: Icons.map,
                imagePath: null,
                onPressed: () {
                  // Handle RapportenKaart action
                },
              ),
              (
                text: 'Rapporteren',
                icon: Icons.edit_note,
                imagePath: null,
                onPressed: () {
                  navigationManager.pushReplacementForward(
                    context,
                    const Rapporteren(),
                  );
                },
              ),
              (
                text: 'Mijn Rapporten',
                icon: Icons.description,
                imagePath: null,
                onPressed: () {
                  // Handle Mijn Rapporten action
                },
              ),
            ],
            iconSize: 64,
            verticalPadding: 0,
            horizontalPadding: MediaQuery.of(context).size.width * 0.05,
            buttonSpacing: 16,
            buttonHeight: 140,
          ),
        ],
      ),
    );
  }
}




















