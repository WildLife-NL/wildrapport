import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/api_models/detection_pin.dart';
import '../../constants/app_colors.dart';
import 'package:wildrapport/utils/api_datetime.dart';
import 'package:wildrapport/utils/translation_utils.dart';
import 'package:wildrapport/utils/species_icon_utils.dart';

class DetectionDetailDialog extends StatelessWidget {
  final DetectionPin detection;

  const DetectionDetailDialog({super.key, required this.detection});

  static const double _cardHeight = 230;
  static const double _imageWidth = 150;

  @override
  Widget build(BuildContext context) {
    final label = detection.label != null
        ? Translator.toDutch(detection.label!)
        : 'Onbekende detectie';

    final rawKind = (detection.deviceType ?? detection.type ?? '').toLowerCase();
    final isCameraOrAcoustic = rawKind.contains('camera') ||
      rawKind.contains('cameraval') ||
      rawKind.contains('visual') ||
      rawKind.contains('acoustic') ||
      rawKind.contains('akoestisch');

    final deviceLabel = detection.deviceType != null
      ? Translator.toDutch(detection.deviceType!)
      : 'Detectie';

    final subtitleLabel = (isCameraOrAcoustic &&
        detection.speciesLatinName != null &&
        detection.speciesLatinName!.isNotEmpty)
      ? detection.speciesLatinName!
      : deviceLabel;

    final animalDetails = isCameraOrAcoustic
        ? <String>[
            if (detection.animalLifeStage != null &&
                detection.animalLifeStage!.isNotEmpty)
              _formatAnimalLifeStage(detection.animalLifeStage!),
            if (detection.animalSex != null && detection.animalSex!.isNotEmpty)
              _formatAnimalSex(detection.animalSex!),
          ]
        : const <String>[];

    final animalSummary = isCameraOrAcoustic
        ? _buildAnimalSummary(
            count: detection.animalCount,
            details: animalDetails,
          )
        : null;

    final iconPath = detection.label != null
        ? getSpeciesCardImagePath(detection.label!)
        : null;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              height: _cardHeight,
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                color: Colors.white,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: Color(0xFF999999),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: _imageWidth,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0D9C9),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: _buildImage(iconPath),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 14, 11),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _detectionTypePill(detection.deviceType),
                            const SizedBox(height: 7),
                            Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                                height: 1.0,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              subtitleLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF777777),
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 13),
                            if (detection.confidence != null)
                              _infoRow(
                                icon: Icons.analytics_outlined,
                                child: Text(
                                  '${(detection.confidence! * 100).toStringAsFixed(1)}% betrouwbaar',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textPrimary,
                                    height: 1.18,
                                  ),
                                ),
                              ),
                            if (detection.confidence != null)
                              const SizedBox(height: 10),
                            if (animalSummary != null) ...[
                              _infoRow(
                                icon: Icons.pets,
                                child: Text(
                                  animalSummary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textPrimary,
                                    height: 1.18,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            _dateTimeRow(),
                            const Spacer(),
                            const Divider(
                              height: 12,
                              thickness: 1,
                              color: Color(0xFFE8E8E8),
                            ),
                            if (isCameraOrAcoustic)
                              _infoRow(
                                icon: Icons.person_outline,
                                iconSize: 17,
                                child: RichText(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF777777),
                                      height: 1.2,
                                    ),
                                    children: [
                                      const TextSpan(text: 'Gemeld door: '),
                                      TextSpan(
                                        text: (detection.reportedByName != null && detection.reportedByName!.isNotEmpty)
                                            ? detection.reportedByName!
                                            : 'unavailable',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              _infoRow(
                                icon: Icons.location_on_outlined,
                                iconSize: 17,
                                child: Text(
                                  '${detection.lat.toStringAsFixed(6)}, ${detection.lon.toStringAsFixed(6)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF777777),
                                    height: 1.2,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detectionTypePill(String? deviceType) {
    final color = _detectionTypeColor(deviceType);
    final label = deviceType != null
        ? Translator.toDutch(deviceType).toUpperCase()
        : 'DETECTIE';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: color,
          height: 1.0,
        ),
      ),
    );
  }

  Color _detectionTypeColor(String? deviceType) {
    final value = deviceType?.toLowerCase() ?? '';

    if (value.contains('camera') || value.contains('visual')) {
      return const Color(0xFF00BFD8);
    }
    if (value.contains('acoustic') || value.contains('akoestisch')) {
      return const Color(0xFFFF9100);
    }
    if (value.contains('collar') ||
        value.contains('diergedragen') ||
        value.contains('wearable')) {
      return const Color(0xFFFE008E);
    }

    return const Color(0xFF777777);
  }

  String _formatAnimalSex(String raw) {
    final value = raw.trim().toLowerCase();
    if (value == 'male' || value == 'm' || value == 'man') return 'mannetje';
    if (value == 'female' || value == 'f' || value == 'vrouw') {
      return 'vrouwtje';
    }
    return raw;
  }

  String _formatAnimalLifeStage(String raw) {
    final value = raw.trim().toLowerCase();
    if (value == 'adult') return 'volwassen';
    if (value == 'juvenile' || value == 'young') return 'jong';
    if (value == 'infant' || value == 'subadult') return 'jong';
    return raw;
  }

  String _buildAnimalSummary({
    required int? count,
    required List<String> details,
  }) {
    final effectiveCount = count != null && count > 0 ? count : 1;
    if (details.isEmpty) return _animalCountText(effectiveCount);

    final lifeStage = details.where(_isLifeStageLabel).toList();
    final sex = details.where(_isSexLabel).toList();

    final descriptorParts = <String>[];
    if (lifeStage.isNotEmpty) {
      descriptorParts.add(_formatLifeStageForCount(lifeStage.first, effectiveCount));
    }
    if (sex.isNotEmpty) {
      descriptorParts.add(_formatSexForCount(sex.first, effectiveCount));
    }

    if (descriptorParts.isEmpty) return _animalCountText(effectiveCount);
    return '$effectiveCount ${descriptorParts.join(' ')}';
  }

  Widget _dateTimeRow() {
    final local = toLocalWallClock(detection.detectedAt);

    return Row(
      children: [
        _smallIcon(Icons.calendar_today_outlined),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            DateFormat('dd-MM-yyyy').format(local),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 14),
        _smallIcon(Icons.access_time),
        const SizedBox(width: 5),
        Text(
          DateFormat('HH:mm').format(local),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _animalCountText(int? count) {
    final effectiveCount = count != null && count > 0 ? count : 1;
    return '$effectiveCount ${effectiveCount == 1 ? 'dier' : 'dieren'}';
  }

  bool _isLifeStageLabel(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'jong' ||
        normalized == 'volwassen' ||
        normalized == 'oud';
  }

  bool _isSexLabel(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'mannetje' || normalized == 'vrouwtje';
  }

  String _formatLifeStageForCount(String value, int count) {
    final normalized = value.trim().toLowerCase();
    if (count == 1) return value;
    switch (normalized) {
      case 'jong':
        return 'jonge';
      case 'volwassen':
        return 'volwassen';
      case 'oud':
        return 'oude';
      default:
        return value;
    }
  }

  String _formatSexForCount(String value, int count) {
    final normalized = value.trim().toLowerCase();
    if (count == 1) return value;
    switch (normalized) {
      case 'mannetje':
        return 'mannetjes';
      case 'vrouwtje':
        return 'vrouwtjes';
      default:
        return value;
    }
  }

  Widget _infoRow({
    required IconData icon,
    required Widget child,
    double iconSize = 16,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _smallIcon(icon, size: iconSize),
        const SizedBox(width: 7),
        Expanded(child: child),
      ],
    );
  }

  Widget _smallIcon(IconData icon, {double size = 14}) {
    return Icon(
      icon,
      size: size,
      color: const Color(0xFF777777),
    );
  }

  Widget _buildImage(String? iconPath) {
    if (iconPath != null && iconPath.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        child: Image.asset(
          iconPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.sensors,
            size: 38,
            color: AppColors.darkCharcoal,
          ),
        ),
      );
    }

    return const Icon(
      Icons.sensors,
      size: 38,
      color: AppColors.darkCharcoal,
    );
  }
}
