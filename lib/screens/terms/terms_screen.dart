import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wildrapport/screens/login/login_screen.dart';
import 'package:wildrapport/screens/shared/overzicht_screen.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _checked = false;

  Future<void> _onAcceptPressed() async {
    // 1) Save the acceptance flag
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAcceptedTerms', true);

    // 2) Decide where to go next (login or home)
    final String? token = prefs.getString('bearer_token');

    if (!mounted) return;

    // 3) Replace Terms with the next screen (avoid black screen)
    if (token == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OverzichtScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    'Here are the Terms & Conditions...\n\n'
                    '1) ...\n2) ...\n3) ...',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _checked,
                    onChanged: (v) => setState(() => _checked = v ?? false),
                  ),
                  const Expanded(
                    child: Text('I have read and accept the Terms & Conditions'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _checked ? _onAcceptPressed : null,
                  child: const Text('Accept & Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
