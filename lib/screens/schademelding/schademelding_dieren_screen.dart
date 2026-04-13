import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_interface.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_model.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/widgets/animals/scrollable_animal_grid.dart';
import 'package:wildrapport/screens/schademelding/schademelding_damage_details_screen.dart';

class SchademeldingDierenScreen extends StatefulWidget {
  final String gewasType;

  const SchademeldingDierenScreen({super.key, required this.gewasType});

  @override
  State<SchademeldingDierenScreen> createState() =>
      _SchademeldingDierenScreenState();
}

class _SchademeldingDierenScreenState extends State<SchademeldingDierenScreen>
    with SingleTickerProviderStateMixin {
  late final AnimalManagerInterface _animalManager;
  late final AnimalSightingReportingInterface _animalSightingManager;
  late final NavigationStateInterface _navigationManager;
  late final AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  List<AnimalModel>? _animals;
  String? _error;
  bool _isLoading = true;
  List<String> _categories = ['Alle'];
  String _selectedCategory = 'Alle';

  @override
  void initState() {
    super.initState();
    debugPrint('[SchademeldingDieren] Initializing screen');
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animalManager = context.read<AnimalManagerInterface>();
    _animalSightingManager = context.read<AnimalSightingReportingInterface>();
    _navigationManager = context.read<NavigationStateInterface>();
    _animalManager.addListener(_handleStateChange);
    _validateAndLoad();
    _loadCategories();
  }

  void _validateAndLoad() {
    final isValid = _animalSightingManager.validateActiveAnimalSighting();
    if (!isValid) {
      debugPrint(
          '[SchademeldingDieren] No active animal sighting - attempting to initialize');
    }
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    debugPrint('[SchademeldingDieren] Starting to load animals');
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      debugPrint(
          '[SchademeldingDieren] Calling getAnimalsByBackendCategory with category: $_selectedCategory');
      final animals = await _animalManager.getAnimalsByBackendCategory(
        category: _selectedCategory == 'Alle' ? null : _selectedCategory,
      );

      debugPrint('[SchademeldingDieren] API returned ${animals.length} animals');

      final filtered = animals.where((a) {
        final name = a.animalName.trim().toLowerCase();
        final id = (a.animalId ?? '').trim().toLowerCase();
        return name != 'onbekend' && id != 'unknown';
      }).toList();

      debugPrint(
        '[SchademeldingDieren] Successfully loaded ${animals.length} animals (showing ${filtered.length} after filtering unknown)',
      );

      if (mounted) {
        setState(() {
          _animals = filtered;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('[SchademeldingDieren] ERROR: Failed to load animals');
      debugPrint('[SchademeldingDieren] Error details: $e');
      debugPrint('[SchademeldingDieren] Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    debugPrint('[SchademeldingDieren] Disposing screen');
    _scrollController.dispose();
    _animationController.dispose();
    _animalManager.removeListener(_handleStateChange);
    super.dispose();
  }

  void _handleStateChange() {
    if (mounted) {
      _loadAnimals();
    }
  }

  void _handleAnimalSelection(AnimalModel selectedAnimal) {
    _animalSightingManager.processAnimalSelection(
      selectedAnimal,
      _animalManager,
    );

    debugPrint(
        '[SchademeldingDieren] Selected animal: ${selectedAnimal.animalName} for gewas type: ${widget.gewasType}');
    // Navigate to damage details screen
    _navigationManager.pushForward(
      context,
      SchademeldingDamageDetailsScreen(gewasType: widget.gewasType),
    );
  }

  void _handleBackNavigation() {
    debugPrint('[SchademeldingDieren] Back button pressed');
    _animalManager.updateSearchTerm('');
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    } else {
      _navigationManager.resetToHome(context);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _animalManager.getBackendCategories();
      if (mounted) {
        setState(() {
          _categories = ['Alle', ...categories];
        });
      }
    } catch (e) {
      debugPrint('[SchademeldingDieren] Error loading categories: $e');
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
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Schademelding',
              rightIcon: null,
              showUserIcon: false,
              useFixedText: true,
              onLeftIconPressed: _handleBackNavigation,
              iconColor: Colors.black,
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
                  'Selecteer het verdachte dier:',
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
                    side: BorderSide(
                      color: const Color(0xFF999999),
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
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
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
                                  .map((category) => DropdownMenuItem<String>(
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
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                  _loadAnimals();
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ScrollableAnimalGrid(
                            animals: _animals,
                            isLoading: _isLoading,
                            error: _error,
                            scrollController: _scrollController,
                            onAnimalSelected: _handleAnimalSelection,
                            onRetry: _loadAnimals,
                            selectedAnimal: _animalSightingManager.getCurrentanimalSighting()?.animalSelected,
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
