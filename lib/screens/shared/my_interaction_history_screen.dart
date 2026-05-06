import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/data_managers/my_interaction_api.dart';
import 'package:wildrapport/models/api_models/my_interaction.dart';
import 'package:wildrapport/utils/location_label.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:intl/intl.dart';
import 'package:wildrapport/screens/shared/interaction_detail_screen.dart';
import 'package:wildrapport/managers/api_managers/interaction_types_manager.dart';
import 'package:wildrapport/models/api_models/interaction_type.dart';
import 'package:wildrapport/managers/waarneming_flow/animal_manager.dart';

class MyInteractionHistoryScreen extends StatefulWidget {
  const MyInteractionHistoryScreen({super.key});

  @override
  State<MyInteractionHistoryScreen> createState() =>
      _MyInteractionHistoryScreenState();
}

class _MyInteractionHistoryScreenState
    extends State<MyInteractionHistoryScreen> {
  late Future<List<MyInteraction>> _interactionsFuture;
  String _selectedFilterLabel = 'Alle';
  int? _selectedTypeId; // null => All
  List<InteractionType> _types = const [];

  @override
  void initState() {
    super.initState();
    final myInteractionApi = context.read<MyInteractionApi>();
    _interactionsFuture = myInteractionApi.getMyInteractions();

    // Fetch interaction types for dynamic filter options
    _fetchTypes();
  }

  Future<void> _fetchTypes() async {
    try {
      final typesManager = context.read<InteractionTypesManager>();
      final fetched = await typesManager.ensureFetched();
      if (!mounted) return;
      setState(() {
        _types = fetched;
      });
    } catch (_) {
      // Keep empty list on failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Mijn Interacties',
              rightIcon: null,
              showUserIcon: false,
              onLeftIconPressed: () => Navigator.of(context).pop(),
              iconColor: AppColors.textPrimary,
              textColor: AppColors.textPrimary,
              fontScale: 1.15,
              iconScale: 1.15,
              userIconScale: 1.15,
              useFixedText: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 20, color: AppColors.textPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryGreen, width: 1.5),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFilterLabel,
                          items: [
                            const DropdownMenuItem(
                              value: 'Alle',
                              child: Text('Alle'),
                            ),
                            ..._types.map(
                              (t) => DropdownMenuItem(
                                value: t.name,
                                child: Text(t.name),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val == null) return;
                            setState(() {
                              _selectedFilterLabel = val;
                              if (val == 'Alle') {
                                _selectedTypeId = null;
                              } else {
                                final match = _types.firstWhere(
                                  (t) => t.name == val,
                                  orElse: () => InteractionType(
                                    id: -1,
                                    name: val,
                                    description: '',
                                  ),
                                );
                                _selectedTypeId = match.id >= 0 ? match.id : null;
                              }
                            });
                          },
                          isExpanded: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<MyInteraction>>(
                future: _interactionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Fout bij het laden van interacties',
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.history,
                              color: AppColors.primaryGreen,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Geen interacties gevonden',
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'U heeft nog geen interacties gemeld',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    final all = snapshot.data!;
                    final interactions = _applyFilter(all);
                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: interactions.length,
                      itemBuilder: (context, index) {
                        return _InteractionCard(
                          interaction: interactions[index],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<MyInteraction> _applyFilter(List<MyInteraction> items) {
    final filtered =
        _selectedTypeId == null
            ? List<MyInteraction>.from(items)
            : items.where((i) => i.type.id == _selectedTypeId).toList();
    filtered.sort((a, b) => b.moment.compareTo(a.moment));
    return filtered;
  }
}

class _InteractionCard extends StatelessWidget {
  final MyInteraction interaction;

  const _InteractionCard({required this.interaction});

  String _dateOnly(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  String _timeOnly(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  String _speciesName() {
    return interaction.species.commonName.isNotEmpty
        ? interaction.species.commonName
        : interaction.species.name;
  }

  String _locationWithoutCoordinates(String locationText) {
    final withoutCoords = locationText.replaceAll(
      RegExp(r'\s*-?\d+(?:\.\d+)?\s*/\s*-?\d+(?:\.\d+)?'),
      '',
    );
    return withoutCoords.trim();
  }

  String? _animalImagePath() {
    return getAnimalPhotoPath(_speciesName());
  }

  (String, String) _titleAndPrimaryValue() {
    if (interaction.reportOfCollision != null) {
      final report = interaction.reportOfCollision!;
      return ('Dieraanrijding', '${report.involvedAnimals.length} dieren');
    } else if (interaction.reportOfDamage != null) {
      final report = interaction.reportOfDamage!;
      return ('Schademelding', report.belonging.isNotEmpty ? report.belonging : 'Onbekend');
    } else if (interaction.reportOfSighting != null) {
      final report = interaction.reportOfSighting!;
      return ('Waarneming', '${report.involvedAnimals.length} dieren');
    }
    return ('Interactie', '-');
  }

  int _animalCount() {
    if (interaction.reportOfCollision != null) {
      return interaction.reportOfCollision!.involvedAnimals.length;
    }
    if (interaction.reportOfSighting != null) {
      return interaction.reportOfSighting!.involvedAnimals.length;
    }
    return 1;
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 115, 115, 115)),
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
    final typeAndValue = _titleAndPrimaryValue();
    final locationText = formatFriendlyLocation(
      interaction.place.latitude,
      interaction.place.longitude,
    );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => InteractionDetailScreen(interaction: interaction),
          ),
        );
      },
      child: SizedBox(
        height: 205,
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
                child: () {
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
                  return const Icon(
                    Icons.pets,
                    size: 38,
                    color: AppColors.primaryGreen,
                  );
                }(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        typeAndValue.$1,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        _speciesName(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildDetailColumn('Aantal', '${_animalCount()}'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(child: _buildDetailColumn('Datum', _dateOnly(interaction.moment))),
                          const SizedBox(width: 8),
                          Expanded(child: _buildDetailColumn('Tijd', _timeOnly(interaction.moment))),
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
}
