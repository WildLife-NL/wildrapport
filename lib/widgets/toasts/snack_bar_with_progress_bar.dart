import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/widgets/toasts/snack_bar_with_progress_bar_content.dart';
import 'package:wildrapport/utils/snack_bar_utils.dart';

class SnackBarWithProgressBar {
  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    final snackBar = SnackBar(
      content: SnackBarWithProgressBarContent(
        message: message,
        duration: duration,
      ),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.offWhite,
      padding: EdgeInsets.zero,
      margin: snackBarMarginForContext(context),
    );

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
