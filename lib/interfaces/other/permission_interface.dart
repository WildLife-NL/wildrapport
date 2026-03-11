import 'package:flutter/material.dart';

enum PermissionType { location }

abstract class PermissionInterface {
  Future<bool> isPermissionGranted(PermissionType permission);

  Future<bool> requestPermission(
    BuildContext context,
    PermissionType permission, {
    bool showRationale = true,
  });

  Future<bool> showPermissionRationale(
    BuildContext context,
    PermissionType permission,
  );

  Future<void> handleInitialPermissions(BuildContext context);
}
