import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/animal_interface.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/dropdown_interface.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/enums/dropdown_type.dart';
import 'package:wildrapport/screens/animal_gender_screen.dart';
import 'package:wildrapport/screens/category_screen.dart';
import 'package:wildrapport/screens/report_decision_screen.dart';
import 'package:wildrapport/widgets/animal_grid.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:lottie/lottie.dart';

class AnimalsScreen extends StatefulWidget {
  final String appBarTitle;

  const AnimalsScreen({
    super.key, 
    required this.appBarTitle,
  });

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> with SingleTickerProviderStateMixin {
  late final AnimalManagerInterface _animalManager;
  late final AnimalSightingReportingInterface _animalSightingManager;
  late final NavigationStateInterface _navigationManager;
  late final AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  List<AnimalModel>? _animals;
  String? _error;
  bool _isLoading = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[AnimalsScreen] Initializing screen');
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Set a default duration
    );
    _animalManager = context.read<AnimalManagerInterface>();
    _animalSightingManager = context.read<AnimalSightingReportingInterface>();
    _navigationManager = context.read<NavigationStateInterface>();
    _animalManager.addListener(_handleStateChange);
    _validateAndLoad();
  }

  void _validateAndLoad() {
    if (!_animalSightingManager.validateActiveAnimalSighting()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geen actieve animalSighting gevonden'),
            backgroundColor: Colors.red,
          ),
        );
      });
      return;
    }
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    debugPrint('[AnimalsScreen] Starting to load animals');
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final animals = await _animalManager.getAnimals();
      debugPrint('[AnimalsScreen] Successfully loaded ${animals.length} animals');
      
      if (mounted) {
        setState(() {
          _animals = animals;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('[AnimalsScreen] ERROR: Failed to load animals');
      debugPrint('[AnimalsScreen] Error details: $e');
      debugPrint('[AnimalsScreen] Stack trace: $stackTrace');
      
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
    debugPrint('[AnimalsScreen] Disposing screen');
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

  void _toggleExpanded() {
    debugPrint('[AnimalsScreen] Toggling expanded state from $_isExpanded to ${!_isExpanded}');
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _handleAnimalSelection(AnimalModel selectedAnimal) {
    final updatedSighting = _animalSightingManager.processAnimalSelection(
      selectedAnimal,
      _animalManager,
    );
    
    _navigationManager.pushReplacementForward(
      context,
      ReportDecisionScreen(),
    );
  }

  void _handleBackNavigation() {
    debugPrint('[AnimalsScreen] Back button pressed');
    _navigationManager.dispose(); // Call dispose first to clean up resources
    _navigationManager.pushReplacementBack(
      context,
      const CategoryScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dropdownInterface = context.read<DropdownInterface>();
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: widget.appBarTitle,
              rightIcon: Icons.menu,
              onLeftIconPressed: _handleBackNavigation,
              onRightIconPressed: () {/* Handle menu */},
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: dropdownInterface.buildDropdown(
                type: DropdownType.filter,
                selectedValue: _animalManager.getSelectedFilter(),
                isExpanded: _isExpanded,
                onExpandChanged: (_) => _toggleExpanded(),
                onOptionSelected: _animalManager.updateFilter,
                context: context,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Lottie.asset(
            'assets/loaders/loading_paw.json',
            fit: BoxFit.contain,
            repeat: true,
            animate: true,
            frameRate: FrameRate(60),
            controller: _animationController,
            onLoaded: (composition) {
              _animationController.duration = composition.duration;
              _animationController.repeat(); // Start repeating animation after composition is loaded
            },
          ),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAnimals,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_animals == null || _animals!.isEmpty) {
      return const Center(
        child: Text('No animals found'),
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: AnimalGrid(
        animals: _animals!,
        onAnimalSelected: _handleAnimalSelection,
      ),
    );
  }
}



























