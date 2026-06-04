import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/sighting_report_activities.dart';
import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/screens/waarneming/animal_waarneming_summary_screen.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';

class AnimalActivityScreen extends StatefulWidget {
  final int totalCount;

  const AnimalActivityScreen({
    super.key,
    required this.totalCount,
  });

  @override
  State<AnimalActivityScreen> createState() => _AnimalActivityScreenState();
}

class _AnimalActivityScreenState extends State<AnimalActivityScreen> {
  final _humanActivityOtherController = TextEditingController();
  final _perceivedAnimalActivityOtherController = TextEditingController();
  final _humanOtherFocusNode = FocusNode();
  final _perceivedOtherFocusNode = FocusNode();

  String _humanActivity = SightingReportActivityCatalog.defaultHumanActivity;
  String _perceivedAnimalActivity =
      SightingReportActivityCatalog.defaultPerceivedAnimalActivity;

  late final Future<void> _catalogReady;

  @override
  void initState() {
    super.initState();

    final sighting =
        context.read<AnimalSightingReportingInterface>().getCurrentanimalSighting();

    _humanActivity =
        sighting?.humanActivity ?? SightingReportActivityCatalog.defaultHumanActivity;
    _perceivedAnimalActivity = sighting?.perceivedAnimalActivity ??
        SightingReportActivityCatalog.defaultPerceivedAnimalActivity;

    _humanActivityOtherController.text = sighting?.humanActivityOther?.trim() ?? '';
    _perceivedAnimalActivityOtherController.text =
        sighting?.perceivedAnimalActivityOther?.trim() ?? '';

    _catalogReady = SightingReportActivityCatalog.ensureLoaded(
      context.read<ApiClient>(),
    );
  }

  @override
  void dispose() {
    _humanActivityOtherController.dispose();
    _perceivedAnimalActivityOtherController.dispose();
    _humanOtherFocusNode.dispose();
    _perceivedOtherFocusNode.dispose();
    super.dispose();
  }

  bool _validateOtherFields() {
    if (SightingReportActivityCatalog.isOtherHuman(_humanActivity) &&
        _humanActivityOtherController.text.trim().isEmpty) {
      _showValidationMessage('Vul in wat je deed bij "Anders, namelijk".');
      _humanOtherFocusNode.requestFocus();
      return false;
    }
    if (SightingReportActivityCatalog.isOtherPerceivedAnimal(
          _perceivedAnimalActivity,
        ) &&
        _perceivedAnimalActivityOtherController.text.trim().isEmpty) {
      _showValidationMessage('Vul in wat het dier deed bij "Anders, namelijk".');
      _perceivedOtherFocusNode.requestFocus();
      return false;
    }
    return true;
  }

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleNext() {
    if (!_validateOtherFields()) return;

    final sightingManager = context.read<AnimalSightingReportingInterface>();
    final sighting = sightingManager.getCurrentanimalSighting();

    if (sighting != null) {
      final updatedSighting = sighting.copyWith(
        humanActivity: _humanActivity,
        humanActivityOther: SightingReportActivityCatalog.isOtherHuman(_humanActivity)
            ? _humanActivityOtherController.text.trim()
            : null,
        perceivedAnimalActivity: _perceivedAnimalActivity,
        perceivedAnimalActivityOther:
            SightingReportActivityCatalog.isOtherPerceivedAnimal(
              _perceivedAnimalActivity,
            )
                ? _perceivedAnimalActivityOtherController.text.trim()
                : null,
      );

      sightingManager.updateCurrentanimalSighting(updatedSighting);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimalWaarnemingSummaryScreen(
          totalCount: widget.totalCount,
        ),
      ),
    );
  }

  void _handleBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F4),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomAppBar(
              centerText: 'Waarneming',
              rightIcon: null,
              showUserIcon: false,
              useFixedText: true,
              onLeftIconPressed: _handleBack,
              textColor: AppColors.textPrimary,
              iconColor: AppColors.textPrimary,
              fontScale: 1.4,
              iconScale: 1.15,
              userIconScale: 1.15,
            ),
            Expanded(
              child: FutureBuilder<void>(
                future: _catalogReady,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    );
                  }
                  return _buildScrollableContent();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const SizedBox.shrink(),
    );
  }

  Widget _buildScrollableContent() {
    final catalog = SightingReportActivityCatalog.instance;
    final showHumanOther =
        SightingReportActivityCatalog.isOtherHuman(_humanActivity);
    final showPerceivedOther =
        SightingReportActivityCatalog.isOtherPerceivedAnimal(_perceivedAnimalActivity);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(16, 2, 16, 16 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(
                color: Color(0xFF999999),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Activiteit',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _activityDropdown(
                    label: 'Wat deed je toen je het dier zag?',
                    value: _humanActivity,
                    options: catalog.humanActivities,
                    onChanged: (v) {
                      setState(() => _humanActivity = v);
                    },
                  ),
                  if (showHumanOther) ...[
                    const SizedBox(height: 10),
                    _otherTextField(
                      controller: _humanActivityOtherController,
                      focusNode: _humanOtherFocusNode,
                      hint: 'Beschrijf jouw activiteit',
                    ),
                  ],
                  const SizedBox(height: 16),
                  _activityDropdown(
                    label: 'Wat deed het dier?',
                    value: _perceivedAnimalActivity,
                    options: catalog.perceivedAnimalActivities,
                    onChanged: (v) {
                      setState(() => _perceivedAnimalActivity = v);
                    },
                  ),
                  if (showPerceivedOther) ...[
                    const SizedBox(height: 10),
                    _otherTextField(
                      controller: _perceivedAnimalActivityOtherController,
                      focusNode: _perceivedOtherFocusNode,
                      hint: 'Beschrijf de activiteit van het dier',
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _navigationButtons(),
        ],
      ),
    );
  }

  Widget _navigationButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _handleBack,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(
                color: Color(0xFF999999),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
            ),
            child: const Text(
              'Vorige',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed:
                SightingReportActivityCatalog.isLoaded ? _handleNext : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: const Color(0xFF37A904),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Volgende',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _otherTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
  }) {
    return Builder(
      builder: (fieldContext) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          scrollPadding: const EdgeInsets.only(bottom: 220),
          onTap: () {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (!fieldContext.mounted) return;
              Scrollable.ensureVisible(
                fieldContext,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                alignment: 0.25,
              );
            });
          },
          decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFF999999),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFF37A904),
            width: 2,
          ),
        ),
      ),
        );
      },
    );
  }

  Widget _activityDropdown({
    required String label,
    required String value,
    required List<SightingReportActivityOption> options,
    required ValueChanged<String> onChanged,
  }) {
    final resolvedValue = options.any((o) => o.apiValue == value)
        ? value
        : options.last.apiValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: resolvedValue,
          menuMaxHeight: 400,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          borderRadius: BorderRadius.circular(16),
          dropdownColor: AppColors.cardBackground,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xFF999999),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xFF37A904),
                width: 2,
              ),
            ),
          ),
          items: options
              .map(
                (o) => DropdownMenuItem(
                  value: o.apiValue,
                  child: Text(
                    o.labelNl,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}
