import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DamageTypeDropdown(),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            controller: _responseController,
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
            value: currentDamage,
            min: 0,
            max: 100,
            divisions: 100,
            label: currentDamage.round().toString(),
            activeColor: AppColors.brown,
            onChanged: (value) {
              setState(() {
                currentDamage = value;
              });
            },
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
            value: expectedDamage,
            min: 0,
            max: 100,
            divisions: 100,
            label: expectedDamage.round().toString(),
            activeColor: AppColors.brown,
            onChanged: (value) {
              setState(() {
                expectedDamage = value;
              });
            },
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
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
