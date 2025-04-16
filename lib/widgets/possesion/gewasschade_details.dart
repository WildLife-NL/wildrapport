import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/providers/possesion_damage_report_provider.dart';
import 'package:wildrapport/widgets/possesion/possesion_dropdown.dart';

class GewasschadeDetails extends StatefulWidget {
  const GewasschadeDetails({super.key});

  @override
  State<GewasschadeDetails> createState() => _GewasschadeDetailsState();
}

class _GewasschadeDetailsState extends State<GewasschadeDetails> {
  final TextEditingController _responseController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<PossesionDamageFormProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PossesionDropdown(
          onChanged: (value) => formProvider.setImpactedCrop(value), 
          getSelectedValue: formProvider.impactedCrop,
          dropdownItems: [
            {'text': 'Mais', 'value': 'mais'},
            {'text': 'Bieten', 'value': 'bieten'},
            {'text': 'Granen', 'value': 'granen'},
            {'text': 'Bloementeelt', 'value': 'bloementeelt'},
            {'text': 'Grasvelden', 'value': 'grasvelden'},
            {'text': 'Boomteelt', 'value': 'boomteelt'},
            {'text': 'Tuinbouw', 'value': 'tuinbouw'},
          ],
          containerHeight: 50,
          containerWidth: 400,
          startingValue: "mais",
          hasDropdownSideDescription: false,
        ),
        const SizedBox(height: 10),
        PossesionDropdown(
          onChanged: (value) => formProvider.setImpactedAreaType(value), 
          getSelectedValue: formProvider.impactedAreaType,
          dropdownItems: [
            {'text': 'ha', 'value': 'hectare'},
            {'text': 'm2', 'value': 'vierkante meters'},
            {'text': '%', 'value': 'percentage'},
          ],
          startingValue: "hectare",
          hasDropdownSideDescription: true,
          dropdownSideDescriptionText: "Getroffen Gebied",
        ),
          
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            controller: _responseController,
            onChanged: (value) => formProvider.setImpactedArea(value),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'hoe groot',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            style: const TextStyle(fontSize: 18, color: AppColors.brown),
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            "Intensiteit schade op dit moment: ${formProvider.currentDamage.round()}%",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Slider(
            value: formProvider.currentDamage,
            onChanged: (value) => formProvider.setCurrentDamage(value),
            min: 0,
            max: 100,
            divisions: 100,
            label: formProvider.currentDamage.round().toString(),
            activeColor: AppColors.brown,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            "Verwachte schade in de toekomst: ${formProvider.expectedDamage.round()}%",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Slider(
            value: formProvider.expectedDamage,
            onChanged: (value) => formProvider.setExpectedDamage(value),
            min: 0,
            max: 100,
            divisions: 100,
            label: formProvider.expectedDamage.round().toString(),
            activeColor: AppColors.brown,
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            onChanged: (val) => formProvider.setDescription(val),
            maxLines: 5, 
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'opmerkingen...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            style: const TextStyle(fontSize: 18, color: AppColors.brown),
          ),
        ),
      ],
    );
  }
}
