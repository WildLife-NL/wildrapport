import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/data_apis/species_api_interface.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_gender_view_count_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/view_count_model.dart';
import 'package:wildrapport/models/api_models/species.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/utils/species_icon_utils.dart';
import 'package:wildrapport/widgets/animals/scrollable_animal_grid.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';

class SpeciesGridPickerScreen extends StatefulWidget {
  const SpeciesGridPickerScreen({
    super.key,
    this.title = 'Diersoort kiezen',
  });

  final String title;

  @override
  State<SpeciesGridPickerScreen> createState() =>
      _SpeciesGridPickerScreenState();
}

AnimalModel _animalModelFromSpecies(Species s) {
  final fileName = s.commonName
      .trim()
      .toLowerCase()
      .replaceAll(' ', '_')
      .replaceAll('-', '_');

  final path = 'assets/images/color-animals/$fileName.png';

  return AnimalModel(
    animalId: s.id,
    animalImagePath: path,
    animalName: s.commonName,
    category: s.category,
    genderViewCounts: [
      AnimalGenderViewCount(
        gender: AnimalGender.onbekend,
        viewCount: ViewCountModel(),
      ),
    ],
  );
}
class _SpeciesGridPickerScreenState extends State<SpeciesGridPickerScreen> {
  final ScrollController _scrollController = ScrollController();

  List<Species> _allSpecies = [];
  final Map<String, Species> _speciesById = {};
  List<AnimalModel> _displayAnimals = [];
  List<String> _categories = ['Alle'];
  String _selectedCategory = 'Alle';

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSpecies());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSpecies() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final speciesApi = context.read<SpeciesApiInterface>();
      final list = await speciesApi.getAllSpecies();

      if (!mounted) return;

      final cats = list.map((s) => s.category).toSet().toList()..sort();

      setState(() {
        _allSpecies = list;
        _speciesById
          ..clear()
          ..addEntries(list.map((s) => MapEntry(s.id, s)));
        _categories = ['Alle', ...cats];
        _selectedCategory = 'Alle';
        _loading = false;
      });

      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _applyFilters() {
    final filtered = _allSpecies.where((s) {
      if (_selectedCategory != 'Alle' && s.category != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();

    setState(() {
      _displayAnimals = filtered.map(_animalModelFromSpecies).toList();
    });
  }

  void _onCategoryChanged(String? value) {
    if (value == null) return;
    setState(() {
      _selectedCategory = value;
    });
    _applyFilters();
  }

  void _onAnimalSelected(AnimalModel animal) {
    final id = animal.animalId;
    if (id == null) return;

    final species = _speciesById[id];
    if (species != null) {
      Navigator.of(context).pop(species);
    }
  }

  void _handleBack() {
    Navigator.of(context).pop();
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
              leftIcon: Icons.arrow_back_ios,
              centerText: widget.title,
              rightIcon: null,
              showUserIcon: false,
              useFixedText: true,
              onLeftIconPressed: _handleBack,
              iconColor: AppColors.textPrimary,
              textColor: Colors.black,
              fontScale: 1.4,
              iconScale: 1.15,
              userIconScale: 1.15,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 12, 0, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selecteer diersoort:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(
                      color: Color(0xFF999999),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                          child: Text(
                            'Categorie',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                          ),
                        ),
                        Container(
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
                              value: _selectedCategory,
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
                              items: _categories
                                  .map(
                                    (category) => DropdownMenuItem<String>(
                                      value: category,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                          vertical: 8.0,
                                        ),
                                        child: Text(
                                          category,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _loading ? null : _onCategoryChanged,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ScrollableAnimalGrid(
                            animals: _displayAnimals,
                            isLoading: _loading,
                            error: _error,
                            scrollController: _scrollController,
                            onAnimalSelected: _onAnimalSelected,
                            onRetry: _loadSpecies,
                          ),
                        ),
                      ],
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
}