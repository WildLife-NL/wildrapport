import 'package:flutter/material.dart';

class SnackBarText extends StatelessWidget {
  final String message;
  final Widget? trailing;

  const SnackBarText({
    super.key,
    required this.message,
    this.trailing,
  });

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
        if (trailing != null) trailing!,
      ],
    );
  }
}
