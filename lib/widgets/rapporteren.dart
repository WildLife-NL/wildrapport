import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/screens/animals_screen.dart';
import 'package:wildrapport/widgets/app_bar.dart';

class Rapporteren extends StatefulWidget {
  const Rapporteren({super.key});

  @override
  State<Rapporteren> createState() => _RapporterenState();
}

class _RapporterenState extends State<Rapporteren> {
  String selectedCategory = '';

  void _handleReportTypeSelection(String reportType) {
    setState(() {
      selectedCategory = reportType;
    });
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimalsScreen(screenTitle: reportType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Rapporteren',
              rightIcon: Icons.menu,
              onLeftIconPressed: () => Navigator.of(context).pop(),
              onRightIconPressed: () {},
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildReportColumn([
                        {'image': 'assets/icons/rapporteren/crop_icon.png', 'text': 'Gewasschade'},
                        {'image': 'assets/icons/rapporteren/health_icon.png', 'text': 'Diergezondheid'},
                      ]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildReportColumn([
                        {'image': 'assets/icons/rapporteren/accident_icon.png', 'text': 'Verkeersongeval'},
                        {'image': 'assets/icons/rapporteren/sighting_icon.png', 'text': 'Waarnemingen'},
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportColumn(List<Map<String, String>> reports) {
    return Column(
      children: reports.map((report) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildReportButton(
              context: context,
              image: report['image']!,
              text: report['text']!,
              onPressed: () => _handleReportTypeSelection(report['text']!),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReportButton({
    required BuildContext context,
    required String image,
    required String text,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 3,
                    child: Image.asset(image, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    flex: 2,
                    child: Text(
                      text,
                      style: AppTextTheme.textTheme.titleMedium?.copyWith(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.brown.withOpacity(0.5),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
