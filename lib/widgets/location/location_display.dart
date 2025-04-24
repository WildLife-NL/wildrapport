import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lottie/lottie.dart';

class LocationDisplay extends StatelessWidget {
  final VoidCallback? onLocationIconTap;
  final String locationText;
  final bool isLoading;

  const LocationDisplay({
    super.key,
    this.onLocationIconTap,
    this.locationText = 'Huidige locatie wordt geladen...',
    this.isLoading = false,
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
              padding: const EdgeInsets.only(bottom: 10.0),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: isLoading
                      ? Center(
                          child: SizedBox(
                            height: 36,
                            child: Lottie.asset(
                              'assets/loaders/loading_paw.json',
                              fit: BoxFit.contain,
                              repeat: true,
                              animate: true,
                              frameRate: FrameRate(60),
                            ),
                          ),
                        )
                      : AutoSizeText(
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









