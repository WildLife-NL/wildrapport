import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/button_layout.dart';
import 'package:wildrapport/data_managers/alarms_api.dart';
import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/interfaces/data_apis/species_api_interface.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildlifenl_alarms_components/wildlifenl_alarms_components.dart';

class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({super.key});

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
  List<Alarm>? _alarms;
  Map<String, String> _speciesCommonNames = {};
  String? _error;
  bool _loading = true;
  bool _showAllAlarms = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = AlarmsApi(AlarmsApiClientAdapter(context.read<ApiClient>()));
      final list = _showAllAlarms
          ? await api.getAllAlarms()
          : await api.getMyAlarms();
      Map<String, String> commonNames = {};
      try {
        final speciesApi = context.read<SpeciesApiInterface>();
        final speciesList = await speciesApi.getAllSpecies();
        for (final s in speciesList) {
          if (s.commonName.isNotEmpty) commonNames[s.id] = s.commonName;
        }
      } catch (_) {}
      if (mounted) {
        setState(() {
          _alarms = list;
          _speciesCommonNames = commonNames;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  void _switchMode(bool showAll) {
    if (_showAllAlarms == showAll) return;
    setState(() => _showAllAlarms = showAll);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightMintGreen,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: _showAllAlarms ? 'Alle alarmen' : "Mijn alarmen",
              rightIcon: null,
              showUserIcon: false,
              onLeftIconPressed: () {
                Navigator.of(context).pop();
              },
              iconColor: Colors.black,
              textColor: Colors.black,
              fontScale: 1.15,
              iconScale: 1.15,
              userIconScale: 1.15,
              useFixedText: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _SegmentChip(
                      label: 'Mijn alarmen',
                      selected: !_showAllAlarms,
                      onTap: () => _switchMode(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SegmentChip(
                      label: 'Alle alarmen',
                      selected: _showAllAlarms,
                      onTap: () => _switchMode(true),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.darkGreen),
            const SizedBox(height: 16),
            Text(
              _showAllAlarms ? 'Alle alarmen ophalen…' : 'Alarmen ophalen…',
              style: const TextStyle(color: Colors.black87),
            ),
          ],
        ),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[700]),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700], fontSize: 14),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Opnieuw proberen'),
                style: TextButton.styleFrom(foregroundColor: AppColors.darkGreen),
              ),
            ],
          ),
        ),
      );
    }
    final list = _alarms ?? [];
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Geen alarmen',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              _showAllAlarms
                  ? 'Er zijn geen alarmen.'
                  : 'Je hebt op dit moment geen alarmen voor je zones.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.darkGreen,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final alarm = list[index];
          return _AlarmTile(
            alarm: alarm,
            speciesCommonNames: _speciesCommonNames,
            onTap: () => _showAlarmDetail(context, alarm),
          );
        },
      ),
    );
  }

  void _showAlarmDetail(BuildContext context, Alarm alarm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AlarmDetailSheet(
        alarm: alarm,
        speciesCommonNames: _speciesCommonNames,
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.darkGreen : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: kMinTouchTargetHeight),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

String? _speciesDisplayName(Alarm alarm, Map<String, String> speciesCommonNames) {
  final species = alarm.animal?.species;
  if (species == null) return null;
  try {
    final d = species as dynamic;
    final id = d.id ?? d.ID;
    if (id != null) {
      final idStr = id.toString().trim();
      final common = speciesCommonNames[idStr];
      if (common != null && common.isNotEmpty) return common;
    }
  } catch (_) {}
  final name = species.name;
  if (name != null && name.toString().trim().isNotEmpty) return name.toString().trim();
  return null;
}

String _defaultAlarmSummary(Alarm alarm, Map<String, String> speciesCommonNames) {
  final zoneName = alarm.zone.name ?? 'je zone';
  final speciesName = _speciesDisplayName(alarm, speciesCommonNames);
  if (speciesName != null) {
    return 'Er is een $speciesName in je $zoneName.';
  }
  if (alarm.detection != null) return 'Er is een detectie in je $zoneName.';
  if (alarm.interaction != null) return 'Er is een interactie in je $zoneName.';
  return 'Er is activiteit in je $zoneName.';
}

class _AlarmTile extends StatelessWidget {
  const _AlarmTile({
    required this.alarm,
    required this.speciesCommonNames,
    this.onTap,
  });

  final Alarm alarm;
  final Map<String, String> speciesCommonNames;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final zoneName = alarm.zone.name ?? 'Zone';
    final message = alarm.firstMessageText;
    final summary = (message != null && message.isNotEmpty)
        ? message
        : _defaultAlarmSummary(alarm, speciesCommonNames);
    final timestamp = alarm.timestamp;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.darkGreen.withValues(alpha: 0.2),
          child: const Icon(Icons.notifications_active, color: AppColors.darkGreen),
        ),
        title: Text(
          zoneName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _formatTimestamp(timestamp),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    if (timestamp.isEmpty) return '';
    try {
      final dt = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays > 0) return '${diff.inDays} dag geleden';
      if (diff.inHours > 0) return '${diff.inHours} uur geleden';
      if (diff.inMinutes > 0) return '${diff.inMinutes} min geleden';
      return 'Zojuist';
    } catch (_) {
      return timestamp;
    }
  }
}

class _AlarmDetailSheet extends StatelessWidget {
  const _AlarmDetailSheet({
    required this.alarm,
    required this.speciesCommonNames,
  });

  final Alarm alarm;
  final Map<String, String> speciesCommonNames;

  bool _hasConveyanceMessage(Alarm a) {
    for (final c in a.conveyances) {
      if ((c.message.title != null && c.message.title!.isNotEmpty) ||
          (c.message.body != null && c.message.body!.isNotEmpty)) {
        return true;
      }
    }
    return false;
  }

  String? _speciesName(Alarm a) {
    return _speciesDisplayName(a, speciesCommonNames);
  }

  String _eventTypeLabel(Alarm a) {
    final parts = <String>[];
    if (a.detection != null) parts.add('Detectie');
    if (a.interaction != null) parts.add('Interactie');
    if (parts.isEmpty) return '—';
    return parts.join(', ');
  }

  Widget _prominentMessageBlock(Alarm a) {
    final first = a.conveyances.where((c) =>
        (c.message.title != null && c.message.title!.isNotEmpty) ||
        (c.message.body != null && c.message.body!.isNotEmpty)).firstOrNull;
    if (first == null) return const SizedBox.shrink();
    final title = first.message.title?.trim();
    final body = first.message.body?.trim();
    final hasTitle = title != null && title.isNotEmpty;
    final hasBody = body != null && body.isNotEmpty;
    if (!hasTitle && !hasBody) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasTitle)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          if (hasBody)
            SelectableText(
              body,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Alarmdetails',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    if (_hasConveyanceMessage(alarm)) ...[
                      _prominentMessageBlock(alarm),
                      const SizedBox(height: 20),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _defaultAlarmSummary(alarm, speciesCommonNames),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                    _sectionTitle('Alarm'),
                    if (_speciesName(alarm) != null)
                      _detailRow('Diersoort', _speciesName(alarm)!),
                    _detailRow('Eventsoort', _eventTypeLabel(alarm)),
                    _detailRow('Tijdstip', _formatTimestampFull(alarm.timestamp)),
                    _detailRow('Zone', alarm.zone.name ?? '—'),
                    if (_speciesName(alarm) != null &&
                        alarm.animal!.locationTimestamp != null)
                      _detailRow(
                        'Locatie bijgewerkt',
                        _formatTimestampFull(alarm.animal!.locationTimestamp!),
                      ),
                    if (alarm.conveyances.isNotEmpty &&
                        !_hasConveyanceMessage(alarm)) ...[
                      const SizedBox(height: 12),
                      _sectionTitle('Berichten'),
                      ...alarm.conveyances.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (c.message.title != null &&
                                c.message.title!.isNotEmpty)
                              _detailRow('Titel', c.message.title!),
                            if (c.message.body != null &&
                                c.message.body!.isNotEmpty)
                              _detailRow('Bericht', c.message.body!),
                            _detailRow('Tijdstip', _formatTimestampFull(c.timestamp)),
                            if (c.user?.displayName != null &&
                                c.user!.displayName!.isNotEmpty)
                              _detailRow('Gebruiker', c.user!.displayName!),
                          ],
                        ),
                      )),
                    ],
                    if (_hasConveyanceMessage(alarm)) ...[
                      const SizedBox(height: 12),
                      _sectionTitle('Overige berichten'),
                      ...alarm.conveyances
                          .where((c) =>
                              (c.message.title != null &&
                                  c.message.title!.isNotEmpty) ||
                              (c.message.body != null &&
                                  c.message.body!.isNotEmpty))
                          .skip(1)
                          .map((c) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (c.message.title != null &&
                                        c.message.title!.isNotEmpty)
                                      _detailRow('Titel', c.message.title!),
                                    if (c.message.body != null &&
                                        c.message.body!.isNotEmpty)
                                      _detailRow('Bericht', c.message.body!),
                                    _detailRow(
                                        'Tijdstip', _formatTimestampFull(c.timestamp)),
                                    if (c.user?.displayName != null &&
                                        c.user!.displayName!.isNotEmpty)
                                      _detailRow(
                                          'Gebruiker', c.user!.displayName!),
                                  ],
                                ),
                              )),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGreen,
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestampFull(String timestamp) {
    if (timestamp.isEmpty) return '—';
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return timestamp;
    }
  }
}
