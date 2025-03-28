import 'package:flutter/material.dart';
import 'package:wildrapport/models/brown_button_model.dart';
import 'package:wildrapport/models/enums/dropdown_type.dart';
import 'package:wildrapport/widgets/brown_button.dart';
import 'package:wildrapport/constants/app_colors.dart';

class DropdownService {
  static const String defaultFilterText = 'Filteren';
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
    // Find the matching model for the selected value
    BrownButtonModel selectedModel;
    
    if (selectedValue == defaultFilterText) {
      // Default state (no filter selected)
      selectedModel = BrownButtonModel(
        text: defaultFilterText,
        leftIconPath: 'circle_icon:filter_list',
        rightIconPath: isExpanded 
            ? 'assets/icons/filter_dropdown/arrow_up_icon.png'
            : 'assets/icons/filter_dropdown/arrow_down_icon.png',
        leftIconPadding: 5,
        leftIconSize: 38.0,  // Match original CircleIconContainer size
        rightIconSize: 24.0,
      );
    } else {
      // Check if selected value matches any filter option
      final filterOptions = _getFilterDropdown();
      final matchingOption = filterOptions.firstWhere(
        (model) => model.text == selectedValue,
        orElse: () => BrownButtonModel(
          text: selectedValue,
          leftIconPath: 'circle_icon:filter_list',
          rightIconPath: isExpanded 
              ? 'assets/icons/filter_dropdown/arrow_up_icon.png'
              : 'assets/icons/filter_dropdown/arrow_down_icon.png',
          leftIconPadding: 5,
          leftIconSize: 38.0,  // Match original CircleIconContainer size
          rightIconSize: 24.0,
        ),
      );
      
      selectedModel = BrownButtonModel(
        text: matchingOption.text ?? selectedValue,
        leftIconPath: matchingOption.leftIconPath,
        rightIconPath: isExpanded 
            ? 'assets/icons/filter_dropdown/arrow_up_icon.png'
            : 'assets/icons/filter_dropdown/arrow_down_icon.png',
        leftIconPadding: 5,
        leftIconSize: 38.0,  // Match original CircleIconContainer size
        rightIconSize: 24.0,
      );
    }

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
              children: _getFilterOptions(
                selectedValue: selectedValue,
                onOptionSelected: (selected) {
                  onOptionSelected(selected);
                  onExpandChanged(false);
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
    
    // Get regular filter options
    final filterOptions = _getFilterDropdown()
        .where((model) => model.text != selectedValue) // Exclude the selected filter
        .toList();
    
    // Add reset button only if an actual filter is selected (not the default text)
    final isFilterSelected = selectedValue != defaultFilterText && 
        _getFilterDropdown().any((model) => model.text == selectedValue);
        
    if (isFilterSelected) {
      models.add(BrownButtonModel(
        text: 'Resetten',
        leftIconPath: 'circle_icon:restart_alt',  // Use Material icon for reset
        leftIconPadding: 5,
      ));
    }
    
    // Add remaining filter options
    models.addAll(filterOptions);
    
    return _createButtons(models, (selected) {
      // If "Resetten" is clicked, pass the default filter text
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
    return BrownButtonModel(
      text: selectedValue,
      leftIconPath: 'assets/icons/filter_dropdown/filter_icon.png',
      rightIconPath: isExpanded 
          ? 'assets/icons/filter_dropdown/arrow_up_icon.png'
          : 'assets/icons/filter_dropdown/arrow_down_icon.png',
      leftIconPadding: 5, // Add this to match the positioning
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




