import 'package:flutter/material.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_sighting_model.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';

class SightingDetailScreen extends StatelessWidget {
  final AnimalSightingModel sighting;

  const SightingDetailScreen({super.key, required this.sighting});

  void _handleBackNavigation(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    }
  }

  String _getGenderDisplay(AnimalGender gender) {
    switch (gender) {
      case AnimalGender.mannelijk:
        return 'Mannelijk';
      case AnimalGender.vrouwelijk:
        return 'Vrouwelijk';
      case AnimalGender.onbekend:
        return 'Onbekend';
    }
  }

  String _getLocationDisplay(List? locations) {
    if (locations?.isEmpty != false) {
      return 'Locatie nog niet ingesteld';
    }
    final loc = locations!.first;
    if (loc.streetName != null && loc.houseNumber != null) {
      return '${loc.streetName} ${loc.houseNumber}, ${loc.cityName ?? ""}';
    } else if (loc.streetName != null) {
      return '${loc.streetName}, ${loc.cityName ?? ""}';
    } else if (loc.cityName != null) {
      return loc.cityName!;
    }
    if (loc.latitude != null && loc.longitude != null) {
      return '${loc.latitude?.toStringAsFixed(2)}, ${loc.longitude?.toStringAsFixed(2)}';
    }
    return 'Locatie nog niet ingesteld';
  }

  String _getDateTimeDisplay(dynamic dateTimeModel) {
    if (dateTimeModel == null) {
      return 'Datum en tijd nog niet ingesteld';
    }
    try {
      final dt = dateTimeModel.dateTime as DateTime?;
      if (dt == null) {
        return 'Datum en tijd nog niet ingesteld';
      }
      final date =
          '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
      final time =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      return '$date | $time';
    } catch (e) {
      return 'Datum en tijd nog niet ingesteld';
    }
  }

  @override
  Widget build(BuildContext context) {
    final animalName = sighting.animals?.isNotEmpty == true
        ? sighting.animals!.first.animalName
        : 'Dier';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F4),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomAppBar(
              centerText: 'Waarneming',
              leftIcon: Icons.arrow_back_ios,
              rightIcon: null,
              showUserIcon: false,
              useFixedText: true,
              onLeftIconPressed: () => _handleBackNavigation(context),
              textColor: Colors.black,
              iconColor: Colors.black,
              fontScale: 1.4,
              iconScale: 1.15,
              userIconScale: 1.15,
            ),
            // Main card container
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: const Color(0xFF999999),
                      width: 1,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Heading
                          const Text(
                            'Overzicht',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Animal info card (compact)
                          Center(
                            child: SizedBox(
                              width: 140,
                              child: Card(
                                shadowColor: const Color.fromARGB(133, 0, 0, 0)
                                    .withValues(alpha: 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: const Color(0xFF999999),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Image area
                                    Center(
                                      child: SizedBox(
                                        width: 140,
                                        height: 120,
                                        child: AspectRatio(
                                          aspectRatio: 1.0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(14),
                                                topRight: Radius.circular(14),
                                              ),
                                              color: Colors.white,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(14),
                                                topRight: Radius.circular(14),
                                              ),
                                              child: SizedBox.expand(
                                                child: sighting.animals
                                                            ?.isNotEmpty ==
                                                        true
                                                    ? (sighting.animals!.first
                                                                .animalImagePath !=
                                                            null
                                                        ? Image(
                                                            image: AssetImage(
                                                              sighting.animals!
                                                                  .first
                                                                  .animalImagePath!,
                                                            ),
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Center(
                                                            child: Icon(
                                                              Icons
                                                                  .image_not_supported_outlined,
                                                              size: 50,
                                                              color: Colors
                                                                  .grey[400],
                                                            ),
                                                          ))
                                                    : Center(
                                                        child: Icon(
                                                          Icons
                                                              .image_not_supported_outlined,
                                                          size: 50,
                                                          color:
                                                              Colors.grey[400],
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Divider line
                                    Container(
                                      height: 1,
                                      color: const Color(0xFF999999),
                                      width: 140,
                                    ),
                                    // Name area
                                    Container(
                                      width: 140,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(14),
                                          bottomRight: Radius.circular(14),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        animalName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Total aantal
                          Text(
                            'Aantal: ${sighting.animals?.length ?? 0}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Animal details
                          ..._buildAnimalDetailsList(sighting.animals ?? []),
                          const SizedBox(height: 16),
                          // Divider line
                          Container(
                            height: 1,
                            color: const Color(0xFF999999),
                          ),
                          const SizedBox(height: 16),
                          // Location and DateTime info
                          Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Color(0xFFE8E8E8),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Location
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0F0F0),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.location_on, size: 18, color: Colors.grey[700]),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Locatie',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              _getLocationDisplay(sighting.locations),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Divider(
                                    color: Colors.grey.withValues(alpha: 0.15),
                                    height: 1,
                                    thickness: 1,
                                  ),
                                  const SizedBox(height: 14),
                                  // Date/Time
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0F0F0),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.calendar_today, size: 18, color: Colors.grey[700]),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Datum & Tijd',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              _getDateTimeDisplay(sighting.dateTime),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAnimalDetailsList(List animals) {
    final details = <Widget>[];

    if (animals.isEmpty) {
      return [
        const Center(
          child: Text(
            'Geen dier details beschikbaar',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      ];
    }

    int animalIndex = 1;
    int totalAnimals = 0;
    
    // Count total animals
    for (final animal in animals) {
      if (animal?.genderViewCounts == null || animal.genderViewCounts.isEmpty) {
        continue;
      }
      totalAnimals += (animal.genderViewCounts.length as int);
    }
    
    int currentAnimalCount = 0;

    for (final animal in animals) {
      if (animal?.genderViewCounts == null || animal.genderViewCounts.isEmpty) {
        continue;
      }

      for (final genderViewCount in animal.genderViewCounts) {
        final gender = _getGenderDisplay(genderViewCount.gender);
        final viewCount = genderViewCount.viewCount;

        String age = 'Onbekend';
        if (viewCount.pasGeborenAmount > 0) {
          age = 'Pas geboren';
        } else if (viewCount.onvolwassenAmount > 0) {
          age = 'Jong';
        } else if (viewCount.volwassenAmount > 0) {
          age = 'Volwassen';
        }

        details.add(
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.pets, size: 18, color: Colors.grey[700]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dier $animalIndex',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$gender, $age',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        currentAnimalCount++;
        
        // Add divider between animals (but not after the last one)
        if (currentAnimalCount < totalAnimals) {
          details.add(const SizedBox(height: 14));
          details.add(
            Divider(
              color: Colors.grey.withValues(alpha: 0.15),
              height: 1,
              thickness: 1,
            ),
          );
          details.add(const SizedBox(height: 14));
        }

        animalIndex++;
      }
    }

    if (details.isEmpty) {
      return [
        const Center(
          child: Text(
            'Geen dier details beschikbaar',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      ];
    }

    return details;
  }
}
