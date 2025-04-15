import 'package:flutter/material.dart';

class LocationDisplay extends StatelessWidget {
  final VoidCallback? onLocationIconTap;
  final String locationText;

  const LocationDisplay({
    super.key,
    this.onLocationIconTap,
    this.locationText = 'Huidige locatie wordt geladen...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Makes container take full screen width
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end, // Align items to bottom
        children: [
          GestureDetector(
            onTap: () {
              onLocationIconTap?.call();
              debugPrint('Location icon tapped');
            },
            child: SizedBox(
              width: 107,
              height: 99,
              child: Image.asset(
                'assets/location/location_icon.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded( // Make the card take remaining width
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5.0), // Moves card 5px higher
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      locationText,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



