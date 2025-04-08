import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/animal_interface.dart';
import 'package:wildrapport/interfaces/dropdown_interface.dart';
import 'package:wildrapport/interfaces/waarneming_reporting_interface.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/enums/dropdown_type.dart';
import 'package:wildrapport/models/waarneming_model.dart';
import 'package:wildrapport/screens/animal_gender_screen.dart';
import 'package:wildrapport/widgets/animal_grid.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:lottie/lottie.dart';

class AnimalsScreen extends StatefulWidget {
  final String appBarTitle;
  final WaarnemingModel? waarnemingModel;

  const AnimalsScreen({
    super.key, 
    required this.appBarTitle,
    this.waarnemingModel,
  });

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  late final AnimalManagerInterface _animalManager;
  late final WaarnemingReportingInterface _waarnemingManager;
  List<AnimalModel>? _animals;
  String? _error;
  bool _isLoading = true;
  bool _isExpanded = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    debugPrint('[AnimalsScreen] Initializing screen');
    _animalManager = context.read<AnimalManagerInterface>();
    _waarnemingManager = context.read<WaarnemingReportingInterface>();
    _animalManager.addListener(_handleStateChange);
    
    if (widget.waarnemingModel != null) {
      debugPrint('[AnimalsScreen] Initialized with WaarnemingModel: ${widget.waarnemingModel!.toJson()}');
      // Instead of creating new, update the existing waarneming
      if (widget.waarnemingModel?.animals?.isNotEmpty == true) {
        _waarnemingManager.updateSelectedAnimal(widget.waarnemingModel!.animals!.first);
      }
    } else {
      debugPrint('[AnimalsScreen] Initialized without WaarnemingModel');
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
    debugPrint('[AnimalsScreen] Animal selected: ${selectedAnimal.animalName}');
    debugPrint('[AnimalsScreen] Current waarneming before update: ${_waarnemingManager.getCurrentWaarneming()?.toJson()}');
    
    try {
      // Update the animal using the manager
      final updatedWaarneming = _waarnemingManager.updateSelectedAnimal(selectedAnimal);
      
      debugPrint('[AnimalsScreen] Successfully updated animal');
      debugPrint('[AnimalsScreen] Updated waarneming state: ${updatedWaarneming.toJson()}');

      // Navigate to the gender selection screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnimalGenderScreen(
            waarneming: updatedWaarneming,
          ),
        ),
      );
    } catch (e) {
      debugPrint('[AnimalsScreen] Error updating animal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Er is een fout opgetreden bij het selecteren van het dier'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              onLeftIconPressed: () => Navigator.pop(context),
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





