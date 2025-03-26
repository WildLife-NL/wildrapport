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
    BrownButtonModel selectedModel = BrownButtonModel(
      text: selectedValue,
      leftIconPath: 'assets/icons/filter_dropdown/filter_icon.png',
      rightIconPath: isExpanded 
          ? 'assets/icons/filter_dropdown/arrow_up_icon.png'
          : 'assets/icons/filter_dropdown/arrow_down_icon.png',
      leftIconPadding: 5, // Add this to match the positioning
    );

    // Update selected model if it matches one of the filter options
    final filterOptions = _getFilterDropdown();
    for (var option in filterOptions) {
      if (option.text == selectedValue) {
        selectedModel = BrownButtonModel(
          text: selectedValue,
          leftIconPath: option.leftIconPath,
          rightIconPath: isExpanded 
              ? 'assets/icons/filter_dropdown/arrow_up_icon.png'
              : 'assets/icons/filter_dropdown/arrow_down_icon.png',
          leftIconPadding: 5, // Add this to match the positioning
        );
        break;
      }
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
    final filterOptions = _getFilterDropdown();
    
    // Add reset button with the same positioning
    if (filterOptions.any((model) => model.text == selectedValue)) {
      models.add(BrownButtonModel(
        text: 'Resetten',
        leftIconPath: 'assets/icons/filter_dropdown/reset_icon.png',
        leftIconPadding: 5, // Add this to match the positioning
      ));
    }
    
    // Add regular filter options
    models.addAll(filterOptions);
    
    return _createButtons(models, onOptionSelected);
  }

  static List<BrownButtonModel> _getFilterDropdown() {
    return [
      BrownButtonModel(
        text: 'Sorteer alfabetisch',
        leftIconPath: 'assets/icons/filter_dropdown/letter_icon.png',
        leftIconPadding: 5, 
      ),
      BrownButtonModel(
        text: 'Sorteer op Categorie',
        leftIconPath: 'assets/icons/filter_dropdown/category_icon.png',
        rightIconPath: 'assets/icons/filter_dropdown/arrow_next_icon.png',
        leftIconPadding: 5, 
      ),
      BrownButtonModel(
        text: 'Meest gezien',
        leftIconPath: 'assets/icons/filter_dropdown/seen_icon.png',
        leftIconPadding: 5, 
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




