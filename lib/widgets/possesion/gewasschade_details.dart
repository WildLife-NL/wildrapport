import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/possesion_interface.dart';
import 'package:wildrapport/providers/possesion_damage_report_provider.dart';
import 'package:wildrapport/widgets/possesion/possesion_dropdown.dart';

class GewasschadeDetails extends StatefulWidget {
  const GewasschadeDetails({super.key});

  @override
  State<GewasschadeDetails> createState() => _GewasschadeDetailsState();
}

class _GewasschadeDetailsState extends State<GewasschadeDetails> {
  final TextEditingController _responseController = TextEditingController();
  late final PossesionInterface _possesionManager;
  String? _inputError;
  final greenLog = '\x1B[32m';
  final redLog = '\x1B[31m';
  final yellowLog = '\x1B[93m';

  @override
  void initState() {
    super.initState();
    _possesionManager = context.read<PossesionInterface>();

    // Initialize the controller with the value from the provider
    _responseController.text = formatImpactAreaString();  }

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String formatImpactAreaString(){
    final formProvider = Provider.of<PossesionDamageFormProvider>(context, listen: false);
    debugPrint(formProvider.impactedAreaType);
    try{
      if(formProvider.impactedAreaType.isNotEmpty && formProvider.impactedAreaType == "hectare"){
        debugPrint("FIRST");
        return formProvider.impactedArea?.toString() ?? '';
      }
      else{
        debugPrint("SECOND");
        return formProvider.impactedArea?.toInt().toString() ?? '';
      }
    }catch(e, stackTrace){
      debugPrint("Message: ${e.toString()}");
      debugPrint("stackTrace: $stackTrace");
      rethrow;
    }
  }

void convertImpactArea(String value) {
  debugPrint("convertImpactArea: value = $value");
  final formProvider = Provider.of<PossesionDamageFormProvider>(context, listen: false);

  if (formProvider.impactedAreaType.isNotEmpty &&
      formProvider.impactedArea != null &&
      formProvider.impactedAreaType != value) {
    switch (value) {
      case "vierkante meters":
        formProvider.setImpactedArea(formProvider.impactedArea! * 10000);
        break;
      case "hectare":
        formProvider.setImpactedArea(formProvider.impactedArea! / 10000);
        break;
    }

    final impacted = formProvider.impactedArea!;
    // ✅ Check if the number is whole (e.g., ends with .0)
    if (impacted == impacted.roundToDouble()) {
      _responseController.text = impacted.round().toString();
    } else {
      _responseController.text = impacted.toString();
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final euroFormat = NumberFormat.currency(locale: 'nl_NL', symbol: '€', decimalDigits: 0);
    final formProvider = Provider.of<PossesionDamageFormProvider>(context);


    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        debugPrint("$greenLog [GewasschadeDetails]: Line 47");
        formProvider.updateExpanded(true);
        FocusScope.of(context).unfocus();
      }, 
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PossesionDropdown(
            onChanged: (value) { 
              _possesionManager.updateImpactedCrop(value); 
              formProvider.setErrorState("impactedCrop", false);
              },
            getSelectedValue: formProvider.impactedCrop,
            getSelectedText: capitalize(formProvider.impactedCrop),
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
            hasError: formProvider.hasErrorImpactedCrop,
            useIcons: true,
          ),
          const SizedBox(height: 10),

          PossesionDropdown(
            onChanged: (value) {
              // Update the impacted area type
              switch(value){
                case "vierkante meters":
                  formProvider.updateSelectedText("m2");
                case "hectare":
                  formProvider.updateSelectedText("ha");
                default:
                  formProvider.updateSelectedText("Type");
              }
              convertImpactArea(value);
              _possesionManager.updateImpactedAreaType(value);
              formProvider.setErrorState("impactedAreaType", false);

              // If impactedArea is not null or empty, validate the input
              if (_responseController.text.isNotEmpty) {
                final areaType = value;
                String cleanedValue = _responseController.text.replaceAll(',', '.');

                bool isValid = false;
                double? parsed;

                if (areaType == "vierkante meters") {
                  // Only allow full integers
                  final intRegex = RegExp(r'^\d+$');
                  if (intRegex.hasMatch(_responseController.text)) {
                    parsed = double.tryParse(_responseController.text);
                    isValid = parsed != null;
                  }
                } else if (areaType == "hectare") {
                  // Allow decimals with comma or dot
                  final decimalRegex = RegExp(r'^\d+([.,]\d+)?$');
                  if (decimalRegex.hasMatch(cleanedValue)) {
                    parsed = double.tryParse(cleanedValue);
                    isValid = parsed != null;
                  }
                }
                debugPrint("$isValid");
                if (isValid) {
                  setState(() {
                    _inputError = null;
                  });
                  debugPrint("$yellowLog is valid = $isValid");
                  debugPrint("$yellowLog parsed = $parsed");

                  _possesionManager.updateImpactedArea(parsed!);
                  formProvider.setHasErrorImpactedArea(false); // Clear error in provider
                  formProvider.resetInputErrorImpactArea();
                  
                  debugPrint("$yellowLog ErrorImpactedArea = ${formProvider.hasErrorImpactedArea}");
                } else {
                  setState(() {
                    formProvider.updateInputErrorImpactArea(areaType == "vierkante meters"
                        ? "Alleen gehele getallen toegestaan"
                        : "Gebruik een geldig getal (bv. 1,5 of 1.5)");
                  });
                  formProvider.setHasErrorImpactedArea(true); // Set error in provider
                }
              }
            },
            getSelectedValue: formProvider.impactedAreaType,
            getSelectedText: formProvider.selectedText ?? "Type",
            dropdownItems: [
              {'text': 'ha', 'value': 'hectare'},
              {'text': 'm2', 'value': 'vierkante meters'},
            ],
            startingValue: "vierkante meters",
            defaultValue: "Type",
            hasDropdownSideDescription: true,
            dropdownSideDescriptionText: "Getroffen Gebied",
            hasError: formProvider.hasErrorImpactedAreaType,
            useIcons: false,
          ),
          
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _responseController,
                    onChanged: (value) {
                      debugPrint(value);
                      final areaType = formProvider.impactedAreaType;
                      String cleanedValue = value.replaceAll(',', '.');

                      bool isValid = false;
                      double? parsed;

                      if (areaType == "vierkante meters") {
                        // Only allow full integers
                        final intRegex = RegExp(r'^\d+$');
                        if (intRegex.hasMatch(value)) {
                          parsed = double.tryParse(value);
                          isValid = parsed != null;
                        }
                      } else if (areaType == "hectare") {
                        // Allow decimals with comma or dot
                        final decimalRegex = RegExp(r'^\d+([.,]\d+)?$');
                        if (decimalRegex.hasMatch(cleanedValue)) {
                          parsed = double.tryParse(cleanedValue);
                          isValid = parsed != null;
                        }
                      }

                      if (isValid) {
                        setState(() {
                          formProvider.resetInputErrorImpactArea(); // Clear the error if the input is valid
                        });
                        _possesionManager.updateImpactedArea(parsed!);
                        formProvider.setHasErrorImpactedArea(false); // Clear error in provider
                      } else {
                        // Only show 'This field is required' when input is empty
                        setState(() {
                          if (value.isNotEmpty && areaType != "vierkante meters" && areaType != "hectare"){
                            debugPrint("$greenLog [GewasschadeDetails]: Line 198");
                            formProvider.updateInputErrorImpactArea("Vul Getroffen Gebied in");
                          }
                          else if (value.isEmpty) {
                            debugPrint("$greenLog [GewasschadeDetails]: Line 197, value = $value");
                            formProvider.resetImpactedArea();
                            formProvider.updateInputErrorImpactArea("This field is required"); // Show error if the input is empty
                          } else {
                            formProvider.updateInputErrorImpactArea(areaType == "vierkante meters"
                                ? "Alleen gehele getallen toegestaan"
                                : "Gebruik een geldig getal (bv. 1,5 of 1.5)");
                          }
                        });
                        formProvider.setHasErrorImpactedArea(true); // Set error in provider
                      }
                    },
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'hoe groot',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: (formProvider.inputErrorImpactArea != null || formProvider.hasErrorImpactedArea)
                            ? const BorderSide(color: Colors.red, width: 2.0)
                            : BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: (formProvider.inputErrorImpactArea != null || formProvider.hasErrorImpactedArea)
                            ? const BorderSide(color: Colors.red, width: 2.0)
                            : BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: (formProvider.inputErrorImpactArea != null || formProvider.hasErrorImpactedArea)
                            ? const BorderSide(color: Colors.red, width: 2.0)
                            : BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.brown,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                formProvider.hasErrorImpactedArea
                  ? Text(
                      formProvider.inputErrorImpactArea ?? 'This field is required',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    )
                  : const SizedBox.shrink(), // invisible when no error
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Geschatte huidige schade: ${euroFormat.format(formProvider.currentDamage)}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Slider(
                value: formProvider.currentDamage,
                onChanged: (value) => _possesionManager.updateCurrentDamage(value),
                min: 0,
                max: 10000,
                divisions: 1000, // so each step is €10
                label: formProvider.currentDamage.round().toString(),
                activeColor: AppColors.brown,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Verwachte toekomstige schade: ${euroFormat.format(formProvider.expectedDamage)}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Slider(
                value: formProvider.expectedDamage,
                onChanged: (value) => _possesionManager.updateExpectedDamage(value),
                min: 0,
                max: 10000,
                divisions: 1000, // so each step is €10
                label: formProvider.expectedDamage.round().toString(),
                activeColor: AppColors.brown,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: TextField(
                onChanged: (val) => _possesionManager.updateDescription(val),
                maxLines: 5,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'opmerkingen...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                style: const TextStyle(fontSize: 18, color: AppColors.brown),
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