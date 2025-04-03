import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/models/brown_button_model.dart';

class BrownButton extends StatelessWidget {
  final BrownButtonModel? model;
  final VoidCallback onPressed;

  const BrownButton({
    super.key,
    this.model,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: model?.width ?? double.infinity,
      height: model?.height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brown,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 4,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (model?.leftIconPath != null && model!.leftIconPath!.isNotEmpty)
                  Transform.translate(
                    offset: Offset(-(model?.leftIconPadding ?? 0) * 0.5, 0),
                    child: _buildLeftIcon(),
                  )
                else
                  const SizedBox(width: 24),
                if (model?.rightIconPath != null && model!.rightIconPath!.isNotEmpty)
                  Image.asset(
                    model!.rightIconPath!,
                    width: model!.rightIconSize,
                    height: model!.rightIconSize,
                    fit: BoxFit.contain,
                  )
                else
                  const SizedBox(width: 24),
              ],
            ),
            Text(
              model?.text ?? '',
              style: TextStyle(
                fontSize: model?.fontSize ?? 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftIcon() {
    if (model?.leftIconPath?.startsWith('circle_icon:') ?? false) {
      final iconName = model!.leftIconPath!.split(':')[1];
      return CircleIconContainer(
        icon: _getIconData(iconName),
        iconColor: AppColors.brown,
      );
    }
    return Image.asset(
      model!.leftIconPath!,
      width: model!.leftIconSize,
      height: model!.leftIconSize,
      fit: BoxFit.contain,
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'sort_by_alpha':
        return Icons.sort_by_alpha;
      case 'category':
        return Icons.category;
      case 'visibility':
        return Icons.visibility;
      case 'filter_list':
        return Icons.filter_list;
      case 'restart_alt':
        return Icons.restart_alt;
      case 'search':
        return Icons.search;  // Added search icon
      default:
        return Icons.error;
    }
  }
}

class CircleIconContainer extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double size;

  const CircleIconContainer({
    super.key,
    required this.icon,
    required this.iconColor,
    this.size = 38.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: iconColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: size * 0.5,  // Icon size is half of container size
      ),
    );
  }
}























