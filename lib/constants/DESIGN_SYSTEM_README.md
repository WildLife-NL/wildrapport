# Design System Guide

This folder contains the centralized design system for the WildlifeNL app. Use these files to maintain consistency across the entire application.

## Files

### `design_colors.dart`
All color definitions with semantic naming. Instead of hardcoding colors, use:
```dart
AppColors.primaryGreen
AppColors.darkCharcoal
AppColors.lightGreen
AppColors.white
AppColors.textPrimary
```

### `text_styles.dart`
Predefined text styles for different semantic purposes:
```dart
AppTextStyles.heading1
AppTextStyles.bodyLarge
AppTextStyles.button
AppTextStyles.labelMedium
```

### `component_styles.dart`
Reusable styles for UI components:
```dart
// Buttons
AppComponentStyles.primaryElevatedButton()
AppComponentStyles.outlinedButtonSelected()
AppComponentStyles.outlinedButtonUnselected()

// Cards
AppComponentStyles.cardDecoration()
AppComponentStyles.cardShape()

// Input fields
AppComponentStyles.textFieldDecoration()
AppComponentStyles.dropdownDecoration()
```

### `spacing.dart`
Consistent spacing scale throughout the app:
```dart
AppSpacing.paddingMedium // 16
AppSpacing.gapLarge // 16
AppSpacing.radiusXLarge // 20
AppSpacing.buttonHeight // 48
```

## Usage

### Import Everything at Once
```dart
import 'package:wildrapport/constants/design_system.dart';
```

### Import Specific Module
```dart
import 'package:wildrapport/constants/design_colors.dart';
import 'package:wildrapport/constants/text_styles.dart';
```

## Examples

### Button with Consistent Styling
```dart
ElevatedButton(
  onPressed: () {},
  style: AppComponentStyles.primaryElevatedButton(),
  child: const Text('Click Me', style: AppTextStyles.buttonWhite),
)
```

### Card with Border
```dart
Card(
  shape: AppComponentStyles.cardShape(),
  child: Padding(
    padding: const EdgeInsets.all(AppSpacing.paddingMedium),
    child: Text('Card Content', style: AppTextStyles.bodyLarge),
  ),
)
```

### Text Field
```dart
TextField(
  decoration: AppComponentStyles.textFieldDecoration(
    hintText: 'Enter text',
    labelText: 'Label',
  ),
)
```

### Consistent Spacing
```dart
Column(
  children: [
    Text('Title', style: AppTextStyles.heading2),
    SizedBox(height: AppSpacing.gapLarge),
    Text('Content', style: AppTextStyles.bodyMedium),
  ],
)
```

## Adding New Styles

When you need a new style:
1. **Color**: Add to `design_colors.dart`
2. **Text appearance**: Add to `text_styles.dart`
3. **Component styling**: Add method to `component_styles.dart`
4. **Sizing/spacing**: Add constant to `spacing.dart`

This keeps the design system centralized and easy to maintain!
