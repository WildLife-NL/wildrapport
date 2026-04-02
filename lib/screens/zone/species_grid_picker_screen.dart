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
import 'package:wildrapport/widgets/shared_ui_widgets/bottom_app_bar.dart';

/// Zelfde patroon als [AnimalsScreen]: app bar, categorie, zoeken, icoon-grid.
/// Pop met `Navigator.pop(context, Species)` bij een keuze.
class SpeciesGridPickerScreen extends StatefulWidget {
  const SpeciesGridPickerScreen({
    super.key,
    this.title = 'Selecteer diersoort',
  });

  final String title;

  @override
  State<SpeciesGridPickerScreen> createState() =>
      _SpeciesGridPickerScreenState();
}

AnimalModel _animalModelFromSpecies(Species s) {
  final path = getSpeciesIconPath(s.commonName);
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
  final TextEditingController _searchController = TextEditingController();

  List<Species> _allSpecies = [];
  final Map<String, Species> _speciesById = {};
  List<AnimalModel> _displayAnimals = [];
  List<String> _categories = const [];
  String _selectedCategory = 'Alle';

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSpecies());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _applyFilters() {
    if (!mounted) return;
    final q = _searchController.text.trim().toLowerCase();
    final filtered = _allSpecies.where((s) {
      if (_selectedCategory != 'Alle' && s.category != _selectedCategory) {
        return false;
      }
      if (q.isEmpty) return true;
      return s.commonName.toLowerCase().contains(q);
    }).toList();
    setState(() {
      _displayAnimals = filtered.map(_animalModelFromSpecies).toList();
    });
  }

  void _onCategoryChanged(String? val) {
    if (val == null) return;
    setState(() => _selectedCategory = val);
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
      backgroundColor: AppColors.lightMintGreen,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: null,
              centerText: widget.title,
              rightIcon: null,
              showUserIcon: false,
              useFixedText: true,
              onLeftIconPressed: _handleBack,
              iconColor: Colors.black,
              textColor: Colors.black,
              fontScale: 1.15,
              iconScale: 1.15,
              userIconScale: 1.15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  Container(
                    height: 44,
                    constraints: const BoxConstraints(
                      minWidth: 140,
                      maxWidth: 220,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.darkGreen,
                        width: 1.5,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isDense: true,
                        iconSize: 18,
                        value: _selectedCategory,
                        items: _categories
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Tooltip(
                                  message: c,
                                  waitDuration: const Duration(
                                    milliseconds: 500,
                                  ),
                                  child: Text(
                                    c,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        selectedItemBuilder: (ctx) => _categories
                            .map(
                              (c) => Align(
                                alignment: Alignment.centerLeft,
                                child: Tooltip(
                                  message: c,
                                  waitDuration: const Duration(
                                    milliseconds: 500,
                                  ),
                                  child: Text(
                                    c,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: _loading ? null : _onCategoryChanged,
                        isExpanded: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.lightMintGreen,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.darkGreen,
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.darkGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Zoeken',
                                border: InputBorder.none,
                                isCollapsed: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.clear,
                                          color: AppColors.darkGreen,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {});
                                        },
                                      )
                                    : null,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ScrollableAnimalGrid(
              animals: _displayAnimals,
              isLoading: _loading,
              error: _error,
              scrollController: _scrollController,
              onAnimalSelected: _onAnimalSelected,
              onRetry: _loadSpecies,
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: _handleBack,
        onNextPressed: null,
        showNextButton: false,
        showBackButton: true,
      ),
    );
  }
}
