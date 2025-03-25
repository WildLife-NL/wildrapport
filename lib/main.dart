import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/models/dropdown_type.dart';
import 'package:wildrapport/services/dropdown_service.dart';
import 'package:wildrapport/widgets/brown_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WildRapport',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.lightMintGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.darkGreen,
          surface: AppColors.lightMintGreen,
        ),
        textTheme: AppTextTheme.textTheme,
        fontFamily: 'Arimo',
      ),
      home: const FilterDropdownScreen(),
    );
  }
}

class FilterDropdownScreen extends StatefulWidget {
  const FilterDropdownScreen({super.key});

  @override
  State<FilterDropdownScreen> createState() => _FilterDropdownScreenState();
}

class _FilterDropdownScreenState extends State<FilterDropdownScreen> {
  bool isExpanded = false;
  String selectedFilter = 'Filter';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: DropdownService.buildDropdown(
            type: DropdownType.filter,
            selectedValue: selectedFilter,
            isExpanded: isExpanded,
            onExpandChanged: (value) {
              setState(() {
                isExpanded = value;
              });
            },
            onOptionSelected: (selected) {
              setState(() {
                selectedFilter = selected;
                isExpanded = false;
              });
              print('Selected: $selected');
            },
          ),
        ),
      ),
    );
  }
}


