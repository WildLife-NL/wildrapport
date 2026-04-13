import 'package:flutter/material.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_model.dart';
import 'package:wildrapport/widgets/animals/animal_tile.dart';
import 'package:wildrapport/utils/responsive_utils.dart';

class AnimalGrid extends StatelessWidget {
  final List<AnimalModel> animals;
  final Function(AnimalModel) onAnimalSelected;
  final AnimalModel? selectedAnimal;

  const AnimalGrid({
    super.key,
    required this.animals,
    required this.onAnimalSelected,
    this.selectedAnimal,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    // Calculate the width for each column to make image area square
    final horizontalPadding = responsive.spacing(40);
    final columnSpacing = responsive.spacing(16);
    final containerWidth =
        (responsive.width - horizontalPadding - columnSpacing) / 2;
    // Height equals width to make cards square
    final containerHeight = containerWidth;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        Expanded(
          child: Column(
            children: List.generate(
              (animals.length + 1) ~/ 2,
              (index) => SizedBox(
                height: containerHeight,
                child: AnimalTile(
                  animal: animals[index * 2],
                  onTap: () => onAnimalSelected(animals[index * 2]),
                  isSelected: selectedAnimal?.animalId == animals[index * 2].animalId,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: responsive.spacing(16)),
        // Right Column
        Expanded(
          child: Column(
            children: List.generate(
              animals.length ~/ 2,
              (index) => SizedBox(
                height: containerHeight,
                child: AnimalTile(
                  animal: animals[index * 2 + 1],
                  onTap: () => onAnimalSelected(animals[index * 2 + 1]),
                  isSelected: selectedAnimal?.animalId == animals[index * 2 + 1].animalId,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

