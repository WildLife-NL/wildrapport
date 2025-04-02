import 'package:flutter/material.dart';
import 'package:wildrapport/interfaces/dropdown_interface.dart';
import 'package:wildrapport/interfaces/filter_interface.dart';
import 'package:wildrapport/managers/filter_manager.dart';
import 'package:wildrapport/models/brown_button_model.dart';
import 'package:wildrapport/models/enums/dropdown_type.dart';
import 'package:wildrapport/models/enums/filter_type.dart';
import 'package:wildrapport/models/filter_button_model.dart';
import 'package:wildrapport/widgets/brown_button.dart';
import 'package:wildrapport/widgets/category_filter_options.dart';

class DropdownManager implements DropdownInterface {
  final FilterInterface _filterManager;

  DropdownManager(this._filterManager);

  @override
  Widget buildDropdown({
    required DropdownType type,
    required String selectedValue,
    required bool isExpanded,
    required Function(bool) onExpandChanged,
    required Function(String) onOptionSelected,
  }) {
    switch (type) {
      case DropdownType.filter:
        return _buildFilterDropdown(
          selectedValue: selectedValue,
          isExpanded: isExpanded,
          onExpandChanged: onExpandChanged,
          onOptionSelected: onOptionSelected,
        );
      default:
        throw UnimplementedError('Dropdown type not implemented');
    }
  }

  Widget _buildFilterDropdown({
    required String selectedValue,
    required bool isExpanded,
    required Function(bool) onExpandChanged,
    required Function(String) onOptionSelected,
  }) {
    final bool isShowingCategories = selectedValue == FilterType.category.displayText ||
                                   (_filterManager as CategoryInterface).getAnimalCategories()
                                       .any((category) => category['text'] == selectedValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BrownButton(
          model: _createSelectedButtonModel(selectedValue, isExpanded).toBrownButtonModel(isExpanded: isExpanded),
          onPressed: () => onExpandChanged(!isExpanded),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 8),
          if (isShowingCategories)
            _buildCategoryOptions(onOptionSelected, onExpandChanged)
          else
            ..._buildFilterOptions(
              selectedValue: selectedValue,
              onOptionSelected: onOptionSelected,
              onExpandChanged: onExpandChanged,
            ),
        ],
      ],
    );
  }

  Widget _buildCategoryOptions(
    Function(String) onOptionSelected,
    Function(bool) onExpandChanged,
  ) {
    return CategoryFilterOptions(
      items: (_filterManager as CategoryInterface).getAnimalCategories(),
      onCategorySelected: (category) {
        onOptionSelected(category);
        onExpandChanged(false);
      },
      onBackPressed: () => onOptionSelected(FilterType.none.displayText),
    );
  }

  List<Widget> _buildFilterOptions({
    required String selectedValue,
    required Function(String) onOptionSelected,
    required Function(bool) onExpandChanged,
  }) {
    final List<Widget> options = [];

    // Add filter options
    options.addAll(
      _filterManager.getAvailableFilters(selectedValue)
          .map((filterModel) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BrownButton(
                  model: filterModel.toBrownButtonModel(),
                  onPressed: () {
                    onOptionSelected(filterModel.type.displayText);
                    if (filterModel.type != FilterType.category && !filterModel.keepDropdownOpen) {
                      onExpandChanged(false);
                    }
                  },
                ),
              ))
          .toList(),
    );

    // Only show reset when a filter is actually selected
    final bool shouldShowReset = selectedValue != FilterType.none.displayText && 
                                selectedValue != 'Filteren' &&
                                selectedValue != 'Filter' &&
                                selectedValue.isNotEmpty &&
                                !_filterManager.getAvailableFilters(selectedValue)
                                    .any((filter) => filter.type.displayText == selectedValue);

    if (shouldShowReset) {
      options.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: BrownButton(
            model: BrownButtonModel(
              text: 'Reset filter',
              leftIconPath: 'assets/icons/filter_dropdown/reset_icon.png',
              leftIconSize: 38.0,
            ),
            onPressed: () {
              onOptionSelected(FilterType.none.displayText);
              onExpandChanged(false);  // Close the dropdown after reset
            },
          ),
        ),
      );
    }

    return options;
  }

  FilterButtonModel _createSelectedButtonModel(String currentValue, bool isExpanded) {
    if (currentValue == FilterType.none.displayText) {
      return FilterButtonModel(
        type: FilterType.none,
        showRightArrow: false,
        customText: 'Filteren',
      );
    }

    final categories = (_filterManager as CategoryInterface).getAnimalCategories();
    final isCategory = categories.any((category) => category['text'] == currentValue);
    
    if (isCategory) {
      final category = categories.firstWhere(
        (category) => category['text'] == currentValue,
      );
      return FilterButtonModel(
        type: FilterType.category,
        customText: currentValue,
        customIcon: category['icon'],
        showRightArrow: false,
      );
    }

    final filterType = FilterType.values.firstWhere(
      (type) => type.displayText == currentValue,
      orElse: () => FilterType.none,
    );

    return FilterButtonModel(
      type: filterType,
      showRightArrow: filterType == FilterType.category,
      keepDropdownOpen: filterType == FilterType.category,
    );
  }
}












