import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';

class SnackBarWithProgress extends StatelessWidget {
  const SnackBarWithProgress({super.key, required this.message});

  final String message;

  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontFamily: 'Arimo',
              ),
            ),
          ),
        ],
      ),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.offWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 205,
        right: 20,
        left: 20,
      ),
    );

    // Clear any existing snackbars to prevent stacking
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontFamily: 'Arimo',
            ),
          ),
        ),
      ],
    );
  }
}
