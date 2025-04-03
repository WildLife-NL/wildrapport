import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/animal_interface.dart';
import 'package:wildrapport/interfaces/dropdown_interface.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/enums/dropdown_type.dart';
import 'package:wildrapport/widgets/animal_grid.dart';
import 'package:wildrapport/widgets/app_bar.dart';

class AnimalsScreen extends StatefulWidget {
  final String screenTitle;

  const AnimalsScreen({
    required this.screenTitle,
    super.key,
  });

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  late final ScrollController _scrollController;
  late final AnimalManagerInterface _animalManager;
  bool _isExpanded = false;
  bool _isLoading = true;
  String? _error;
  List<AnimalModel>? _animals;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animalManager = context.read<AnimalManagerInterface>();
    _animalManager.addListener(_handleStateChange);
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final animals = await _animalManager.getAnimals();
      
      if (mounted) {
        setState(() {
          _animals = animals;
          _isLoading = false;
        });
      }
    } catch (e) {
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
    setState(() {
      _isExpanded = !_isExpanded;
    });
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
              centerText: widget.screenTitle,
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
      return const Center(
        child: CircularProgressIndicator(),
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
        onAnimalSelected: _animalManager.handleAnimalSelection,
      ),
    );
  }
}









