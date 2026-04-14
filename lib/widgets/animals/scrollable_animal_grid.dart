import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_model.dart';
import 'package:wildrapport/widgets/animals/animal_grid.dart';

class ScrollableAnimalGrid extends StatelessWidget {
  final List<AnimalModel>? animals;
  final bool isLoading;
  final String? error;
  final ScrollController scrollController;
  final Function(AnimalModel) onAnimalSelected;
  final VoidCallback? onRetry;
  final AnimalModel? selectedAnimal;

  const ScrollableAnimalGrid({
    super.key,
    required this.animals,
    required this.isLoading,
    this.error,
    required this.scrollController,
    required this.onAnimalSelected,
    this.onRetry,
    this.selectedAnimal,
  });

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Lottie.asset(
            'assets/loaders/loading_paw.json',
            fit: BoxFit.contain,
            repeat: true,
            animate: true,
            frameRate: FrameRate(60),
          ),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.grey.shade400,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                onPressed: onRetry,
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (animals == null || animals!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No animals found',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 15,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.grey.shade400,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                onPressed: onRetry,
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return AnimalGrid(
      animals: animals!,
      onAnimalSelected: onAnimalSelected,
      selectedAnimal: selectedAnimal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      child: _buildContent(),
    );
  }
}

