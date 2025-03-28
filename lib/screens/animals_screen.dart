import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/animal_interface.dart';
import 'package:wildrapport/managers/animal_manager.dart';
import 'package:wildrapport/managers/screen_state_manager.dart';
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

class _AnimalsScreenState extends ScreenStateManager<AnimalsScreen> {
  late final ScrollController _scrollController;
  late final AnimalsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _viewModel = AnimalsViewModel(
      selectedFilter: FilterType.none.displayText,
      animalService: widget.animalService,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  String get screenName => 'AnimalsScreen';

  @override
  Map<String, dynamic> getInitialState() => {
    'isExpanded': false,
    'selectedFilter': FilterType.none.displayText,  // Change this from 'Filter' to FilterType.none.displayText
  };

  @override
  void updateState(String key, dynamic value) {
    switch (key) {
      case 'isExpanded':
        _viewModel.isExpanded = value as bool;
        break;
      case 'selectedFilter':
        _viewModel.selectedFilter = value as String;
        break;
    }
  }

  @override
  Map<String, dynamic> getCurrentState() => {
    'isExpanded': _viewModel.isExpanded,
    'selectedFilter': _viewModel.selectedFilter,
  };

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
                child: Consumer<AnimalsViewModel>(
                  builder: (context, viewModel, _) {
                    print('AnimalsScreen - Current Filter: ${viewModel.selectedFilter}'); // Debug print
                    return DropdownManager().buildDropdown(
                      type: DropdownType.filter,
                      selectedValue: viewModel.selectedFilter,
                      isExpanded: viewModel.isExpanded,
                      onExpandChanged: (_) => viewModel.toggleExpanded(),
                      onOptionSelected: (filter) {
                        viewModel.updateFilter(filter);
                      },
                    );
                  },
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
































