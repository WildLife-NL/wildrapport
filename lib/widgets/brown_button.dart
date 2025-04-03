import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/models/brown_button_model.dart';
import 'package:wildrapport/widgets/circle_icon_container.dart';

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
                  _buildRightIcon()
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
        size: model!.leftIconSize ?? 38.0,  // Use the model's size
      );
    }
    return Image.asset(
      model!.leftIconPath!,
      width: model!.leftIconSize,
      height: model!.leftIconSize,
      fit: BoxFit.contain,
    );
  }

  Widget _buildRightIcon() {
    if (model?.rightIconPath?.startsWith('circle_icon:') ?? false) {
      final iconName = model!.rightIconPath!.split(':')[1];
      return Transform.translate(
        offset: const Offset(3, 0),  // Move 3px to the right
        child: CircleIconContainer(
          icon: _getIconData(iconName),
          iconColor: AppColors.brown,
          size: model!.rightIconSize ?? 38.0,
          iconSize: (model!.rightIconSize ?? 38.0) * 0.75,  // Increased from 0.6 to 0.75 for bigger arrows
        ),
      );
    }
    return Image.asset(
      model!.rightIconPath!,
      width: model!.rightIconSize,
      height: model!.rightIconSize,
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
        return Icons.search;
      case 'keyboard_arrow_up':
        return Icons.keyboard_arrow_up;
      case 'keyboard_arrow_down':
        return Icons.keyboard_arrow_down;
      case 'arrow_forward_ios':
        return Icons.arrow_forward_ios;
      case 'pets':
        return Icons.pets;
      default:
        return Icons.error;
    }
  }
}
