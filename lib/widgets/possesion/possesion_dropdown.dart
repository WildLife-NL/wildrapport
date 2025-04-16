import 'package:flutter/material.dart';

class PossesionDropdown extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final String getSelectedValue;
  final List<Map<String, String>> dropdownItems;
  final double? containerWidth;
  final double? containerHeight;
  final String startingValue;
  final bool hasDropdownSideDescription;
  final String? dropdownSideDescriptionText;

  const PossesionDropdown(
    {
      super.key, 
      this.onChanged, 
      required this.getSelectedValue,
      required this.dropdownItems,
      this.containerWidth,
      this.containerHeight,
      required this.startingValue,
      required this.hasDropdownSideDescription,
      this.dropdownSideDescriptionText,
    }
  );

  @override
  State<PossesionDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<PossesionDropdown> {

  @override
  Widget build(BuildContext context) {
    String selectedValue;
    if(widget.getSelectedValue.isNotEmpty){ selectedValue = widget.getSelectedValue; } else { selectedValue = widget.startingValue; }
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0, top: 10.0),
      child: Column(
        children: [
          widget.hasDropdownSideDescription
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.dropdownSideDescriptionText!),
                  const SizedBox(width: 10),
                  buildDropdownContainer(),
                ],
              )
            : Center(
                child: buildDropdownContainer(),
              ),
        ],
      ),
    );
  }
  Widget buildDropdownContainer() {
  String selectedValue = widget.getSelectedValue.isNotEmpty
      ? widget.getSelectedValue
      : widget.startingValue;

  return Container(
    width: widget.containerWidth ?? 150,
    height: widget.containerHeight ?? 40,
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
            if(widget.hasDropdownSideDescription)
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
            items: widget.dropdownItems.map((item) {
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
  );
}

}
