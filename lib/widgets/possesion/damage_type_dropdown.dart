import 'package:flutter/material.dart';

class DamageTypeDropdown extends StatefulWidget {
  const DamageTypeDropdown({super.key});

  @override
  State<DamageTypeDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<DamageTypeDropdown> {
  String selectedValue = 'hectare';

  final List<Map<String, String>> dropdownItems = [
    {'text': 'ha', 'value': 'hectare'},
    {'text': 'm2', 'value': 'vierkante meters'},
    {'text': '%', 'value': 'percentage'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text('Getroffen Gebied'),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF6C452D), // Brown background
                borderRadius: BorderRadius.circular(30),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedValue,
                  dropdownColor: const Color(0xFF6C452D),
                  icon: const Icon(Icons.expand_less, color: Colors.white),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValue = newValue!;
                    });
                  },
                  items: dropdownItems.map((item) {
                    return DropdownMenuItem<String>(
                      value: item['value'],
                      child: Text(item['text']!),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
