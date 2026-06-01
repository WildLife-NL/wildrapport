import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/utils/species_icon_utils.dart';
import 'package:wildrapport/utils/zone_api_parser.dart';

class ZoneSpeciesSilhouettesRow extends StatelessWidget {
  const ZoneSpeciesSilhouettesRow({
    super.key,
    required this.species,
    this.iconSize = 28,
    this.iconOnDarkBackground = false,
  });

  final List<ZoneSpeciesRef> species;
  final double iconSize;
  final bool iconOnDarkBackground;

  @override
  Widget build(BuildContext context) {
    if (species.isEmpty) {
      return Text(
        'Geen dieren gekoppeld',
        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
      );
    }

    return SizedBox(
      height: iconSize + 2,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: species.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final item = species[index];
          return Tooltip(
            message: item.commonName,
            child: _SpeciesSilhouette(
              commonName: item.commonName,
              size: iconSize,
              onDarkBackground: iconOnDarkBackground,
            ),
          );
        },
      ),
    );
  }
}

class _SpeciesSilhouette extends StatelessWidget {
  const _SpeciesSilhouette({
    required this.commonName,
    required this.size,
    this.onDarkBackground = false,
  });

  final String commonName;
  final double size;
  final bool onDarkBackground;

  @override
  Widget build(BuildContext context) {
    final fallbackColor =
        onDarkBackground ? Colors.white : AppColors.primaryGreen;
    final path = getSpeciesIconPath(commonName);
    Widget child;
    if (path == null) {
      child = Icon(Icons.pets, size: size * 0.7, color: fallbackColor);
    } else {
      child = Image.asset(
        path,
        fit: BoxFit.contain,
        color: onDarkBackground ? Colors.white : null,
        colorBlendMode: onDarkBackground ? BlendMode.srcIn : null,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.pets, size: size * 0.7, color: fallbackColor),
      );
    }
    return SizedBox(width: size, height: size, child: child);
  }
}
