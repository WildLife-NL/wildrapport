import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/data_managers/alarms_api.dart';
import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/interfaces/data_apis/species_api_interface.dart';
import 'package:wildrapport/screens/zone/alarm_detail_screen.dart';
import 'package:wildrapport/utils/alarm_display_utils.dart';
import 'package:wildrapport/utils/api_datetime.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildlifenl_alarms_components/wildlifenl_alarms_components.dart';

import 'package:wildrapport/utils/responsive_utils.dart';

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
      final list = await api.getMyAlarms();
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

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Alarmen',
              rightIcon: null,
              showUserIcon: false,
              onLeftIconPressed: () {
                Navigator.of(context).pop();
              },
              iconColor: AppColors.textPrimary,
              textColor: AppColors.textPrimary,
              fontScale: responsive.breakpointValue<double>(
                small: 1.4,
                medium: 1.3,
                large: 1.2,
                extraLarge: 1.15,
              ),
              iconScale: 1.15,
              userIconScale: 1.15,
              useFixedText: true,
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
            const CircularProgressIndicator(color: AppColors.primaryGreen),
            const SizedBox(height: 16),
            const Text(
              'Alarmen ophalen…',
              style: TextStyle(color: Colors.black87),
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
                style: TextButton.styleFrom(foregroundColor: AppColors.primaryGreen),
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
              'Je hebt op dit moment geen alarmen voor je zones.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primaryGreen,
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AlarmDetailScreen(
          alarm: alarm,
          speciesCommonNames: _speciesCommonNames,
        ),
      ),
    );
  }
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
        : defaultAlarmSummary(alarm, speciesCommonNames);
    final timestamp = alarmEventTimestampRaw(alarm) ?? alarm.timestamp;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.borderDefault, width: 1),
      ),
      color: Colors.white,
      elevation: 0,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.2),
          child: const Icon(Icons.notifications_active, color: AppColors.primaryGreen),
        ),
        title: Text(
          zoneName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.textPrimary,
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
                style: TextStyle(fontSize: 13, color: AppColors.textLight),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _formatTimestamp(timestamp),
                style: TextStyle(fontSize: 12, color: AppColors.textLight),
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
    final dt = tryParseBackendTimestampToUtc(timestamp);
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt.toLocal());
    if (diff.inDays > 0) return '${diff.inDays} dag geleden';
    if (diff.inHours > 0) return '${diff.inHours} uur geleden';
    if (diff.inMinutes > 0) return '${diff.inMinutes} min geleden';
    return 'Zojuist';
  }
}
