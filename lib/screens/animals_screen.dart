import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/dropdown_type.dart';
import 'package:wildrapport/services/animal_service.dart';
import 'package:wildrapport/services/dropdown_service.dart';
import 'package:wildrapport/widgets/app_bar.dart';

class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({super.key});

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  bool isExpanded = false;
  String selectedFilter = 'Filter';
  late List<AnimalModel> animals;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    animals = AnimalService.getAnimals();
  }

  @override
  void dispose() {
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
              centerText: 'Dieren',
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
        // Now you can use the selectedAnimal for navigation or other purposes
        print('Selected animal: ${selectedAnimal.animalName}');
        // Example:
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => AnimalDetailScreen(animal: selectedAnimal),
        //   ),
        // );
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
                child: Image.asset(
                  animal.animalImagePath,
                  fit: BoxFit.cover,
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


