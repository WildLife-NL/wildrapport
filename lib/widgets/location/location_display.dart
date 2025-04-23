import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0), // Increased bottom padding
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
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 12.0, // Increased top padding
                    bottom: 16.0, // Increased bottom padding
                  ),
                  child: AutoSizeText(
                    locationText,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    minFontSize: 12,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
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








