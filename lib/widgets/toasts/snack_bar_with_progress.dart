import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/widgets/toasts/snack_bar_text.dart';
import 'package:wildrapport/utils/snack_bar_utils.dart';

class SnackBarWithProgress extends StatelessWidget {
  const SnackBarWithProgress({super.key, required this.message});

  final String message;

  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    final snackBar = SnackBar(
      content: SnackBarText(message: message),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.offWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: snackBarMarginForContext(context),
    );

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return SnackBarText(message: message);
  }
}
