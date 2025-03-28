import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/managers/screen_state_manager.dart';
import 'package:wildrapport/models/enums/dropdown_type.dart';
import 'package:wildrapport/viewmodels/animals_view_model.dart';
import 'package:wildrapport/widgets/animal_grid.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/services/dropdown_service.dart';

class AnimalsScreen extends StatefulWidget {
  final String screenTitle;
  
  const AnimalsScreen({
    super.key,
    required this.screenTitle,
  });

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
    _viewModel = AnimalsViewModel();
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
    'selectedFilter': 'Filter',
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
                  builder: (context, viewModel, _) => DropdownService.buildDropdown(
                    type: DropdownType.filter,
                    selectedValue: viewModel.selectedFilter,
                    isExpanded: viewModel.isExpanded,
                    onExpandChanged: (_) => viewModel.toggleExpanded(),
                    onOptionSelected: viewModel.updateFilter,
                  ),
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

