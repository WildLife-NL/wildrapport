import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/screens/location/location_screen.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';

class TrafficAccidentDetailsScreen extends StatefulWidget {
  const TrafficAccidentDetailsScreen({super.key});

  @override
  State<TrafficAccidentDetailsScreen> createState() =>
      _TrafficAccidentDetailsScreenState();
}

class _TrafficAccidentDetailsScreenState
    extends State<TrafficAccidentDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _estimatedDamageController = TextEditingController();

  String? _selectedIntensity;
  String? _selectedUrgency;

  final List<String> _intensityOptions = ['high', 'medium', 'low'];
  final List<String> _urgencyOptions = ['high', 'medium', 'low'];

  @override
  void dispose() {
    _estimatedDamageController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      final appStateProvider = context.read<AppStateProvider>();
      final navigationManager = context.read<NavigationStateInterface>();

      // Store the traffic accident details
      final trafficAccidentData = {
        'estimatedDamage': double.tryParse(_estimatedDamageController.text) ?? 0.0,
        'intensity': _selectedIntensity,
        'urgency': _selectedUrgency,
      };

      debugPrint('[TrafficAccidentDetails] Saving data: $trafficAccidentData');

      // Store in app state (you may need to add a method to AppStateProvider)
      // For now, we'll navigate forward and the data will be collected when creating the interaction
      appStateProvider.setTrafficAccidentDetails(
        estimatedDamage: double.tryParse(_estimatedDamageController.text) ?? 0.0,
        intensity: _selectedIntensity ?? 'medium',
        urgency: _selectedUrgency ?? 'medium',
      );

      // Navigate to location screen
      navigationManager.pushForward(context, const LocationScreen());
    }
  }

  void _handleBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double horizontalPadding = screenSize.width * 0.05;
    final double verticalPadding = screenSize.height * 0.02;

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Verkeersongeval Details',
              rightIcon: Icons.menu,
              onLeftIconPressed: _handleBack,
              onRightIconPressed: () {},
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vul de details van het verkeersongeval in',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.03),

                      // Estimated Damage
                      const Text(
                        'Geschatte schade (€)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _estimatedDamageController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Bijv. 500.00',
                          prefixText: '€ ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Voer een geschatte schade in';
                          }
                          final damage = double.tryParse(value);
                          if (damage == null || damage < 0) {
                            return 'Voer een geldig bedrag in';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenSize.height * 0.03),

                      // Intensity
                      const Text(
                        'Intensiteit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedIntensity,
                        decoration: InputDecoration(
                          hintText: 'Selecteer intensiteit',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        items: _intensityOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(_getIntensityLabel(value)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedIntensity = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Selecteer een intensiteit';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenSize.height * 0.03),

                      // Urgency
                      const Text(
                        'Urgentie',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedUrgency,
                        decoration: InputDecoration(
                          hintText: 'Selecteer urgentie',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        items: _urgencyOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(_getUrgencyLabel(value)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedUrgency = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Selecteer een urgentie';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenSize.height * 0.03),

                      // Info text
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'In de volgende stap kunt u de betrokken dieren en locatie specificeren.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.04),

                      // Continue button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _handleContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Volgende',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getIntensityLabel(String value) {
    switch (value) {
      case 'high':
        return 'Hoog';
      case 'medium':
        return 'Gemiddeld';
      case 'low':
        return 'Laag';
      default:
        return value;
    }
  }

  String _getUrgencyLabel(String value) {
    switch (value) {
      case 'high':
        return 'Hoog';
      case 'medium':
        return 'Gemiddeld';
      case 'low':
        return 'Laag';
      default:
        return value;
    }
  }
}
