import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/services/alarm_map_focus_service.dart';
import 'package:wildrapport/utils/alarm_display_utils.dart';
import 'package:wildrapport/utils/alarm_event_mapper.dart';
import 'package:wildrapport/utils/responsive_utils.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildlifenl_alarms_components/wildlifenl_alarms_components.dart';

class AlarmDetailScreen extends StatefulWidget {
  const AlarmDetailScreen({
    super.key,
    required this.alarm,
    required this.speciesCommonNames,
  });

  final Alarm alarm;
  final Map<String, String> speciesCommonNames;

  @override
  State<AlarmDetailScreen> createState() => _AlarmDetailScreenState();
}

class _AlarmDetailScreenState extends State<AlarmDetailScreen> {
  bool _showOnMapChecked = false;

  Alarm get alarm => widget.alarm;

  bool get _canShowOnMap => mapAlarmFocusFromAlarm(alarm) != null;

  void _onShowOnMapChanged(bool? value) {
    if (value != true || !_canShowOnMap) return;
    final focus = mapAlarmFocusFromAlarm(alarm);
    if (focus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Locatie van deze melding kon niet worden bepaald.',
          ),
        ),
      );
      return;
    }
    setState(() => _showOnMapChecked = true);
    context.read<AlarmMapFocusService>().requestShowOnMap(focus);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final species = speciesDisplayName(alarm, widget.speciesCommonNames);
    final zoneName = alarm.zone.name?.trim();
    final messages = conveyancesWithText(alarm);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Alarm',
              rightIcon: null,
              showUserIcon: false,
              onLeftIconPressed: () => Navigator.of(context).pop(),
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _SectionCard(
                    icon: Icons.schedule_outlined,
                    title: 'Wanneer het gebeurde',
                    child: Text(
                      formatAlarmEventTime(alarm),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    icon: Icons.pets_outlined,
                    title: 'Diersoort en zone',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoLine(
                          label: 'Diersoort',
                          value: species ?? 'Onbekend',
                        ),
                        const SizedBox(height: 10),
                        _InfoLine(
                          label: 'Zone',
                          value: (zoneName != null && zoneName.isNotEmpty)
                              ? zoneName
                              : '—',
                        ),
                        const SizedBox(height: 10),
                        _InfoLine(
                          label: 'Soort melding',
                          value: eventTypeLabel(alarm),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    icon: Icons.message_outlined,
                    title: 'Berichten van onderzoekers',
                    child: messages.isEmpty
                        ? Text(
                            defaultAlarmSummary(
                              alarm,
                              widget.speciesCommonNames,
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: Colors.grey.shade700,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < messages.length; i++) ...[
                                if (i > 0) const SizedBox(height: 12),
                                _ResearcherMessageCard(
                                  conveyance: messages[i],
                                ),
                              ],
                            ],
                          ),
                  ),
                  const SizedBox(height: 20),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: CheckboxListTile(
                      value: _showOnMapChecked,
                      onChanged: _canShowOnMap ? _onShowOnMapChanged : null,
                      activeColor: AppColors.primaryGreen,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text(
                        'Toon op de kaart',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        _canShowOnMap
                            ? 'Bekijk de ${alarm.detection != null ? 'detectie' : 'interactie'} die dit alarm heeft veroorzaakt'
                            : 'Geen kaartlocatie beschikbaar voor dit alarm',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.borderDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResearcherMessageCard extends StatelessWidget {
  const _ResearcherMessageCard({required this.conveyance});

  final AlarmConveyance conveyance;

  @override
  Widget build(BuildContext context) {
    final title = conveyance.message.title?.trim();
    final body = conveyance.message.body?.trim();
    final researcher = conveyance.user?.displayName?.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title.isNotEmpty)
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          if (body != null && body.isNotEmpty) ...[
            if (title != null && title.isNotEmpty) const SizedBox(height: 6),
            SelectableText(
              body,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            [
              if (researcher != null && researcher.isNotEmpty) researcher,
              formatAlarmTimestamp(conveyance.timestamp),
            ].where((s) => s.isNotEmpty).join(' · '),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
