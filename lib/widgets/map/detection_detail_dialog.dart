import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/api_models/detection_pin.dart';
import '../../constants/app_colors.dart';
import 'package:wildrapport/utils/translation_utils.dart';

class DetectionDetailDialog extends StatelessWidget {
  final DetectionPin detection;

  const DetectionDetailDialog({super.key, required this.detection});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.sensors,
                        size: 32,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detectie',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          if (detection.label != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              Translator.toDutch(detection.label!),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Device Type (if available)
                if (detection.deviceType != null) ...[
                  _buildInfoSection(
                    Icons.devices,
                    'Apparaat Type',
                    Text(
                      Translator.toDutch(detection.deviceType!),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Confidence (if available)
                if (detection.confidence != null) ...[
                  _buildInfoSection(
                    Icons.analytics,
                    'Betrouwbaarheid',
                    Text(
                      '${(detection.confidence! * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Date and Time
                _buildDateTimeInfo(),

                const SizedBox(height: 16),

                // Location
                _buildLocationInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeInfo() {
    final local = detection.detectedAt.toLocal();
    final now = DateTime.now();
    final difference = now.difference(local);

    String timeAgo;
    if (difference.inMinutes < 60) {
      timeAgo = '${difference.inMinutes} minuten geleden';
    } else if (difference.inHours < 24) {
      timeAgo = '${difference.inHours} uur geleden';
    } else {
      timeAgo = '${difference.inDays} dagen geleden';
    }

    return _buildInfoSection(
      Icons.calendar_today,
      'Datum & Tijd',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE d MMMM yyyy').format(local),
            style: const TextStyle(fontSize: 14, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('HH:mm').format(local),
            style: const TextStyle(fontSize: 14, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 4),
          Text(
            timeAgo,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return _buildInfoSection(
      Icons.location_on,
      'Locatie',
      Text(
        '${detection.lat.toStringAsFixed(6)}, ${detection.lon.toStringAsFixed(6)}',
        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildInfoSection(IconData icon, String title, Widget content) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }
}
