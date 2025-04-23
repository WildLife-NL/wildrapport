import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';

class LocationDataCard extends StatelessWidget {
  final String? cityName;
  final String? streetName;
  final String? houseNumber;
  final bool isLoading;
  final bool isCurrentLocation;  // Add this parameter

  const LocationDataCard({
    super.key,
    this.cityName,
    this.streetName,
    this.houseNumber,
    this.isLoading = false,
    this.isCurrentLocation = true,  // Default to true for current location
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildCard(
        child: const Row(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            Text('Locatie wordt geladen...'),
          ],
        ),
      );
    }

    final Color locationColor = isCurrentLocation ? Colors.blue : Colors.red;
    final String titleText = isCurrentLocation ? 'Huidige Locatie' : 'Geselecteerde Locatie';

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            titleText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: locationColor,
            ),
          ),
          const SizedBox(height: 8),
          // Location info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: locationColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  color: locationColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (streetName != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${streetName!}${houseNumber != null ? " $houseNumber" : ""}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: locationColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                    ],
                    if (cityName != null)
                      Text(
                        cityName!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (cityName == null && streetName == null)
                      Text(
                        'Locatie niet beschikbaar',
                        style: TextStyle(
                          fontSize: 14,
                          color: locationColor,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),  // Restored border radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: child,
      ),
    );
  }
}





