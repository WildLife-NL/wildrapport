import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_pin.dart';
import 'package:wildrapport/utils/species_icon_utils.dart';
import 'package:wildrapport/utils/interaction_type_display.dart';
import 'package:wildrapport/utils/api_datetime.dart';
import 'package:wildrapport/utils/interaction_animal_count_store.dart';

class AnimalDetailCard extends StatelessWidget {
  static const double _cardHeight = 205;
  static const double _imageWidth = 150;

  final AnimalPin? animal;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const AnimalDetailCard({
    super.key,
    this.animal,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = animal?.speciesName ?? 'Onbekend dier';
    final cachedCount =
        animal != null ? InteractionAnimalCountStore.peek(animal!.id) : null;
    final rawCount = animal?.animalCount;
    final resolved = [
      rawCount ?? 0,
      cachedCount ?? 0,
    ].reduce((a, b) => a > b ? a : b);
    final displayCount = resolved > 0 ? resolved : 1;
    final formattedDate = formatLocalDate(animal?.seenAt);
    final formattedTime = formatLocalTime(animal?.seenAt);

    final iconPath = animal?.speciesName != null
    ? getSpeciesCardImagePath(animal!.speciesName!)
    : null;

    final locationLabel = animal != null
        ? '${animal!.lat.toStringAsFixed(5)}, ${animal!.lon.toStringAsFixed(5)}'
        : 'Onbekende locatie';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: SizedBox(
        height: _cardHeight,
        child: Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          elevation: 0,
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: Color(0xFF999999),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: _imageWidth,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0D9C9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: _buildImage(iconPath),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reportTypeDisplayLabel(animal?.reportType),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildDetailColumn('Aantal', '$displayCount'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailColumn('Datum', formattedDate),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDetailColumn('Tijd', formattedTime),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              locationLabel,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 115, 115, 115),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String? iconPath) {
    if (iconPath != null && iconPath.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        child: Image.asset(
          iconPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.pets,
            size: 38,
            color: AppColors.primaryGreen,
          ),
        ),
      );
    }

    return const Icon(
      Icons.pets,
      size: 38,
      color: AppColors.primaryGreen,
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color.fromARGB(255, 115, 115, 115),
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
