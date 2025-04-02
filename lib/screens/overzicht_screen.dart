import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/widgets/brown_button.dart';
import 'package:wildrapport/widgets/white_bulk_button.dart';
import 'package:wildrapport/widgets/rapporteren.dart';

class OverzichtScreen extends StatefulWidget {
  const OverzichtScreen({super.key});

  @override
  State<OverzichtScreen> createState() => _OverzichtScreenState();
}

class _OverzichtScreenState extends State<OverzichtScreen> {
  String userName = "John Doe";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TopContainer(userName: userName),
          ActionButtons(
            onRapporterenPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Rapporteren(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class TopContainer extends StatelessWidget {
  final String userName;

  const TopContainer({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    double height = 285.0;
    double welcomeFontSize = 20.0;
    double usernameFontSize = 24.0;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(75),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.05,
              top: height * 0.15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welkom Bij Wild Rapport',
                  style: TextStyle(
                    color: AppColors.offWhite,
                    fontSize: welcomeFontSize,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.25),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.03),
                Text(
                  userName,
                  style: TextStyle(
                    color: AppColors.offWhite,
                    fontSize: usernameFontSize,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.25),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 15,
            right: 0,
            left: 0,
            child: Center(
              child: Image.asset(
                'assets/LogoWildlifeNL.png',
                width: MediaQuery.of(context).size.width * 0.7,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final VoidCallback onRapporterenPressed;

  const ActionButtons({super.key, required this.onRapporterenPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: MediaQuery.of(context).size.height * 0.02,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            WhiteBulkButton(
              text: 'RapportenKaart',
              leftWidget: CircleIconContainer(
                icon: Icons.map,
                iconColor: AppColors.brown,
                size: 48,
              ),
              rightWidget: Icon(Icons.arrow_forward_ios, color: Colors.black54),
            ),
            WhiteBulkButton(
              text: 'Rapporteren',
              leftWidget: CircleIconContainer(
                icon: Icons.edit_note,
                iconColor: AppColors.brown,
                size: 48,
              ),
              rightWidget: Icon(Icons.arrow_forward_ios, color: Colors.black54),
              onPressed: onRapporterenPressed,
            ),
            WhiteBulkButton(
              text: 'Mijn Rapporten',
              leftWidget: CircleIconContainer(
                icon: Icons.description,
                iconColor: AppColors.brown,
                size: 48,
              ),
              rightWidget: Icon(Icons.arrow_forward_ios, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

