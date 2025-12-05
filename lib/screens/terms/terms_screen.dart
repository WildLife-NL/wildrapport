import 'package:wildrapport/widgets/shared_ui_widgets/white_bulk_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:wildrapport/interfaces/data_apis/profile_api_interface.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/screens/shared/overzicht_screen.dart';
import 'package:wildrapport/utils/responsive_utils.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _checked = false;
  bool _submitting = false;

  Future<void> _onAcceptPressed() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final profileApi = context.read<ProfileApiInterface>();

      // 1) Persist acceptance on the server
      await profileApi.updateReportAppTerms(true);

      // 2) (Optional) Pull fresh profile to update local cache
      // If your API already caches in updateReportAppTerms, you can skip this.
      await profileApi.setProfileDataInDeviceStorage();

      if (!mounted) return;

      // 3) Navigate to the home screen (no local flags involved)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OverzichtScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kon voorwaarden niet accepteren: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Scaffold(
      backgroundColor: AppColors.lightMintGreen,
      appBar: AppBar(
        title: Text(
          'Algemene Voorwaarden',
          style: TextStyle(fontSize: responsive.fontSize(18)),
        ),
        backgroundColor: AppColors.lightMintGreen,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(responsive.spacing(16)),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    'Algemene Voorwaarden\n\n'
                    'Deze app wordt geleverd door WildlifeNL om wildlifemelding te vergemakkelijken. Door gebruik te maken van deze app, gaat u ermee akkoord dat u zich houdt aan alle toepasselijke wet- en regelgeving met betrekking tot de bescherming van wilde dieren en gegevensprivacy. U erkent dat alle gegevens die u via deze app indient, door WildlifeNL kunnen worden gebruikt voor onderzoeksdoeleinden.',
                    style: TextStyle(
                      fontSize: responsive.fontSize(16),
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Transform.scale(
                    scale: responsive.sp(0.15),
                    child: Checkbox(
                      value: _checked,
                      activeColor: AppColors.darkGreen,
                      onChanged:
                          _submitting
                              ? null
                              : (v) => setState(() => _checked = v ?? false),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Ik heb de Algemene Voorwaarden gelezen en accepteer deze',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: responsive.fontSize(14),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.spacing(8)),
              SizedBox(
                width: double.infinity,
                child: WhiteBulkButton(
                  text: 'Accepteren & Doorgaan',
                  showIcon: false,
                  backgroundColor: AppColors.lightMintGreen100,
                  borderColor: AppColors.brown,
                  textStyle: TextStyle(
                    fontFamily: 'Roboto',
                    color: Colors.black,
                    fontSize: responsive.fontSize(16),
                    fontWeight: FontWeight.w600,
                  ),
                  onPressed:
                      (_checked && !_submitting) ? _onAcceptPressed : null,
                  showShadow: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
