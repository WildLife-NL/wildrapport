import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/permission_interface.dart';

class PermissionGate extends StatelessWidget {
  final Widget child;

  const PermissionGate({
    super.key,
    required this.child,
  });

  Future<bool> _checkAndRequestPermission(BuildContext context) async {
    debugPrint('[PermissionGate] Checking and requesting permission');
    final permissionManager = context.read<PermissionInterface>();
    
    // Check if permission is already granted
    final hasPermission = await permissionManager.isPermissionGranted(PermissionType.location);
    debugPrint('[PermissionGate] Initial permission status: $hasPermission');
    
    if (hasPermission) return true;

    // Request permission if not granted
    debugPrint('[PermissionGate] Permission not granted, requesting...');
    final permissionGranted = await permissionManager.requestPermission(
      context,
      PermissionType.location,
    );

    debugPrint('[PermissionGate] Permission request result: $permissionGranted');
    return permissionGranted;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[PermissionGate] Building widget');
    return FutureBuilder<bool>(
      future: _checkAndRequestPermission(context),
      builder: (context, snapshot) {
        debugPrint('[PermissionGate] FutureBuilder state: ${snapshot.connectionState}, data: ${snapshot.data}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == true) {
          return child;
        }

        // Permission denied - show blocking overlay
        return Stack(
          children: [
            // Render the main screen in background (dimmed)
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.darken,
              ),
              child: child,
            ),
            // Permission request overlay
            Center(
              child: Card(
                margin: const EdgeInsets.all(32),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Locatie Toegang Vereist',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'We hebben toegang tot je locatie nodig om nauwkeurig te kunnen rapporteren waar je dieren hebt waargenomen.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _checkAndRequestPermission(context),
                        child: const Text('Geef Toegang'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
