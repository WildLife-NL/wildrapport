import 'package:flutter/material.dart';
import 'package:wildlifenl_map_ui_components/wildlifenl_map_ui_components.dart';

class CategoryFilterOptions extends StatelessWidget {
  final List<Map<String, String>> items;
  final Function(String) onCategorySelected;
  final VoidCallback onBackPressed;

  const CategoryFilterOptions({
    super.key,
    required this.items,
    required this.onCategorySelected,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final gridItems = items
        .map((e) => CategoryGridItem(text: e['text'] ?? '', iconPath: e['icon']))
        .toList();
    return WildLifeNLCategoryGrid(
      items: gridItems,
      onItemSelected: onCategorySelected,
      onBackPressed: onBackPressed,
    );
  }
}
