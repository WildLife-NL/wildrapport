import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/widgets/overzicht/top_container.dart';
import 'package:wildrapport/widgets/overzicht/action_buttons.dart';
import 'package:wildrapport/screens/rapporteren.dart';

class OverzichtScreen extends StatefulWidget {
  const OverzichtScreen({super.key});

  @override
  State<OverzichtScreen> createState() => _OverzichtScreenState();
}

class _OverzichtScreenState extends State<OverzichtScreen> {
  String userName = "Joe Doe";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("userName") ?? "Joe Doe";
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigationManager = context.read<NavigationStateInterface>();
    final screenSize = MediaQuery.of(context).size;

    final double topContainerHeight = (screenSize.height * 0.4).clamp(180.0, 300.0);
    final double welcomeFontSize = (screenSize.width * 0.045).clamp(14.0, 24.0);
    final double usernameFontSize = (screenSize.width * 0.06).clamp(18.0, 28.0);
    final double buttonHeight = (screenSize.height * 0.18).clamp(100.0, 160.0);
    final double buttonWidth = (screenSize.width * 0.8).clamp(250.0, 400.0);
    final double spacing = (screenSize.height * 0.02).clamp(8.0, 24.0);
    final double iconSize = (screenSize.width * 0.14).clamp(28.0, 56.0);
    final double buttonFontSize = (screenSize.width * 0.045).clamp(14.0, 22.0);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TopContainer(
                    userName: userName,
                    height: topContainerHeight,
                    welcomeFontSize: welcomeFontSize,
                    usernameFontSize: usernameFontSize,
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: spacing / 2,
                        horizontal: spacing,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            SizedBox(height: spacing),
                            ActionButtons(
                              buttons: [
                                (
                                  text: 'RapportenKaart',
                                  icon: Icons.map,
                                  imagePath: null,
                                  onPressed: () {},
                                ),
                                (
                                  text: 'Rapporteren',
                                  icon: Icons.edit_note,
                                  imagePath: null,
                                  onPressed: () {
                                    navigationManager.pushReplacementForward(
                                      context,
                                      const Rapporteren(),
                                    );
                                  },
                                ),
                                (
                                  text: 'Mijn Rapporten',
                                  icon: Icons.description,
                                  imagePath: null,
                                  onPressed: () {},
                                ),
                              ],
                              iconSize: iconSize,
                              verticalPadding: spacing / 2,
                              horizontalPadding: spacing,
                              buttonSpacing: spacing / 2,
                              buttonHeight: buttonHeight,
                              buttonFontSize: buttonFontSize,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}