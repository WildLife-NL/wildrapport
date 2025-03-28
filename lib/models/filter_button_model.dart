import 'package:wildrapport/models/brown_button_model.dart';
import 'package:wildrapport/models/enums/filter_type.dart';

class FilterButtonModel {
  final FilterType type;
  final bool showRightArrow;
  final bool keepDropdownOpen;
  final double leftIconSize;
  final double rightIconSize;
  final double leftIconPadding;
  final String? customText;
  final String? customIcon;

  const FilterButtonModel({
    required this.type,
    this.showRightArrow = false,
    this.keepDropdownOpen = false,
    this.leftIconSize = 38.0,
    this.rightIconSize = 24.0,
    this.leftIconPadding = 5,
    this.customText,
    this.customIcon,
  });

  BrownButtonModel toBrownButtonModel({bool isExpanded = false}) {
    return BrownButtonModel(
      text: customText ?? type.displayText,
      leftIconPath: customIcon ?? type.iconPath,
      rightIconPath: showRightArrow
          ? 'assets/icons/filter_dropdown/arrow_next_icon.png'
          : isExpanded
              ? 'assets/icons/filter_dropdown/arrow_up_icon.png'
              : 'assets/icons/filter_dropdown/arrow_down_icon.png',
      leftIconPadding: leftIconPadding,
      leftIconSize: leftIconSize,
      rightIconSize: rightIconSize,
    );
  }
}
