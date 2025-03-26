import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/mixins/ui_state_aware.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/enums/dropdown_type.dart';
import 'package:wildrapport/services/animal_service.dart';
import 'package:wildrapport/services/dropdown_service.dart';
import 'package:wildrapport/widgets/app_bar.dart';

class AnimalsScreen extends StatefulWidget {
  final String screenTitle;
  
  const AnimalsScreen({
    super.key,
    required this.screenTitle,
  });

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> with UIStateAware<AnimalsScreen> {
  bool isExpanded = false;
  String selectedFilter = 'Filter';
  late List<AnimalModel> animals;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    animals = AnimalService.getAnimals();
    isExpanded = getScreenState<bool>('isExpanded') ?? false;
    selectedFilter = getScreenState<String>('selectedFilter') ?? 'Filter';
  }

  @override
  void dispose() {
    setScreenState('isExpanded', isExpanded);
    setScreenState('selectedFilter', selectedFilter);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: widget.screenTitle,
              rightIcon: Icons.menu,
              onLeftIconPressed: () {
                Navigator.pop(context);
              },
              onRightIconPressed: () {
                // Handle menu button press
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: DropdownService.buildDropdown(
                type: DropdownType.filter,
                selectedValue: selectedFilter,
                isExpanded: isExpanded,
                onExpandChanged: (value) {
                  setState(() {
                    isExpanded = value;
                  });
                },
                onOptionSelected: (selected) {
                  setState(() {
                    selectedFilter = selected;
                  });
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        child: Column(
                          children: List.generate(
                            (animals.length + 1) ~/ 2,
                            (index) => SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: _buildAnimalTile(animals[index * 2]),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Right Column
                      Expanded(
                        child: Column(
                          children: List.generate(
                            animals.length ~/ 2,
                            (index) => SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: _buildAnimalTile(animals[index * 2 + 1]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalTile(AnimalModel animal) {
    return GestureDetector(
      onTap: () {
        final selectedAnimal = AnimalService.handleAnimalSelection(animal);
        print('Selected animal: ${selectedAnimal.animalName}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
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
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image(
                  image: AssetImage(animal.animalImagePath),
                  fit: BoxFit.cover,
                  // Add a fade-in animation
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded) return child;
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                animal.animalName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brown,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}








