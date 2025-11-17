import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/reporting/belonging_damage_report_interface.dart';
import 'package:wildrapport/providers/belonging_damage_report_provider.dart';
import 'package:wildrapport/widgets/belonging/belonging_dropdown.dart';
import 'package:flutter/services.dart';


class BelongingCropsDetails extends StatefulWidget {
  const BelongingCropsDetails({super.key});

  @override
  State<BelongingCropsDetails> createState() => _BelongingCropsDetailsState();
}

class _BelongingCropsDetailsState extends State<BelongingCropsDetails> {
  late final TextEditingController _impactValueController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _currentDamageController;
  late final TextEditingController _expectedDamageController;
  late final BelongingDamageReportInterface _belongingDamageReportManager;
  final greenLog = '\x1B[32m';
  final redLog = '\x1B[31m';
  final yellowLog = '\x1B[93m';

  @override
  void initState() {
    super.initState();
    _belongingDamageReportManager =
        context.read<BelongingDamageReportInterface>();

    final belongingDamageReportProvider =
      Provider.of<BelongingDamageReportProvider>(context, listen: false);

      // STEP A: Legacy normalization — if old state stored 'hectare', convert to m²
if (belongingDamageReportProvider.impactedAreaType == 'hectare' &&
    belongingDamageReportProvider.impactedArea != null) {
  final ha = belongingDamageReportProvider.impactedArea!;
  belongingDamageReportProvider.setImpactedAreaType('vierkante meters');
  belongingDamageReportProvider.updateSelectedText('m2');
  belongingDamageReportProvider.setImpactedArea(ha * 10000); // ha -> m²
}

    
    // Initialize controllers with proper text values
    final impactAreaString = formatImpactAreaString();
    final initialImpact = (impactAreaString.isNotEmpty && impactAreaString != "0" && impactAreaString != "0.0") 
        ? impactAreaString 
        : '';
    _impactValueController = TextEditingController(text: initialImpact);
    
    final initialDescription = belongingDamageReportProvider.description.isNotEmpty 
        ? belongingDamageReportProvider.description 
        : '';
    _descriptionController = TextEditingController(text: initialDescription);
    
    final initialCurrentDamage = belongingDamageReportProvider.currentDamage > 0 
        ? belongingDamageReportProvider.currentDamage.round().toString() 
        : '';
    _currentDamageController = TextEditingController(text: initialCurrentDamage);
    
    final initialExpectedDamage = belongingDamageReportProvider.expectedDamage > 0 
        ? belongingDamageReportProvider.expectedDamage.round().toString() 
        : '';
    _expectedDamageController = TextEditingController(text: initialExpectedDamage);
  }
  
  @override
  void dispose() {
    _impactValueController.dispose();
    _descriptionController.dispose();
    _currentDamageController.dispose();
    _expectedDamageController.dispose();
    super.dispose();
  }

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String formatImpactAreaString() {
    final belongingDamageReportProvider =
        Provider.of<BelongingDamageReportProvider>(context, listen: false);
    debugPrint(belongingDamageReportProvider.impactedAreaType);
    try {
      if (belongingDamageReportProvider.impactedAreaType.isNotEmpty &&
          belongingDamageReportProvider.impactedAreaType == "hectare") {
        debugPrint("FIRST");
        return belongingDamageReportProvider.impactedArea?.toString() ?? '';
      } else {
        debugPrint("SECOND");
        return belongingDamageReportProvider.impactedArea?.toInt().toString() ??
            '';
      }
    } catch (e, stackTrace) {
      debugPrint("Message: ${e.toString()}");
      debugPrint("stackTrace: $stackTrace");
      rethrow;
    }
  }

  void convertImpactArea(String value) {
    debugPrint("convertImpactArea: value = $value");
    final belongingDamageReportProvider =
        Provider.of<BelongingDamageReportProvider>(context, listen: false);

    if (belongingDamageReportProvider.impactedAreaType.isNotEmpty &&
        belongingDamageReportProvider.impactedArea != null &&
        belongingDamageReportProvider.impactedAreaType != value) {
      switch (value) {
        case "vierkante meters":
          belongingDamageReportProvider.setImpactedArea(
            belongingDamageReportProvider.impactedArea! * 10000,
          );
          break;
        case "hectare":
          belongingDamageReportProvider.setImpactedArea(
            belongingDamageReportProvider.impactedArea! / 10000,
          );
          break;
      }

      final impacted = belongingDamageReportProvider.impactedArea!;
      if (impacted == impacted.roundToDouble()) {
        _impactValueController.text = impacted.round().toString();
      } else {
        _impactValueController.text = impacted.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final belongingDamageReportProvider =
        Provider.of<BelongingDamageReportProvider>(context);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        belongingDamageReportProvider.updateExpanded(true);
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BelongingDropdown(
                  key: const Key('impacted-crop'),
                  onChanged: (value) {
                    _belongingDamageReportManager.updateImpactedCrop(value);
                    belongingDamageReportProvider.setErrorState(
                      "impactedCrop",
                      false,
                    );
                  },
                  getSelectedValue: belongingDamageReportProvider.impactedCrop,
                  getSelectedText: capitalize(
                    belongingDamageReportProvider.impactedCrop,
                  ),
                  dropdownItems: [
                    {'text': 'Mais', 'value': 'mais'},
                    {'text': 'Bieten', 'value': 'bieten'},
                    {'text': 'Granen', 'value': 'granen'},
                    {'text': 'Bloementeelt', 'value': 'bloementeelt'},
                    {'text': 'Grasvelden', 'value': 'grasvelden'},
                    {'text': 'Boomteelt', 'value': 'boomteelt'},
                    {'text': 'Tuinbouw', 'value': 'tuinbouw'},
                  ],
                  containerHeight: 50,
                  containerWidth: 400,
                  startingValue: "mais",
                  defaultValue: "Kies Gewas",
                  hasDropdownSideDescription: false,
                  hasError: belongingDamageReportProvider.hasErrorImpactedCrop,
                  useIcons: true,
                ),
                const SizedBox(height: 10),

BelongingDropdown(
  key: const Key('impacted-area-type'),
  onChanged: (value) {
    // value is either 'vierkante meters' or 'units'
    belongingDamageReportProvider.updateSelectedText(
      value == 'units' ? 'units' : 'm2',
    );

    _belongingDamageReportManager.updateImpactedAreaType(value);
    belongingDamageReportProvider.setErrorState('impactedAreaType', false);

    // Re-validate current input (both types are integers)
    final txt = _impactValueController.text;
    if (txt.isNotEmpty) {
      final intRegex = RegExp(r'^\d+$');
      final ok = intRegex.hasMatch(txt);
      if (ok) {
        _belongingDamageReportManager.updateImpactedArea(double.parse(txt));
        belongingDamageReportProvider.setHasErrorImpactedArea(false);
        belongingDamageReportProvider.resetInputErrorImpactArea();
      } else {
        belongingDamageReportProvider.setHasErrorImpactedArea(true);
        belongingDamageReportProvider
            .updateInputErrorImpactArea('Alleen gehele getallen toegestaan');
      }
      setState(() {});
    }
  },
  getSelectedValue: belongingDamageReportProvider.impactedAreaType,
  getSelectedText: belongingDamageReportProvider.selectedText ?? 'Type',
  dropdownItems: const [
    {'text': 'm²',    'value': 'vierkante meters'}, // store value = 'vierkante meters'
    {'text': 'units', 'value': 'units'},            // store value = 'units'
  ],
  containerHeight: 40,
  containerWidth: 150,
  startingValue: 'vierkante meters',
  defaultValue: 'Type',
  hasDropdownSideDescription: true,
  dropdownSideDescriptionText: 'Getroffen Gebied',
  hasError: belongingDamageReportProvider.hasErrorImpactedAreaType,
  useIcons: false,
)
,

                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: const BoxDecoration(),
                        child: TextField(
  key: const Key('area-value'),
  controller: _impactValueController,
  keyboardType: const TextInputType.numberWithOptions(decimal: false),
  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  decoration: InputDecoration(
    filled: true,
    fillColor: Colors.white,
    hintText: belongingDamageReportProvider.impactedAreaType == 'units'
        ? 'hoeveel (aantal)'
        : 'hoe groot (m²)',
    suffixText: belongingDamageReportProvider.impactedAreaType == 'units'
        ? 'units'
        : 'm²',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: (belongingDamageReportProvider.inputErrorImpactArea != null ||
              belongingDamageReportProvider.hasErrorImpactedArea)
          ? const BorderSide(color: Colors.red, width: 2.0)
          : const BorderSide(color: AppColors.darkGreen, width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: (belongingDamageReportProvider.inputErrorImpactArea != null ||
              belongingDamageReportProvider.hasErrorImpactedArea)
          ? const BorderSide(color: Colors.red, width: 2.0)
          : const BorderSide(color: AppColors.darkGreen, width: 2.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: (belongingDamageReportProvider.inputErrorImpactArea != null ||
              belongingDamageReportProvider.hasErrorImpactedArea)
          ? const BorderSide(color: Colors.red, width: 2.0)
          : const BorderSide(color: AppColors.darkGreen, width: 2.0),
    ),
  ),
  style: const TextStyle(
    fontSize: 18,
    color: AppColors.brown,
    fontFamily: 'Roboto',
  ),
  onChanged: (value) {
    if (value.isEmpty) {
      setState(() {
        belongingDamageReportProvider.resetImpactedArea();
        belongingDamageReportProvider
            .updateInputErrorImpactArea('This field is required');
        belongingDamageReportProvider.setHasErrorImpactedArea(true);
      });
      return;
    }

    final intRegex = RegExp(r'^\d+$');
    if (intRegex.hasMatch(value)) {
      final parsed = double.parse(value);
      _belongingDamageReportManager.updateImpactedArea(parsed);
      setState(() {
        belongingDamageReportProvider.resetInputErrorImpactArea();
        belongingDamageReportProvider.setHasErrorImpactedArea(false);
      });
    } else {
      setState(() {
        belongingDamageReportProvider.setHasErrorImpactedArea(true);
        belongingDamageReportProvider
            .updateInputErrorImpactArea('Alleen gehele getallen toegestaan');
      });
    }
  },
)


                      ),
                      const SizedBox(height: 5),
                      belongingDamageReportProvider.hasErrorImpactedArea
                          ? Text(
                            belongingDamageReportProvider
                                    .inputErrorImpactArea ??
                                'This field is required',
                            style: const TextStyle(color: Colors.red, fontSize: 12, fontFamily: 'Roboto'),
                          )
                          : const SizedBox.shrink(), // invisible when no error
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Geschatte huidige schade",
                        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto', fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: const BoxDecoration(),
                        child: TextField(
                          key: const Key('estimated-damage'),
                          controller: _currentDamageController,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              _belongingDamageReportManager.updateCurrentDamage(0);
                            } else {
                              final parsed = double.tryParse(value);
                              if (parsed != null) {
                                _belongingDamageReportManager.updateCurrentDamage(parsed);
                              }
                            }
                          },
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Bedrag in €',
                            prefixText: '€ ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                color: AppColors.darkGreen,
                                width: 2.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                color: AppColors.darkGreen,
                                width: 2.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                color: AppColors.darkGreen,
                                width: 2.0,
                              ),
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.brown,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Verwachte inkomstenderving",
                        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto', fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: const BoxDecoration(),
                        child: TextField(
                          key: const Key('estimated-future-damage'),
                          controller: _expectedDamageController,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              _belongingDamageReportManager.updateExpectedDamage(0);
                            } else {
                              final parsed = double.tryParse(value);
                              if (parsed != null) {
                                _belongingDamageReportManager.updateExpectedDamage(parsed);
                              }
                            }
                          },
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Bedrag in €',
                            prefixText: '€ ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                color: AppColors.darkGreen,
                                width: 2.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                color: AppColors.darkGreen,
                                width: 2.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                color: AppColors.darkGreen,
                                width: 2.0,
                              ),
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.brown,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    decoration: const BoxDecoration(),
                    child: TextField(
                      key: const Key('description'),
                      controller: _descriptionController,
                      onChanged:
                          (val) => _belongingDamageReportManager
                              .updateDescription(val),
                      maxLines: 5,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'opmerkingen...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: AppColors.darkGreen,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: AppColors.darkGreen,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: AppColors.darkGreen,
                            width: 2.0,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.brown,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
