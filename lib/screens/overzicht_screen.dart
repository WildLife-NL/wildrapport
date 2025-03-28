import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/managers/screen_state_manager.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/widgets/brown_button.dart';
import 'package:wildrapport/widgets/white_bulk_button.dart';
import 'package:wildrapport/widgets/rapporteren.dart';

class OverzichtScreen extends StatefulWidget {
  const OverzichtScreen({super.key});

  @override
  State<OverzichtScreen> createState() => _OverzichtScreenState();
}

class _OverzichtScreenState extends ScreenStateManager<OverzichtScreen> {
  late final OverzichtViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OverzichtViewModel();
    _viewModel.loadState(context.read<AppStateProvider>());
  }

  @override
  void dispose() {
    _viewModel.saveState(context.read<AppStateProvider>());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: WillPopScope(
        onWillPop: () async {
          _viewModel.saveState(context.read<AppStateProvider>());
          return true;
        },
        child: Scaffold(
          body: Column(
            children: [
              Consumer<OverzichtViewModel>(
                builder: (context, viewModel, _) => TopContainer(
                  userName: viewModel.userName,
                  height: viewModel.topContainerHeight,
                  welcomeFontSize: viewModel.welcomeFontSize,
                  usernameFontSize: viewModel.usernameFontSize,
                ),
              ),
              ActionButtons(
                onRapporterenPressed: () {
                  _viewModel.saveState(context.read<AppStateProvider>());
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
        ),
      ),
    );
  }
  
  @override
  Map<String, dynamic> getCurrentState() {
    // TODO: implement getCurrentState
    throw UnimplementedError();
  }
  
  @override
  Map<String, dynamic> getInitialState() {
    // TODO: implement getInitialState
    throw UnimplementedError();
  }
  
  @override
  // TODO: implement screenName
  String get screenName => throw UnimplementedError();
  
  @override
  void updateState(String key, value) {
    // TODO: implement updateState
  }
}

class TopContainer extends StatelessWidget {
  final String userName;
  final double height;
  final double welcomeFontSize;
  final double usernameFontSize;

  const TopContainer({
    super.key,
    required this.userName,
    required this.height,
    required this.welcomeFontSize,
    required this.usernameFontSize,
  });

  @override
  Widget build(BuildContext context) {
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

  const ActionButtons({
    super.key,
    required this.onRapporterenPressed,
  });

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
                size: MediaQuery.of(context).size.width * 0.12,
              ),
              rightWidget: Icon(
                Icons.arrow_forward_ios,
                color: Colors.black54,
                size: MediaQuery.of(context).size.width * 0.05,
              ),
            ),
            WhiteBulkButton(
              text: 'Rapporteren',
              leftWidget: CircleIconContainer(
                icon: Icons.edit_note,
                iconColor: AppColors.brown,
                size: MediaQuery.of(context).size.width * 0.12,
              ),
              rightWidget: Icon(
                Icons.arrow_forward_ios,
                color: Colors.black54,
                size: MediaQuery.of(context).size.width * 0.05,
              ),
              onPressed: onRapporterenPressed,
            ),
            WhiteBulkButton(
              text: 'Mijn Rapporten',
              leftWidget: CircleIconContainer(
                icon: Icons.description,
                iconColor: AppColors.brown,
                size: MediaQuery.of(context).size.width * 0.12,
              ),
              rightWidget: Icon(
                Icons.arrow_forward_ios,
                color: Colors.black54,
                size: MediaQuery.of(context).size.width * 0.05,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OverzichtViewModel extends ChangeNotifier {
  String _userName = 'John Doe';
  final double topContainerHeight = 285.0; // Reduced from 300 to 285 (15px less)
  final double welcomeFontSize = 20.0;
  final double usernameFontSize = 24.0;
  final double logoWidth = 180.0;
  final double logoHeight = 180.0;

  String get userName => _userName;

  void loadState(AppStateProvider appStateProvider) {
    _userName = appStateProvider.getScreenState('OverzichtScreen', 'userName') ?? 'John Doe';
  }

  void saveState(AppStateProvider appStateProvider) {
    appStateProvider.setScreenState('OverzichtScreen', 'userName', _userName);
  }
}



