import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/dropdown_interface.dart';
import 'package:wildrapport/interfaces/animal_interface.dart';
import 'package:wildrapport/models/enums/dropdown_type.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/animal_grid.dart';
import 'package:lottie/lottie.dart';
import 'package:wildrapport/widgets/scrollable_animal_grid.dart';

class GewasschadeAnimalScreen extends StatefulWidget {
  final String appBarTitle;

  const GewasschadeAnimalScreen({
    super.key,
    required this.appBarTitle,
  });

  @override
  State<GewasschadeAnimalScreen> createState() => _GewasschadeAnimalScreenState();
}

class _GewasschadeAnimalScreenState extends State<GewasschadeAnimalScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isExpanded = false;
  List<AnimalModel> _animals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAnimals() async {
    final animalManager = context.read<AnimalManagerInterface>();
    
    setState(() {
      _isLoading = true;
    });

    try {
      final animals = await animalManager.getAnimals();
      setState(() {
        _animals = animals;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[GewasschadeAnimalScreen] Error loading animals: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _handleAnimalSelection(AnimalModel selectedAnimal) {
    // TODO: Implement gewasschade specific animal selection logic
    debugPrint('[GewasschadeAnimalScreen] Selected animal: ${selectedAnimal.animalName}');
  }

  @override
  Widget build(BuildContext context) {
    final dropdownInterface = context.read<DropdownInterface>();
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: widget.appBarTitle,
              rightIcon: Icons.menu,
              onLeftIconPressed: () {
                debugPrint('[GewasschadeAnimalScreen] Back button pressed');
                Navigator.pop(context);
              },
              onRightIconPressed: () {
                debugPrint('[GewasschadeAnimalScreen] Menu button pressed');
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: dropdownInterface.buildDropdown(
                type: DropdownType.filter,
                selectedValue: context.read<AnimalManagerInterface>().getSelectedFilter(),
                isExpanded: _isExpanded,
                onExpandChanged: (_) => _toggleExpanded(),
                onOptionSelected: (value) {
                  context.read<AnimalManagerInterface>().updateFilter(value);
                  _loadAnimals();
                },
                context: context,
              ),
            ),
            ScrollableAnimalGrid(
              animals: _animals,
              isLoading: _isLoading,
              scrollController: _scrollController,
              onAnimalSelected: _handleAnimalSelection,
              onRetry: _loadAnimals,
            ),
          ],
        ),
      ),
    );
  }
}
