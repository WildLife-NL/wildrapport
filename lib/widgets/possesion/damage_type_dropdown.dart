import 'package:flutter/material.dart';

class DamageTypeDropdown extends StatefulWidget {
  final ValueChanged<String>? onChanged; 

  const DamageTypeDropdown({super.key, this.onChanged});

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
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0, top: 10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Getroffen Gebied'),
              const SizedBox(width: 10),
              Container(
                width: 150,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C452D),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/icons/possesion/impacted_area_type.png",
                          scale: 2,
                        ),
                      ],
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedValue,
                        isExpanded: true,
                        icon: const Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.expand_less, color: Colors.white),
                        ),
                        dropdownColor: const Color(0xFF6C452D),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedValue = newValue;
                            });
                            widget.onChanged?.call(newValue);
                          }
                        },
                        items: dropdownItems.map((item) {
                          return DropdownMenuItem<String>(
                            value: item['value'],
                            child: Center(
                              child: Text(item['text']!),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
