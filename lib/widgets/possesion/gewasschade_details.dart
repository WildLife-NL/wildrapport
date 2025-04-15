import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/providers/possesion_damage_report_provider.dart';
import 'package:wildrapport/widgets/possesion/damage_type_dropdown.dart';

class GewasschadeDetails extends StatefulWidget {
  const GewasschadeDetails({super.key});

  @override
  State<GewasschadeDetails> createState() => _GewasschadeDetailsState();
}

class _GewasschadeDetailsState extends State<GewasschadeDetails> {
  final TextEditingController _responseController = TextEditingController();

  double currentDamage = 0;
  double expectedDamage = 0;

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<PossesionDamageFormProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DamageTypeDropdown(
          onChanged: (value) => formProvider.setImpactedAreaType(value),        ),
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
          child: const Text(
            "Intensiteit schade op dit moment",
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
            label: currentDamage.round().toString(),
            activeColor: AppColors.brown,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: const Text(
            "Verwachte schade in de toekomst",
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
            label: expectedDamage.round().toString(),
            activeColor: AppColors.brown,
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            onChanged: (val) => formProvider.setDescription(val),
            maxLines: 5, // You can increase or make null for expanding
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
