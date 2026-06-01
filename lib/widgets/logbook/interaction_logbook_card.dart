import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/managers/waarneming_flow/animal_manager.dart';
import 'package:wildrapport/models/api_models/my_interaction.dart';
import 'package:wildrapport/screens/shared/interaction_detail_screen.dart';
import 'package:wildrapport/utils/location_label.dart';
import 'package:wildrapport/utils/involved_animal_count.dart';

/// Logbook list row for a single [MyInteraction] from `interactions/me`.
class InteractionLogbookCard extends StatelessWidget {
  final MyInteraction interaction;
  final double height;

  const InteractionLogbookCard({
    super.key,
    required this.interaction,
    this.height = 205,
  });

  String _speciesName() {
    return interaction.species.commonName.isNotEmpty
        ? interaction.species.commonName
        : interaction.species.name;
  }

  String? _animalImagePath() {
    return getAnimalPhotoPath(_speciesName());
  }

  (String typeLabel, String subtitle) _typeLabelAndSubtitle() {
    final count = countFromMyInteraction(interaction);
    if (interaction.reportOfCollision != null) {
      return ('Dieraanrijding', count > 0 ? '$count dieren' : '—');
    }
    if (interaction.reportOfDamage != null) {
      final report = interaction.reportOfDamage!;
      final belonging =
          report.belonging.isNotEmpty ? report.belonging : 'Onbekend';
      return ('Schademelding', belonging);
    }
    if (interaction.reportOfSighting != null) {
      return ('Waarneming', count > 0 ? '$count dieren' : '—');
    }
    return (interaction.type.name.isNotEmpty ? interaction.type.name : 'Melding', '—');
  }

  int _animalCount() => countFromMyInteraction(interaction);

  static String _dateOnly(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  static String _timeOnly(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String _locationWithoutCoordinates(String locationText) {
    return locationText
        .replaceAll(
          RegExp(r'\s*-?\d+(?:\.\d+)?\s*/\s*-?\d+(?:\.\d+)?'),
          '',
        )
        .trim();
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final typeInfo = _typeLabelAndSubtitle();
    final locationText = formatFriendlyLocation(
      interaction.place.latitude,
      interaction.place.longitude,
    );
    final countLabel =
        interaction.reportOfDamage != null ? 'Verdachte dieren' : 'Aantal';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                InteractionDetailScreen(interaction: interaction),
          ),
        );
      },
      child: SizedBox(
        height: height,
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF999999), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 150,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0D9C9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: _buildImage(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        typeInfo.$1,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        _speciesName().isNotEmpty ? _speciesName() : typeInfo.$2,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      _buildDetailColumn(countLabel, '${_animalCount()}'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailColumn(
                              'Datum',
                              _dateOnly(interaction.moment),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDetailColumn(
                              'Tijd',
                              _timeOnly(interaction.moment),
                            ),
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
                              _locationWithoutCoordinates(locationText),
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

  Widget _buildImage() {
    final imagePath = _animalImagePath();
    if (imagePath != null && imagePath.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.pets,
            size: 38,
            color: AppColors.primaryGreen,
          ),
        ),
      );
    }
    return const Icon(Icons.pets, size: 38, color: AppColors.primaryGreen);
  }
}
