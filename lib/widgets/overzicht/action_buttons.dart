import 'package:flutter/material.dart';
import 'package:wildrapport/widgets/brown_button.dart';
import 'package:wildrapport/widgets/circle_icon_container.dart';
import 'package:wildrapport/widgets/white_bulk_button.dart';
import 'package:wildrapport/constants/app_colors.dart';

class ActionButtons extends StatelessWidget {
  final Function() onRapporterenPressed;

  const ActionButtons({
    super.key,
    required this.onRapporterenPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: MediaQuery.of(context).size.height * 0.02,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton(
              text: 'RapportenKaart',
              icon: Icons.map,
            ),
            _buildButton(
              text: 'Rapporteren',
              icon: Icons.edit_note,
              onPressed: onRapporterenPressed,
            ),
            _buildButton(
              text: 'Mijn Rapporten',
              icon: Icons.description,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return WhiteBulkButton(
      text: text,
      leftWidget: CircleIconContainer(
        icon: icon,
        iconColor: AppColors.brown,
        size: 48,
      ),
      rightWidget: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.black54,
      ),
      onPressed: onPressed,
    );
  }
}
