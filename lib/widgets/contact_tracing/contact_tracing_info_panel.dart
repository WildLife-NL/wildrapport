import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/models/api_models/contact_model.dart';
import 'package:wildrapport/utils/api_datetime.dart';

/// Modaal overzicht na start van een contact (dier + onderzoekersberichten).
Future<void> showContactTracingDetailsSheet(
  BuildContext context,
  Contact contact,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFEFF2EF),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      final bottom = MediaQuery.paddingOf(context).bottom;
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottom),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Contact gestart',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Informatie over het gekoppelde dier en eventuele berichten.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                ContactTracingInfoPanel(contact: contact),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                  ),
                  child: const Text('Sluiten'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

/// Toont dier- en onderzoekersberichten (conveyances) van een contactmoment.
class ContactTracingInfoPanel extends StatelessWidget {
  const ContactTracingInfoPanel({
    super.key,
    required this.contact,
    this.compact = false,
    this.showHardwareAddress = true,
  });

  final Contact contact;
  final bool compact;
  final bool showHardwareAddress;

  @override
  Widget build(BuildContext context) {
    final hasAnimal = contact.hasAnimalInfo;
    final messages = contact.conveyancesWithMessages;
    if (!hasAnimal && messages.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasAnimal) ...[
          _AnimalCard(contact: contact, compact: compact, showMac: showHardwareAddress),
          if (messages.isNotEmpty) SizedBox(height: compact ? 10 : 14),
        ],
        if (messages.isNotEmpty) _ConveyancesSection(conveyances: messages, compact: compact),
      ],
    );
  }
}

class _AnimalCard extends StatelessWidget {
  const _AnimalCard({
    required this.contact,
    required this.compact,
    required this.showMac,
  });

  final Contact contact;
  final bool compact;
  final bool showMac;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.pets_rounded,
            color: AppColors.primaryGreen,
            size: compact ? 28 : 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.displayAnimalTitle,
                  style: TextStyle(
                    fontSize: compact ? 15 : 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (contact.displayAnimalSubtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    contact.displayAnimalSubtitle!,
                    style: TextStyle(
                      fontSize: compact ? 13 : 14,
                      color: Colors.grey.shade800,
                      height: 1.3,
                    ),
                  ),
                ],
                if (contact.sensorId != null) ...[
                  const SizedBox(height: 6),
                  _metaRow('Sensor', contact.sensorId!),
                ],
                if (showMac && contact.contactHardwareAddress != null) ...[
                  const SizedBox(height: 4),
                  _metaRow('Collar', contact.contactHardwareAddress!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.35),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _ConveyancesSection extends StatelessWidget {
  const _ConveyancesSection({
    required this.conveyances,
    required this.compact,
  });

  final List<ContactConveyance> conveyances;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          conveyances.length == 1
              ? 'Bericht van onderzoeker'
              : 'Berichten van onderzoekers (${conveyances.length})',
          style: TextStyle(
            fontSize: compact ? 12 : 13,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade700,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: compact ? 8 : 10),
        ...conveyances.map(
          (c) => Padding(
            padding: EdgeInsets.only(bottom: compact ? 8 : 10),
            child: _ConveyanceCard(conveyance: c, compact: compact),
          ),
        ),
      ],
    );
  }
}

class _ConveyanceCard extends StatelessWidget {
  const _ConveyanceCard({
    required this.conveyance,
    required this.compact,
  });

  final ContactConveyance conveyance;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final title = conveyance.displayTitle;
    final body = conveyance.messageText?.trim();
    final hasBody = body != null && body.isNotEmpty;
    final severity = conveyance.messageSeverity;
    final severityColor = _severityColor(severity);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.campaign_outlined,
                size: 20,
                color: severityColor ?? AppColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: compact ? 14 : 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (severity != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (severityColor ?? AppColors.primaryGreen)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    conveyance.severityLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: severityColor ?? AppColors.primaryGreen,
                    ),
                  ),
                ),
            ],
          ),
          if (conveyance.animalName != null &&
              conveyance.animalName!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Betreft: ${conveyance.animalName}',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade700,
              ),
            ),
          ],
          if (hasBody) ...[
            const SizedBox(height: 8),
            SelectableText(
              body,
              style: TextStyle(
                fontSize: compact ? 13 : 14,
                height: 1.45,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            formatLocalTime(conveyance.timestamp),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Color? _severityColor(int? severity) {
    return switch (severity) {
      1 => Colors.red.shade700,
      2 => Colors.orange.shade700,
      3 => Colors.amber.shade800,
      _ => null,
    };
  }
}
