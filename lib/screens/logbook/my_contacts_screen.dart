import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/data_managers/contact_api.dart';
import 'package:wildrapport/models/api_models/contact_model.dart';
import 'package:wildrapport/utils/api_datetime.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';

class MyContactsScreen extends StatefulWidget {
  const MyContactsScreen({super.key});

  @override
  State<MyContactsScreen> createState() => _MyContactsScreenState();
}

class _MyContactsScreenState extends State<MyContactsScreen> {
  late Future<List<Contact>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _contactsFuture = context.read<ContactApi>().getMyContacts();
  }

  Future<void> _onRefresh() async {
    setState(_reload);
    await _contactsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomAppBar(
              centerText: 'Contactmomenten',
              leftIcon: Icons.arrow_back_ios,
              rightIcon: null,
              showUserIcon: false,
              useFixedText: true,
              onLeftIconPressed: () => Navigator.pop(context),
              iconColor: AppColors.textPrimary,
              textColor: AppColors.textPrimary,
              fontScale: 1.4,
              iconScale: 1.15,
            ),
            Expanded(
              child: FutureBuilder<List<Contact>>(
                future: _contactsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Laden mislukt:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    );
                  }

                  final contacts = List<Contact>.from(snapshot.data ?? [])
                    ..sort((a, b) => b.start.compareTo(a.start));

                  if (contacts.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Nog geen contactmomenten. Zet contacttracing aan '
                              'onder Profiel → Voorkeuren.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.6),
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        return _ContactCard(contact: contacts[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final active = contact.isActive;
    final startLabel =
        '${formatLocalDate(contact.start)} ${formatLocalTime(contact.start)}';
    final endLabel = contact.end == null
        ? '—'
        : '${formatLocalDate(contact.end)} ${formatLocalTime(contact.end)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    contact.collarAnimalName ?? 'Collar / dier onbekend',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (active)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Actief',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
              ],
            ),
            if (contact.contactHardwareAddress != null) ...[
              const SizedBox(height: 4),
              Text(
                contact.contactHardwareAddress!,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Colors.grey.shade700,
                ),
              ),
            ],
            if (contact.sensorId != null) ...[
              const SizedBox(height: 4),
              Text(
                'Sensor: ${contact.sensorId}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
            const SizedBox(height: 10),
            _row('Start', startLabel),
            _row('Einde', endLabel),
            if (contact.conveyances.isNotEmpty)
              _row(
                'Berichten',
                '${contact.conveyances.length} conveyance(s)',
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
