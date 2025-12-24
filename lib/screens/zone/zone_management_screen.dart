import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/providers/zone_provider.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/screens/shared/overzicht_screen.dart';

class ZoneManagementScreen extends StatefulWidget {
  const ZoneManagementScreen({super.key});

  @override
  State<ZoneManagementScreen> createState() => _ZoneManagementScreenState();
}

class _ZoneManagementScreenState extends State<ZoneManagementScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Load species once screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ZoneProvider>();
      provider.loadSpecies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZoneProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zonebeheer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context
                .read<NavigationStateInterface>()
                .pushReplacementBack(context, const OverzichtScreen());
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: (provider.createdZone != null &&
              provider.selectedSpeciesIds.isNotEmpty)
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.check),
              label: const Text('Geselecteerde soorten toewijzen'),
              onPressed: provider.isSubmitting
                  ? null
                  : () async {
                      await provider.assignSelectedSpecies();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Soorten toegewezen aan zone.'),
                        ),
                      );
                    },
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Naam'),
                    initialValue: provider.name,
                    onChanged: provider.setName,
                    validator: (v) => (v == null || v.trim().length < 2)
                        ? 'Minimaal 2 tekens'
                        : null,
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Beschrijving'),
                    initialValue: provider.description,
                    onChanged: provider.setDescription,
                    validator: (v) => (v == null || v.trim().length < 5)
                        ? 'Minimaal 5 tekens'
                        : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Breedtegraad'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => provider.setLatitude(double.tryParse(v) ?? 0),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Lengtegraad'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => provider.setLongitude(double.tryParse(v) ?? 0),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Straal (m)'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => provider.setRadius(double.tryParse(v) ?? 1),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: provider.isSubmitting
                        ? null
                        : () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              await provider.createZone();
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Zone aangemaakt: ${provider.createdZone?.id ?? 'onbekend'}',
                                  ),
                                ),
                              );
                            }
                          },
                    child: provider.isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text('Zone aanmaken'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (provider.createdZone != null) ...[
              Text('Zone-ID: ${provider.createdZone!.id}'),
              const SizedBox(height: 8),
              const Text('Selecteer soorten om toe te wijzen:'),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.allSpecies.length,
                itemBuilder: (context, index) {
                  final s = provider.allSpecies[index];
                  final selected = provider.selectedSpeciesIds.contains(s.id);
                  return CheckboxListTile(
                    title: Text(s.commonName),
                    subtitle: Text(s.category),
                    value: selected,
                    onChanged: (v) => provider.toggleSpecies(s.id, v ?? false),
                  );
                },
              ),
              const SizedBox(height: 92),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text('Toegekende soorten:'),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final assigned = provider.createdZone!.species;
                  if (assigned.isEmpty) {
                    return const Text('Geen soorten toegekend');
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: assigned.length,
                    itemBuilder: (context, index) {
                      final a = assigned[index];
                      return ListTile(
                        leading: const Icon(Icons.pets),
                        title: Text(a.commonName ?? 'Onbekende soort'),
                        subtitle: Text(a.category ?? ''),
                      );
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
