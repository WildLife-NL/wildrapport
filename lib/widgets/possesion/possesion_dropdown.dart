import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PossesionDropdown extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final String getSelectedValue;
  final String getSelectedText;
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
    required this.getSelectedText,
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
  late String selectedText;
  OverlayEntry? overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();
  final List<String> gewassIconList = [
    "assets/icons/possesion/gewassen/corn.svg",
    "assets/icons/possesion/gewassen/radish_2.svg",
    "assets/icons/possesion/gewassen/wheat.svg",
    "assets/icons/possesion/gewassen/tulip_2.svg",
    "assets/icons/possesion/gewassen/grass.svg",
    "assets/icons/possesion/gewassen/apple.svg",
    "assets/icons/possesion/gewassen/tomato.svg",
  ];

  @override
  void initState() {
    super.initState();
    selectedValue = widget.getSelectedValue.isNotEmpty ? widget.getSelectedValue : widget.defaultValue;
    selectedText = widget.getSelectedText.isNotEmpty ? widget.getSelectedText : widget.defaultValue; 
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
        const SizedBox(height: 4), // small space between dropdown and error text
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: SizedBox(
            height: 16, // always reserve space for 1 line of error text
            child: widget.hasError
                ? const Text(
                    'This field is required',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  )
                : const SizedBox.shrink(), // invisible when no error
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
          border: widget.hasError
              ? Border.all(color: Colors.red, width: 2.0)
              : Border.all(color: Colors.transparent, width: 0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),


        padding: const EdgeInsets.symmetric(horizontal: 20), // Ensure you know the padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.agriculture, color: Color(0xFF6C452D)),
            Text(
              selectedText,
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
              children: widget.dropdownItems.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, String> item = entry.value;
                return buildDropdownItem(item, buttonWidth, index);
              }).toList(),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry!);
  }
    Widget buildDropdownItem(Map<String, String> item, double buttonWidth, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedValue = item['value']!;
          selectedText = item['text']!;
          isExpanded = false;
        });
        widget.onChanged?.call(item['text']!);
        overlayEntry?.remove();
      },
      child: Container(
        width: buttonWidth,
        height: widget.containerHeight ?? 50,
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF6C452D),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SvgPicture.asset(
                gewassIconList[index],
                height: 20,
                width: 20,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
            Center(
              child: Text(
                item['text']!,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

}