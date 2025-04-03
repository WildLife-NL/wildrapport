import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/dropdown_interface.dart';
import 'package:wildrapport/interfaces/filter_interface.dart';
import 'package:wildrapport/managers/filter_manager.dart';
import 'package:wildrapport/models/brown_button_model.dart';
import 'package:wildrapport/models/enums/dropdown_type.dart';
import 'package:wildrapport/models/enums/filter_type.dart';
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
          model: BrownButtonModel(
            text: selectedValue == FilterType.none.displayText ? 'Filteren' : selectedValue,
            leftIconPath: _getSelectedFilterIcon(selectedValue),
            rightIconPath: isExpanded 
                ? 'assets/icons/filter_dropdown/arrow_up_icon.png'
                : 'assets/icons/filter_dropdown/arrow_down_icon.png',
            leftIconSize: 38.0,
            rightIconSize: 24.0,
            leftIconPadding: 5,
          ),
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
          .map((filterModel) {
            if (filterModel.text == FilterType.search.displayText) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.brown,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: CircleIconContainer(
                          icon: Icons.search,
                          iconColor: AppColors.brown,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          decoration: const InputDecoration(
                            hintText: 'Zoek een dier...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.white70),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onChanged: (value) {
                            // TODO: Implement search functionality
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: BrownButton(
                model: filterModel,
                onPressed: () {
                  if (filterModel.text == FilterType.mostViewed.displayText) {
                    return;
                  }
                  
                  onOptionSelected(filterModel.text ?? '');
                  if (filterModel.text != FilterType.category.displayText) {
                    onExpandChanged(false);
                  }
                },
              ),
            );
          })
          .toList(),
    );

    // Only show reset when a filter is actually selected
    final bool shouldShowReset = selectedValue != FilterType.none.displayText && 
                                selectedValue != 'Filteren' &&
                                selectedValue != 'Filter' &&
                                selectedValue.isNotEmpty &&
                                !_filterManager.getAvailableFilters(selectedValue)
                                    .any((filter) => filter.text == selectedValue);

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

  String _getSelectedFilterIcon(String selectedValue) {
    if (selectedValue == FilterType.none.displayText || selectedValue == 'Filteren') {
      return FilterType.none.iconPath;
    }

    // Check for categories first
    final categories = (_filterManager as CategoryInterface).getAnimalCategories();
    final selectedCategory = categories.firstWhere(
      (category) => category['text'] == selectedValue,
      orElse: () => {'icon': ''},
    );

    if (selectedCategory['icon']?.isNotEmpty ?? false) {
      return selectedCategory['icon']!;
    }

    // Handle filter types
    final filterType = FilterType.values.firstWhere(
      (type) => type.displayText == selectedValue,
      orElse: () => FilterType.none,
    );

    return filterType.iconPath;
  }
}




























