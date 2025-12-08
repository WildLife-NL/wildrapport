import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/providers/belonging_damage_report_provider.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/screens/shared/overzicht_screen.dart';

class SchademeldingHistoryScreen extends StatelessWidget {
  const SchademeldingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder: In a future step, fetch from server and show a list.
    // For now, show a simple empty state and a mock item if current provider has data.
    final provider = context.read<BelongingDamageReportProvider>();
    final hasCurrent = provider.impactedCrop.isNotEmpty && provider.impactedArea != null;

    return Scaffold(
      backgroundColor: AppColors.lightMintGreen,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Schademelding logboek',
              rightIcon: null,
              showUserIcon: true,
              onLeftIconPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const OverzichtScreen(),
                  ),
                );
              },
              iconColor: Colors.black,
              textColor: Colors.black,
              fontScale: 1.15,
              iconScale: 1.15,
              userIconScale: 1.15,
              useFixedText: true,
            ),
            Expanded(
              child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!hasCurrent) ...[
            _EmptyState(),
          ] else ...[
            _HistoryCard(
              title: provider.impactedCrop,
              subtitle:
                  'Area: ${provider.impactedArea!.toStringAsFixed(0)} m² • Estimated: € ${provider.estimatedDamage.toStringAsFixed(2)}',
              onTap: () {},
            ),
          ],
        ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nog geen schadegeschiedenis',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Na het indienen van een schademelding wordt deze hier zichtbaar.',
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _HistoryCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
