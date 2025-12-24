import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/providers/alarms_provider.dart';

class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({super.key});

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlarmsProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlarmsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Mijn alarmen')),
      body: RefreshIndicator(
        onRefresh: () => provider.refresh(),
        child: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Fout bij ophalen: ${provider.error}'),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: provider.alarms.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final a = provider.alarms[index];
                      final species = a.animal?.commonName ?? 'Onbekend';
                      final zoneName = a.zone.name.isNotEmpty
                          ? a.zone.name
                          : a.zone.id;
                      final ts = a.timestamp.toLocal();
                      return ListTile(
                        leading: const Icon(Icons.notifications_active),
                        title: Text('$species • $zoneName'),
                        subtitle: Text(
                          'Tijdstip: ${ts.toIso8601String()}\nBerichten: ${a.conveyances.length}',
                        ),
                        trailing: _severityChip(a),
                      );
                    },
                  ),
      ),
    );
  }

  Widget? _severityChip(alarm) {
    final sev = alarm.conveyances.isNotEmpty ? alarm.conveyances.first.severity : null;
    if (sev == null) return null;
    Color color;
    if (sev >= 3) {
      color = Colors.red;
    } else if (sev == 2) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }
    return Chip(label: Text('Niveau $sev'), backgroundColor: color.withOpacity(0.2));
  }
}
