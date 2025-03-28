import 'package:flutter/material.dart';
import 'package:wildrapport/managers/filter_manager.dart';
import 'package:wildrapport/models/brown_button_model.dart';
import 'package:wildrapport/models/enums/dropdown_type.dart';
import 'package:wildrapport/widgets/brown_button.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/widgets/category_filter_options.dart';

class DropdownService {
  static const String defaultFilterText = 'Filteren';
  static const String sorteerOpCategorieText = 'Sorteer op Categorie';
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Curve animationCurve = Curves.easeInOut;

  static Widget buildDropdown({
    required DropdownType type,
    required String selectedValue,
    required bool isExpanded,
    required Function(bool) onExpandChanged,
    required Function(String) onOptionSelected,
  }) {
    switch (type) {
      case DropdownType.filter:
        return _buildAnimatedDropdown(
          content: _buildFilterDropdown(
            selectedValue: selectedValue,
            isExpanded: isExpanded,
            onExpandChanged: onExpandChanged,
            onOptionSelected: onOptionSelected,
          ),
          isExpanded: isExpanded,
        );
    
      default:
        throw UnimplementedError('Dropdown type not implemented');
    }
  }

  static Widget _buildAnimatedDropdown({
    required Widget content,
    required bool isExpanded,
  }) {
    return AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      child: AnimatedSize(
        duration: animationDuration,
        curve: animationCurve,
        alignment: Alignment.topCenter,
        child: content,
      ),
    );
  }

  static Widget _buildFilterDropdown({
    required String selectedValue,
    required bool isExpanded,
    required Function(bool) onExpandChanged,
    required Function(String) onOptionSelected,
  }) {
    // Check if the current value is a category
    bool isCategory = FilterManager.getAnimalCategories()
        .any((category) => category['text'] == selectedValue);
    bool isShowingCategories = selectedValue == sorteerOpCategorieText || isCategory;
    
    // Ensure we're using defaultFilterText ('Filteren') consistently
    String currentValue = selectedValue == 'Filter' ? defaultFilterText : selectedValue;
    
    BrownButtonModel selectedModel = currentValue == defaultFilterText
        ? BrownButtonModel(
            text: defaultFilterText,
            leftIconPath: 'circle_icon:filter_list',
            rightIconPath: isExpanded 
                ? 'assets/icons/filter_dropdown/arrow_up_icon.png'
                : 'assets/icons/filter_dropdown/arrow_down_icon.png',
            leftIconPadding: 5,
            leftIconSize: 38.0,
            rightIconSize: 24.0,
          )
        : isShowingCategories
            ? BrownButtonModel(
                text: currentValue,
                leftIconPath: 'circle_icon:category',
                rightIconPath: isExpanded 
                    ? 'assets/icons/filter_dropdown/arrow_up_icon.png'
                    : 'assets/icons/filter_dropdown/arrow_down_icon.png',
                leftIconPadding: 5,
                leftIconSize: 38.0,
                rightIconSize: 24.0,
              )
            : _createSelectedModel(currentValue, isExpanded);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrownButton(
          model: selectedModel,
          onPressed: () => onExpandChanged(!isExpanded),
        ),
        if (isExpanded)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: AppColors.lightMintGreen,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: isShowingCategories
                  ? [
                      CategoryFilterOptions(
                        items: FilterManager.getAnimalCategories(),
                        onCategorySelected: (category) {
                          if (category == 'Resetten') {
                            onOptionSelected(defaultFilterText);
                            // Don't close the dropdown
                          } else {
                            onOptionSelected(category);
                            onExpandChanged(false);
                          }
                        },
                      ),
                    ]
                  : _getFilterOptions(
                      selectedValue: currentValue,
                      onOptionSelected: (selected) {
                        onOptionSelected(selected);
                        if (selected == sorteerOpCategorieText) {
                          onExpandChanged(true);
                        } else if (selected != 'Resetten') { // Don't close dropdown on reset
                          onExpandChanged(false);
                        }
                      },
                    ).map((button) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildAnimatedOption(child: button),
                    )).toList(),
            ),
          ),
      ],
    );
  }

  static Widget _buildAnimatedOption({required Widget child}) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: animationDuration,
      curve: animationCurve,
      child: child,
    );
  }

  static List<BrownButton> _getFilterOptions({
    required String selectedValue,
    required Function(String) onOptionSelected,
  }) {
    final List<BrownButtonModel> models = [];
    
    // Only show reset button if we're not showing the default filter text
    if (selectedValue != defaultFilterText) {
      models.add(BrownButtonModel(
        text: 'Resetten',
        leftIconPath: 'circle_icon:restart_alt',
        leftIconPadding: 5,
        leftIconSize: 38.0,
      ));
    }
    
    // Get all filter options except the currently selected one
    final allOptions = _getFilterDropdown().where((model) => 
      model.text != selectedValue && 
      // Also exclude if a category is selected
      !FilterManager.getAnimalCategories()
          .any((category) => category['text'] == selectedValue)
    ).toList();
    
    // Add filtered options
    models.addAll(allOptions);
    
    return _createButtons(models, (selected) {
      if (selected == 'Resetten') {
        onOptionSelected(defaultFilterText);
      } else {
        onOptionSelected(selected);
      }
    });
  }

  static List<BrownButtonModel> _getFilterDropdown() {
    return [
      BrownButtonModel(
        text: 'Sorteer alfabetisch',
        leftIconPath: 'circle_icon:sort_by_alpha',
        leftIconPadding: 5,
        leftIconSize: 38.0,
      ),
      BrownButtonModel(
        text: 'Sorteer op Categorie',
        leftIconPath: 'circle_icon:category',
        rightIconPath: 'assets/icons/filter_dropdown/arrow_next_icon.png',
        leftIconPadding: 5,
        leftIconSize: 38.0,
        rightIconSize: 24.0,
      ),
      BrownButtonModel(
        text: 'Meest gezien',
        leftIconPath: 'circle_icon:visibility',
        leftIconPadding: 5,
        leftIconSize: 38.0,
      ),
    ];
  }

  static BrownButtonModel _createSelectedModel(String selectedValue, bool isExpanded) {
    // Check if the selected value is a category
    final categories = FilterManager.getAnimalCategories();
    final selectedCategory = categories.firstWhere(
      (category) => category['text'] == selectedValue,
      orElse: () => {'text': '', 'icon': ''},
    );

    // If it's a category, use its icon
    if (selectedCategory['text']!.isNotEmpty) {
      return BrownButtonModel(
        text: selectedValue,
        leftIconPath: selectedCategory['icon'],
        rightIconPath: isExpanded 
            ? 'assets/icons/filter_dropdown/arrow_up_icon.png'
            : 'assets/icons/filter_dropdown/arrow_down_icon.png',
        leftIconPadding: 5,
        leftIconSize: 38.0,
        rightIconSize: 24.0,
      );
    }

    // For non-category filters, map the filter name to its corresponding icon
    String leftIconPath = 'circle_icon:filter_list';  // default
    switch (selectedValue) {
      case 'Sorteer alfabetisch':
        leftIconPath = 'circle_icon:sort_by_alpha';
        break;
      case 'Meest gezien':
        leftIconPath = 'circle_icon:visibility';
        break;
      case 'Sorteer op Categorie':
        leftIconPath = 'circle_icon:category';
        break;
    }

    return BrownButtonModel(
      text: selectedValue,
      leftIconPath: leftIconPath,
      rightIconPath: isExpanded 
          ? 'assets/icons/filter_dropdown/arrow_up_icon.png'
          : 'assets/icons/filter_dropdown/arrow_down_icon.png',
      leftIconPadding: 5,
      leftIconSize: 38.0,
      rightIconSize: 24.0,
    );
  }

  static List<BrownButton> _createButtons(
    List<BrownButtonModel> models,
    Function(String) onOptionSelected,
  ) {
    return models.map((model) => BrownButton(
      model: model,
      onPressed: () => onOptionSelected(model.text ?? ''),
    )).toList();
  }
}



























