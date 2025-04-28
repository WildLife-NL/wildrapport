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
  final String defaultValue;
  final bool hasError; // Add this property to check for error state

  const PossesionDropdown({
    super.key,
    this.onChanged,
    required this.getSelectedValue,
    required this.dropdownItems,
    this.containerWidth,
    this.containerHeight,
    required this.startingValue,
    required this.hasDropdownSideDescription,
    this.dropdownSideDescriptionText,
    required this.defaultValue,
    required this.hasError, // Pass error state from provider
  });

  @override
  State<PossesionDropdown> createState() => _PossesionDropdownState();
}

class _PossesionDropdownState extends State<PossesionDropdown> {
  bool isExpanded = false;
  late String selectedValue;
  OverlayEntry? overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    selectedValue = widget.getSelectedValue.isNotEmpty ? widget.getSelectedValue : widget.defaultValue;
  }

  @override
  void didUpdateWidget(covariant PossesionDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.getSelectedValue != oldWidget.getSelectedValue && widget.getSelectedValue.isNotEmpty) {
      selectedValue = widget.getSelectedValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          widget.hasDropdownSideDescription
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.dropdownSideDescriptionText ?? ''),
                    const SizedBox(width: 10),
                    buildMainButton(),
                  ],
                )
              : buildMainButton(),
          if (widget.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'This field is required',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildMainButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isExpanded) {
            overlayEntry?.remove();
            isExpanded = false;
          } else {
            showOverlay();
            isExpanded = true;
          }
        });
      },
      child: Container(
        key: _buttonKey, // Set the key to the button container
        width: widget.containerWidth ?? 200,
        height: widget.containerHeight ?? 50,
        decoration: BoxDecoration(
          color: const Color(0xFF6C452D),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: widget.hasError ? Colors.red : Colors.grey, // Red border on error
            width: 2.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20), // Ensure you know the padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.agriculture, color: Color(0xFF6C452D)),
            Text(
              selectedValue,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  void showOverlay() {
    final overlay = Overlay.of(context);

    // Get the position and size of the dropdown button using the RenderBox
    final RenderBox renderBox = _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final buttonPosition = renderBox.localToGlobal(Offset.zero); // Position relative to screen
    final double buttonWidth = renderBox.size.width; // Get the actual width of the button
    final double top = buttonPosition.dy + renderBox.size.height;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: top, // Position the dropdown right below the button
          left: buttonPosition.dx, // Align the dropdown with the button
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: widget.dropdownItems.map((item) {
                // Use the actual width of the button for the dropdown
                return buildDropdownItem(item, buttonWidth);
              }).toList(),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry!);
  }

  Widget buildDropdownItem(Map<String, String> item, double buttonWidth) {
    // Use the button's width for the dropdown items
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedValue = item['value']!;
          isExpanded = false;
        });
        widget.onChanged?.call(item['text']!);
        overlayEntry?.remove(); // Remove the dropdown after selection
      },
      child: Container(
        width: buttonWidth, // Use the same width as the button
        height: widget.containerHeight ?? 50,
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF6C452D),
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: Text(
          item['text']!,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}