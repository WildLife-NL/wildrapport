import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_pin.dart';
import 'package:wildrapport/utils/species_icon_utils.dart';
import 'package:wildrapport/utils/interaction_type_display.dart';
import 'package:wildrapport/utils/api_datetime.dart';
import 'package:wildrapport/utils/interaction_animal_count_store.dart';

class AnimalDetailCard extends StatelessWidget {
  static const double _cardHeight = 230;
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
    final reportedBy = animal?.reportedByName ?? 'Onbekende gebruiker';
    final displayName = animal?.speciesName ?? 'Onbekend dier';
    final latinName = animal?.speciesLatinName ?? '';
    //print('POPUP LATIN NAME: $latinName');
    print(
  'Popup -> type=${animal?.reportType} '
  'common=${animal?.speciesName} '
  'latin=${animal?.speciesLatinName}'
);
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
    final groupSummary =
    animal?.groupSummary ?? '$displayCount ${displayCount == 1 ? 'dier' : 'dieren'}';

    final iconPath = animal?.speciesName != null
    ? getSpeciesCardImagePath(animal!.speciesName!)
    : null;

    

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
                      RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: displayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            if (latinName.isNotEmpty)
                              TextSpan(
                                text: ' ($latinName)',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F7F1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          groupSummary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Color.fromARGB(255, 115, 115, 115),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Color.fromARGB(255, 115, 115, 115),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedTime,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      const Spacer(), 
                      Row(
                        children: [
                          //const Icon(Icons.person_outline, size: 14),
                          //const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Gemeld door: $reportedBy',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
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
