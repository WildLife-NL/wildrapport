import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/providers/submitted_sightings_provider.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/screens/logbook/viewing_summary_screen.dart';

class RecentSightingsScreen extends StatefulWidget {
  const RecentSightingsScreen({super.key});

  @override
  State<RecentSightingsScreen> createState() => _RecentSightingsScreenState();
}

class _RecentSightingsScreenState extends State<RecentSightingsScreen> {
  String _selectedFilter = 'Alle';
  final List<String> _filterOptions = ['Alle', 'Waarneming', 'Schademelding', 'Dieraanrijding'];

  void _handleBackNavigation(BuildContext context) {
    Navigator.pop(context);
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
      final date = '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
      final time = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      return '$date | $time';
    } catch (e) {
      return 'Datum en tijd nog niet ingesteld';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F4),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomAppBar(
              centerText: 'Logboek',
              leftIcon: Icons.arrow_back_ios,
              rightIcon: null,
              showUserIcon: false,
              useFixedText: true,
              onLeftIconPressed: () => _handleBackNavigation(context),
              textColor: Colors.black,
              fontScale: 1.4,
              iconScale: 1.15,
              userIconScale: 1.15,
            ),
            Expanded(
              child: Consumer<SubmittedSightingsProvider>(
                builder: (context, provider, _) {
                  // Filter sightings based on selected filter
                  final filteredSightings = _filterSightings(provider.submittedSightings);

                  return Column(
                    children: [
                      // Filter dropdown
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.15),
                              width: 1.2,
                            ),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              highlightColor: const Color(0xFFE8ECE6),
                              splashColor: const Color(0xFFE8ECE6),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedFilter,
                              isExpanded: true,
                              underline: const SizedBox(),
                              borderRadius: BorderRadius.circular(12),
                              elevation: 8,
                              dropdownColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 5.0,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black.withValues(alpha: 0.6),
                                size: 24,
                              ),
                              items: _filterOptions
                                  .map((option) => DropdownMenuItem<String>(
                                    value: option,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 8.0,
                                      ),
                                      child: Text(
                                        option,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedFilter = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      // Sightings list
                      Expanded(
                        child: filteredSightings.isEmpty
                            ? Center(
                              child: Text(
                                'Geen meldingen ingediend',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredSightings.length,
                              itemBuilder: (context, index) {
                                final sighting = filteredSightings[index];
                                final isSchademelding = sighting.reportType == 'gewasschade';
                                final isDieraanrijding = sighting.reportType == 'verkeersongeval';

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewingSummaryScreen(sighting: sighting),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      height: 220,
                                      child: Card(
                                        elevation: 0,
                                        color: Colors.white,
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
                                            // Image section
                                            isSchademelding
                                                ? _buildSchademeldingImageSection(sighting)
                                                : isDieraanrijding
                                                    ? _buildDieraanrijdingImageSection(sighting)
                                                    : _buildImageSection(
                                                        sighting.animals?.isNotEmpty == true
                                                            ? sighting.animals!.first.animalImagePath
                                                            : null),
                                            const SizedBox(width: 12),
                                            // Details section
                                            isSchademelding
                                                ? _buildSchademeldingDetailsSection(sighting)
                                                : isDieraanrijding
                                                    ? _buildDieraanrijdingDetailsSection(sighting)
                                                    : _buildDetailsSection(sighting),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _filterSightings(List<dynamic> sightings) {
    if (_selectedFilter == 'Alle') {
      return sightings;
    }
    
    return sightings.where((sighting) {
      if (_selectedFilter == 'Waarneming') {
        return sighting.reportType == 'waarneming';
      } else if (_selectedFilter == 'Schademelding') {
        return sighting.reportType == 'gewasschade';
      } else if (_selectedFilter == 'Dieraanrijding') {
        return sighting.reportType == 'verkeersongeval';
      }
      return true;
    }).toList();
  }

  Widget _buildImageSection(String? imagePath) {
    debugPrint('[RecentSightings._buildImageSection] imagePath: $imagePath');
    
    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: const Color(0xFFE0D9C9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        border: Border.all(
          color: Colors.grey[400] ?? Colors.grey,
          width: 2,
        ),
      ),
      child: (imagePath != null && imagePath.isNotEmpty)
          ? ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('[RecentSightings] Error loading image at $imagePath: $error');
                  return Icon(
                    Icons.pets,
                    size: 40,
                    color: Colors.grey[400],
                  );
                },
              ),
            )
          : Center(
              child: Icon(
                Icons.pets,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
    );
  }

  Widget _buildDetailsSection(dynamic sighting) {
    final animalName = sighting.animals?.isNotEmpty == true
        ? sighting.animals!.first.animalName
        : 'Dier';
    final animalImagePath = sighting.animals?.isNotEmpty == true
        ? sighting.animals!.first.animalImagePath
        : null;
    final aantal = sighting.animals?.length ?? 0;
    final location = _getLocationDisplay(sighting.locations);
    final dateTime = _getDateTimeDisplay(sighting.dateTime);

    debugPrint('[RecentSightings] ==== SIGHTING DETAILS ====');
    debugPrint('[RecentSightings] Animal name: $animalName');
    debugPrint('[RecentSightings] Original image path: $animalImagePath');
    debugPrint('[RecentSightings] Is path null: ${animalImagePath == null}');
    debugPrint('[RecentSightings] Is path empty: ${animalImagePath?.isEmpty ?? "N/A"}');
    debugPrint('[RecentSightings] ==== END SIGHTING ====');

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              sighting.reportType == 'verkeersongeval' ? 'Dieraanrijding' : sighting.reportType == 'gewasschade' ? 'Schademelding' : 'Waarneming',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              animalName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            _buildMetadataRow([
              ('Aantal', '$aantal'),
            ]),
            const SizedBox(height: 4),
            _buildMetadataRow([
              ('Datum', dateTime.split('|')[0].trim()),
              ('Tijd', dateTime.split('|').length > 1 ? dateTime.split('|')[1].trim() : ''),
            ]),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.location_on, location),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(List<(String, String)> items) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _buildDetailColumn(items[i].$1, items[i].$2),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 115, 115, 115)),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 115, 115, 115),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSchademeldingDetailColumn(String label, String value, {double valueFontSize = 14}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 115, 115, 115)),
        ),
        Text(
          value,
          style: TextStyle(fontSize: valueFontSize, fontWeight: FontWeight.bold, color: Colors.black),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSchademeldingImageSection(dynamic sighting) {
    final animalImagePath = sighting.animalSelected?.animalImagePath;

    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: const Color(0xFFE0D9C9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        border: Border.all(
          color: Colors.grey[400] ?? Colors.grey,
          width: 2,
        ),
      ),
      child: (animalImagePath != null && animalImagePath.isNotEmpty)
          ? ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.asset(
                animalImagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('[RecentSightings] Error loading animal image at $animalImagePath: $error');
                  return Icon(
                    Icons.pets,
                    size: 40,
                    color: Colors.grey[400],
                  );
                },
              ),
            )
          : Center(
              child: Icon(
                Icons.pets,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
    );
  }

  Widget _buildSchademeldingDetailsSection(dynamic sighting) {
    final animalName = sighting.animalSelected?.animalName ?? 'Onbekend';
    final cropType = sighting.cropType ?? 'Onbekend';
    final expectedLoss = sighting.expectedLoss ?? 'Onbekend';
    final location = _getLocationDisplay(sighting.locations);
    final dateTime = _getDateTimeDisplay(sighting.dateTime);
    final dateParts = dateTime.split('|');
    final date = dateParts.isNotEmpty ? dateParts[0].trim() : '';
    final time = dateParts.length > 1 ? dateParts[1].trim() : '';

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Schademelding',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              cropType,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            // Two columns: Verdachte dier | Geschat verlies
            Row(
              children: [
                Expanded(
                  child: _buildSchademeldingDetailColumn(
                    'Verdachte dier',
                    animalName,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSchademeldingDetailColumn(
                    'Geschat verlies',
                    expectedLoss,
                    valueFontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Two columns: Datum | Tijd
            Row(
              children: [
                Expanded(
                  child: _buildSchademeldingDetailColumn(
                    'Datum',
                    date,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSchademeldingDetailColumn(
                    'Tijd',
                    time,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.location_on, location),
          ],
        ),
      ),
    );
  }

  Widget _buildDieraanrijdingImageSection(dynamic sighting) {
    final animalImagePath = sighting.animalSelected?.animalImagePath;

    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: const Color(0xFFE0D9C9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        border: Border.all(
          color: Colors.grey[400] ?? Colors.grey,
          width: 2,
        ),
      ),
      child: (animalImagePath != null && animalImagePath.isNotEmpty)
          ? ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.asset(
                animalImagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.pets,
                    size: 40,
                    color: Colors.grey[400],
                  );
                },
              ),
            )
          : Center(
              child: Icon(
                Icons.pets,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
    );
  }

  Widget _buildDieraanrijdingDetailsSection(dynamic sighting) {
    final animalName = sighting.animalSelected?.animalName ?? 'Onbekend';
    final accidentSeverity = sighting.accidentSeverity ?? 'Onbekend';
    final location = _getLocationDisplay(sighting.locations);
    final dateTime = _getDateTimeDisplay(sighting.dateTime);
    final dateParts = dateTime.split('|');
    final date = dateParts.isNotEmpty ? dateParts[0].trim() : '';
    final time = dateParts.length > 1 ? dateParts[1].trim() : '';

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Dieraanrijding',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              animalName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _buildSchademeldingDetailColumn(
                    'Ernst',
                    accidentSeverity,
                    valueFontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: _buildSchademeldingDetailColumn(
                    'Datum',
                    date,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSchademeldingDetailColumn(
                    'Tijd',
                    time,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.location_on, location),
          ],
        ),
      ),
    );
  }
}
