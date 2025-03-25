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
                    offset: Offset(-(model?.leftIconPadding ?? 0) * 0.5, 0),  // Multiplied by 0.5 to reduce the offset
                    child: Image.asset(
                      model!.leftIconPath!,
                      width: model!.leftIconSize,
                      height: model!.leftIconSize,
                      fit: BoxFit.contain,
                    ),
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
}
















