import 'package:flutter/material.dart';
import 'package:wildrapport/widgets/counter_widget.dart';
import 'package:wildrapport/widgets/white_bulk_button.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/widgets/count_bar.dart';

class AnimalCounting extends StatefulWidget {
  final Function(String)? onAgeSelected;
  final VoidCallback? onAddToList;

  const AnimalCounting({
    super.key,
    this.onAgeSelected,
    this.onAddToList,
  });

  @override
  State<AnimalCounting> createState() => _AnimalCountingState();
}

class _AnimalCountingState extends State<AnimalCounting> {
  String? selectedAge;
  String? selectedGender;
  int currentCount = 0;

  void _handleCountChanged(String name, int count) {
    setState(() {
      currentCount = count;
    });
  }

  void _handleAgeSelection(String age) {
    setState(() {
      selectedAge = age;
    });
    widget.onAgeSelected?.call(age);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              Column(
                children: [
                  SizedBox(
                    width: 182, // Same width as buttons
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 22.0),
                      child: Text(
                        'Leeftijd',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brown,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.25),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildAgeButton(
                    "Onbekend",
                    icon: Icons.cancel_outlined,
                  ),
                  const SizedBox(height: 8),
                  _buildAgeButton("<6 maanden"),
                  const SizedBox(height: 8),
                  _buildAgeButton("Onvolwassen"),
                  const SizedBox(height: 8),
                  _buildAgeButton("Volwassen"),
                ],
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  SizedBox(
                    width: 182, // Same width as buttons
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 22.0), // Increased from 8.0 to 16.0
                      child: Text(
                        'Geslacht',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brown,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.25),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildAgeButton(
                    "Onbekend",
                    icon: Icons.cancel_outlined,
                  ),
                  const SizedBox(height: 8),
                  _buildAgeButton(
                    "Mannelijk",
                    icon: Icons.male,
                    tintColor: AppColors.brown,
                  ),
                  const SizedBox(height: 8),
                  _buildAgeButton(
                    "Vrouwelijk",
                    icon: Icons.female,
                    tintColor: AppColors.brown,
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 64.5),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 10, top: 24),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  width: 230,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Aantal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brown,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AnimalCounter(
                  name: "Example",
                  height: 49,
                  onCountChanged: _handleCountChanged,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 350,
                  child: WhiteBulkButton(
                    text: "Voeg toe aan de lijst",
                    showIcon: false,
                    height: 85,
                    onPressed: selectedAge != null && selectedGender != null ? widget.onAddToList : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeButton(String text, {IconData? icon, Color? tintColor}) {
    final bool isSelected = text == selectedAge || text == selectedGender;
    
    Widget? leftWidget;
    if (icon != null) {
      leftWidget = Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Icon(
          icon,
          size: 36,
          color: tintColor ?? AppColors.brown,
        ),
      );
    }

    return SizedBox(
      width: 182,
      height: 64.5,
      child: WhiteBulkButton(
        text: text,
        height: 64.5,
        showIcon: false,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        textAlign: icon != null ? TextAlign.left : TextAlign.center,
        leftWidget: leftWidget,
        onPressed: () => _handleAgeSelection(text),
      ),
    );
  }
}
















