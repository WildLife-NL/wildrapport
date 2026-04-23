import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized component styles for the WildlifeNL app
/// Reusable style definitions for buttons, cards, inputs, etc.
class AppComponentStyles {
  // ============ BUTTON STYLES ============

  /// Primary elevated button (green background)
  static ButtonStyle primaryElevatedButton() => ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    backgroundColor: AppColors.primaryGreen,
    foregroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
  );

  /// Secondary elevated button (dark background)
  static ButtonStyle secondaryElevatedButton() => ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    backgroundColor: AppColors.darkCharcoal,
    foregroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
  );

  /// Outlined button with default styling
  static ButtonStyle outlinedButton() => OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    side: BorderSide(
      color: Colors.black.withValues(alpha: 0.2),
      width: 1.5,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
    foregroundColor: AppColors.textPrimary,
  );

  /// Outlined button with selected state (dark background)
  static ButtonStyle outlinedButtonSelected() => OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    side: const BorderSide(
      color: AppColors.darkCharcoal,
      width: 1.5,
    ),
    backgroundColor: AppColors.darkCharcoal,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    foregroundColor: AppColors.white,
  );

  /// Outlined button with unselected state
  static ButtonStyle outlinedButtonUnselected() => OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    side: BorderSide(
      color: Colors.black.withValues(alpha: 0.2),
      width: 1.5,
    ),
    backgroundColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    foregroundColor: AppColors.textPrimary,
  );

  /// Selection button with fixed width (150px) - selected state (dark background)
  static ButtonStyle selectionButtonSelected() => OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    side: const BorderSide(
      color: AppColors.darkCharcoal,
      width: 1.5,
    ),
    backgroundColor: AppColors.darkCharcoal,
    fixedSize: const Size(150, 44),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    foregroundColor: AppColors.white,
  );

  /// Selection button with fixed width (150px) - unselected state
  static ButtonStyle selectionButtonUnselected() => OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    side: BorderSide(
      color: Colors.black.withValues(alpha: 0.2),
      width: 1.5,
    ),
    backgroundColor: Colors.transparent,
    fixedSize: const Size(150, 44),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    foregroundColor: AppColors.textPrimary,
  );

  // ============ CARD STYLES ============

  /// Default card shape with border
  static ShapeBorder cardShape({
    double borderRadius = 20,
    Color borderColor = AppColors.borderDefault,
    double borderWidth = 1,
  }) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: BorderSide(
        color: borderColor,
        width: borderWidth,
      ),
    );
  }

  /// Card decoration with shadow
  static BoxDecoration cardDecoration({
    double borderRadius = 20,
    Color backgroundColor = AppColors.cardBackground,
    Color borderColor = AppColors.borderDefault,
    double borderWidth = 1,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor,
        width: borderWidth,
      ),
    );
  }

  // ============ INPUT FIELD STYLES ============

  /// Default text field input decoration
  static InputDecoration textFieldDecoration({
    String? hintText,
    String? labelText,
    Color borderColor = AppColors.borderDefault,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      filled: true,
      fillColor: AppColors.cardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: borderColor,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: borderColor,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: borderColor,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

  // ============ DROPDOWN STYLES ============

  /// Default dropdown style
  static InputDecoration dropdownDecoration({
    String? hint,
    Color borderColor = AppColors.borderDefault,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: borderColor,
          width: 1.2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: borderColor,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: borderColor,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
    );
  }

  // ============ DIVIDER STYLES ============

  /// Default divider
  static const Divider defaultDivider = Divider(
    height: 1,
    color: AppColors.borderLight,
    thickness: 1,
  );

  // ============ APP BAR STYLES ============

  /// Standard app bar text color
  static const Color appBarTextColor = AppColors.textPrimary;

  /// Standard app bar background color
  static const Color appBarBackgroundColor = AppColors.white;
}
