import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/providers/zone_provider.dart';

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
      appBar: AppBar(title: const Text('Zone Management')),
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
                    decoration: const InputDecoration(labelText: 'Name'),
                    initialValue: provider.name,
                    onChanged: provider.setName,
                    validator: (v) => (v == null || v.trim().length < 2)
                        ? 'Min 2 characters'
                        : null,
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Description'),
                    initialValue: provider.description,
                    onChanged: provider.setDescription,
                    validator: (v) => (v == null || v.trim().length < 5)
                        ? 'Min 5 characters'
                        : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => provider.setLatitude(double.tryParse(v) ?? 0),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Longitude'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => provider.setLongitude(double.tryParse(v) ?? 0),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Radius (m)'),
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
                                    'Zone created: ${provider.createdZone?.id ?? 'unknown'}',
                                  ),
                                ),
                              );
                            }
                          },
                    child: provider.isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text('Create Zone'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (provider.createdZone != null) ...[
              Text('Zone ID: ${provider.createdZone!.id}'),
              const SizedBox(height: 8),
              const Text('Select species to assign:'),
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
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: provider.isSubmitting
                    ? null
                    : () async {
                        await provider.assignSelectedSpecies();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Species assigned to zone.'),
                          ),
                        );
                      },
                child: provider.isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Assign Selected Species'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
