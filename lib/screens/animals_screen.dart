import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/animal_interface.dart';
import 'package:wildrapport/managers/animal_manager.dart';
import 'package:wildrapport/models/enums/dropdown_type.dart';
import 'package:wildrapport/models/enums/filter_type.dart';
import 'package:wildrapport/viewmodels/animals_view_model.dart';
import 'package:wildrapport/widgets/animal_grid.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/managers/dropdown_manager.dart';

class AnimalsScreen extends StatefulWidget {
  final String screenTitle;
  final AnimalManager animalService;
  
  AnimalsScreen({
    super.key,
    required this.screenTitle,
    AnimalManager? animalService,
  }) : animalService = animalService ?? AnimalManager();

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  late final ScrollController _scrollController;
  late final AnimalsViewModel _viewModel;
  bool _isExpanded = false;
  String _selectedFilter = FilterType.none.displayText;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _viewModel = AnimalsViewModel(
      selectedFilter: _selectedFilter,
      animalService: widget.animalService,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _viewModel.updateFilter(filter);
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
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
                child: DropdownManager().buildDropdown(
                  type: DropdownType.filter,
                  selectedValue: _selectedFilter,
                  isExpanded: _isExpanded,
                  onExpandChanged: (_) => _toggleExpanded(),
                  onOptionSelected: _updateFilter,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Consumer<AnimalsViewModel>(
                      builder: (context, viewModel, _) => AnimalGrid(
                        animals: viewModel.animals,
                        onAnimalSelected: (animal) => 
                          viewModel.handleAnimalSelection(context, animal, widget.screenTitle),
                      ),
                    ),
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
