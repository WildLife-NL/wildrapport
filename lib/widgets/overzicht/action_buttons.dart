import 'package:flutter/material.dart';
import 'package:wildrapport/widgets/brown_button.dart';
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
            _buildMapButton(),
            _buildReportButton(onRapporterenPressed),
            _buildMyReportsButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMapButton() {
    return WhiteBulkButton(
      text: 'RapportenKaart',
      leftWidget: CircleIconContainer(
        icon: Icons.map,
        iconColor: AppColors.brown,
        size: 48,
      ),
      rightWidget: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildReportButton(Function() onPressed) {
    return WhiteBulkButton(
      text: 'Rapporteren',
      leftWidget: CircleIconContainer(
        icon: Icons.edit_note,
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

  Widget _buildMyReportsButton() {
    return WhiteBulkButton(
      text: 'Mijn Rapporten',
      leftWidget: CircleIconContainer(
        icon: Icons.description,
        iconColor: AppColors.brown,
        size: 48,
      ),
      rightWidget: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.black54,
      ),
    );
  }
}