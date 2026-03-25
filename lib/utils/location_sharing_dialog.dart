import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';

Future<bool?> showLocationSharingOffDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Locatie delen staat uit'),
      content: const Text(
        'Wil je locatie delen weer aanzetten? Dan kunnen we je locatie tonen op de kaart en bij rapporten.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Nee'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.darkGreen),
          child: const Text('Ja'),
        ),
      ],
    ),
  );
}
