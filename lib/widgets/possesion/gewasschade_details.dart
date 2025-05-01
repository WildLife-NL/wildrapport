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

  @override
  void initState() {
    super.initState();
    _possesionManager = context.read<PossesionInterface>();
    final formProvider = Provider.of<PossesionDamageFormProvider>(context, listen: false);

    // Initialize the controller with the value from the provider
    _responseController.text = formProvider.impactedArea?.toString() ?? '';
  }

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final euroFormat = NumberFormat.currency(locale: 'nl_NL', symbol: '€', decimalDigits: 0);
    final formProvider = Provider.of<PossesionDamageFormProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PossesionDropdown(
          onChanged: (value) => _possesionManager.updateImpactedCrop(value), 
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
          onChanged: (value) => _possesionManager.updateImpactedAreaType(value), 
          getSelectedValue: formProvider.impactedAreaType,
          getSelectedText: formProvider.impactedAreaType,
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
                    try {
                      final parsed = double.parse(value);
                      _possesionManager.updateImpactedArea(parsed);
                    } catch (e, stackTrace) {
                      debugPrint('Invalid input for double: $value');
                      debugPrint('$e\n$stackTrace');
                      // Optionally, notify formProvider of the error
                    }
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'hoe groot',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: formProvider.hasErrorImpactedArea
                          ? const BorderSide(color: Colors.red, width: 2.0)
                          : BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: formProvider.hasErrorImpactedArea
                          ? const BorderSide(color: Colors.red, width: 2.0)
                          : BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: formProvider.hasErrorImpactedArea
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
              SizedBox(
                height: 18,
                child: formProvider.hasErrorImpactedArea
                    ? const Text(
                        'This field is required',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      )
                    : const SizedBox.shrink(),
              ),
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
    );
  }
}
