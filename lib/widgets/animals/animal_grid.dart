import 'package:flutter/material.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_model.dart';
import 'package:wildrapport/widgets/animals/animal_tile.dart';
import 'package:wildrapport/utils/responsive_utils.dart';

class AnimalGrid extends StatelessWidget {
  final List<AnimalModel> animals;
  final Function(AnimalModel) onAnimalSelected;

  const AnimalGrid({
    super.key,
    required this.animals,
    required this.onAnimalSelected,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    // Calculate the width for each column to make containers square
    final containerWidth = (responsive.width - responsive.spacing(40) - responsive.spacing(12)) / 2;
    final containerHeight = containerWidth + responsive.spacing(50); // Add space for text label
    
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
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: responsive.spacing(12)),
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
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
