import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/data_managers/my_interaction_api.dart';
import 'package:wildrapport/models/api_models/my_interaction.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/screens/logbook/logbook_screen.dart';

class WaarnemingHistoryScreen extends StatelessWidget {
  const WaarnemingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = context.read<ApiClient>();
    final myInteractionApi = MyInteractionApi(apiClient);
    final interactionsFuture = myInteractionApi.getMyInteractions();

    return Scaffold(
      backgroundColor: AppColors.lightMintGreen,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Waarneming geschiedenis',
              rightIcon: null,
              showUserIcon: true,
              onLeftIconPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LogbookScreen()),
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
              child: FutureBuilder<List<MyInteraction>>(
                future: interactionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.darkGreen,
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return const _EmptyState(
                      title: 'Fout bij laden',
                      subtitle: 'Kon waarnemingen niet laden. Probeer opnieuw.',
                    );
                  }

                  final data = snapshot.data ?? [];
                  final filtered = data.where((e) => e.type.id == 1).toList();

                  if (filtered.isEmpty) {
                    return const _EmptyState(
                      title: 'Nog geen waarnemingen',
                      subtitle:
                          'Na het indienen van een waarneming wordt deze hier zichtbaar.',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _InteractionTile(interaction: filtered[index]);
                    },
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

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle),
        ],
      ),
    );
  }
}

class _InteractionTile extends StatelessWidget {
  final MyInteraction interaction;
  const _InteractionTile({required this.interaction});

  String _formatDateTime(DateTime dt) =>
      DateFormat('dd MMM yyyy, HH:mm').format(dt);

  @override
  Widget build(BuildContext context) {
    final species =
        interaction.species.commonName.isNotEmpty
            ? interaction.species.commonName
            : interaction.species.name;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          species,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (interaction.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  interaction.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(_formatDateTime(interaction.moment)),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _InteractionDetailSheet(interaction: interaction),
            ),
          );
        },
      ),
    );
  }
}

class _InteractionDetailSheet extends StatelessWidget {
  final MyInteraction interaction;
  const _InteractionDetailSheet({required this.interaction});

  String _formatDateTime(DateTime dt) =>
      DateFormat('dd MMM yyyy, HH:mm').format(dt);

  @override
  Widget build(BuildContext context) {
    final species =
        interaction.species.commonName.isNotEmpty
            ? interaction.species.commonName
            : interaction.species.name;

    return Scaffold(
      backgroundColor: AppColors.lightMintGreen,
      appBar: AppBar(
        backgroundColor: AppColors.lightMintGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text('Details', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  species,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(_formatDateTime(interaction.moment), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                if (interaction.description.isNotEmpty) ...[
                  Text('Beschrijving:', style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(interaction.description, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                ],
                Text('Locatie:', style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(
                  '${interaction.place.latitude.toStringAsFixed(5)}, ${interaction.place.longitude.toStringAsFixed(5)}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text('Ingediend door:', style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(interaction.user.name, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                if (interaction.species.category.isNotEmpty) ...[
                  Text('Dierencategorie:', style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(interaction.species.category, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                ],
                if (interaction.reportOfSighting != null && interaction.reportOfSighting!.involvedAnimals.isNotEmpty) ...[
                  Text('Betrokken dieren (${interaction.reportOfSighting!.involvedAnimals.length}):', style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  ...interaction.reportOfSighting!.involvedAnimals.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final animal = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Dier $idx', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
                            const SizedBox(height: 4),
                            Text('Geslacht: ${animal.sex}', style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
                            Text('Levensstadium: ${animal.lifeStage}', style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
                            Text('Toestand: ${animal.condition}', style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 12),
                ],
                if (interaction.questionnaire != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Vragenlijst: ${interaction.questionnaire!.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
