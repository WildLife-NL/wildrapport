import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/animal_interface.dart';
import 'package:wildrapport/interfaces/filter_interface.dart';
import 'package:wildrapport/interfaces/overzicht_interface.dart';
import 'package:wildrapport/widgets/overzicht/top_container.dart';
import 'package:wildrapport/widgets/overzicht/action_buttons.dart';
import 'package:wildrapport/widgets/rapporteren.dart';

class OverzichtScreen extends StatefulWidget {
  const OverzichtScreen({super.key});

  @override
  State<OverzichtScreen> createState() => _OverzichtScreenState();
}

class _OverzichtScreenState extends State<OverzichtScreen> {
  late final AnimalRepositoryInterface animalService;
  late final FilterInterface filterService;
  late final OverzichtInterface _overzichtManager;

  @override
  void initState() {
    super.initState();
    animalService = context.read<AnimalRepositoryInterface>();
    filterService = context.read<FilterInterface>();
    _overzichtManager = context.read<OverzichtInterface>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TopContainer(
            userName: _overzichtManager.userName,
            height: _overzichtManager.topContainerHeight,
            welcomeFontSize: _overzichtManager.welcomeFontSize,
            usernameFontSize: _overzichtManager.usernameFontSize,
          ),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Rapporteren(),
                    ),
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
            buttonSpacing: 16, // Increased from 8 to 16 pixels
            buttonHeight: 140,
          ),
        ],
      ),
    );
  }
}
















