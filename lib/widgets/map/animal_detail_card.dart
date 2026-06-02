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
        animal?.groupSummary ??
        '$displayCount ${displayCount == 1 ? 'dier' : 'dieren'}';

    final iconPath = animal?.speciesName != null
        ? getSpeciesCardImagePath(animal!.speciesName!)
        : null;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: SizedBox(
        height: _cardHeight,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  padding: const EdgeInsets.fromLTRB(16, 12, 14, 11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _reportTypePill(animal?.reportType),
                      const SizedBox(height: 7),
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          height: 1.0,
                          letterSpacing: -0.4,
                        ),
                      ),
                      if (latinName.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          latinName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF777777),
                            height: 1.15,
                          ),
                        ),
                      ],
                      const SizedBox(height: 13),
                      _infoRow(
                        icon: Icons.pets,
                        child: Text(
                          groupSummary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimary,
                            height: 1.18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _dateTimeRow(formattedDate, formattedTime),
                      const Spacer(),
                      const Divider(
                        height: 12,
                        thickness: 1,
                        color: Color(0xFFE8E8E8),
                      ),
                      _infoRow(
                        icon: Icons.person_outline,
                        iconSize: 17,
                        child: RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF777777),
                              height: 1.2,
                            ),
                            children: [
                              const TextSpan(text: 'Gemeld door: '),
                              TextSpan(
                                text: reportedBy,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Color _reportTypeColor(String? reportType) {
    switch (reportType?.toLowerCase()) {
      case 'waarneming':
        return const Color(0xFF8613A8);
      case 'gewasschade':
        return const Color(0xFF008C7B);
      case 'verkeersongeval':
        return const Color(0xFF0078DA);
      case 'collar':
        return const Color(0xFFFE008E);
      case 'camera':
        return const Color(0xFF00BFD8);
      case 'acoustic':
        return const Color(0xFFFF9100);
      default:
        return const Color(0xFF777777);
    }
  }

  Widget _reportTypePill(String? reportType) {
    final color = _reportTypeColor(reportType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.45),
          width: 1,
        ),
      ),
      child: Text(
        reportTypeDisplayLabel(reportType).toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: color,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _dateTimeRow(String formattedDate, String formattedTime) {
    return Row(
      children: [
        _smallIcon(Icons.calendar_today_outlined),
        const SizedBox(width: 5),
        Text(
          formattedDate,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 14),
        _smallIcon(Icons.access_time),
        const SizedBox(width: 5),
        Text(
          formattedTime,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required Widget child,
    double iconSize = 16,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _smallIcon(icon, size: iconSize),
        const SizedBox(width: 7),
        Expanded(child: child),
      ],
    );
  }

  Widget _smallIcon(IconData icon, {double size = 14}) {
    return Icon(
      icon,
      size: size,
      color: const Color(0xFF777777),
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
            color: AppColors.darkCharcoal,
          ),
        ),
      );
    }

    return const Icon(
      Icons.pets,
      size: 38,
      color: AppColors.darkCharcoal,
    );
  }
}
