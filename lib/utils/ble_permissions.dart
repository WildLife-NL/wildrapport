import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Platform-specific Bluetooth permission + adapter checks for contact tracing.
class BlePermissions {
  BlePermissions._();

  static Future<bool> ensureReady({
    void Function(String message)? onStatus,
  }) async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();
      if (statuses.values.any((s) => !s.isGranted)) {
        onStatus?.call('Bluetooth-permissies nodig');
        return false;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.bluetooth.request();
      if (!status.isGranted && !status.isLimited) {
        onStatus?.call('Bluetooth-toestemming nodig in Instellingen');
        return false;
      }
    }

    final state = await _waitForAdapterState();
    if (state != BluetoothAdapterState.on) {
      onStatus?.call('Zet Bluetooth aan');
      return false;
    }
    return true;
  }

  static Future<BluetoothAdapterState> _waitForAdapterState() async {
    try {
      return await FlutterBluePlus.adapterState
          .where((s) => s != BluetoothAdapterState.unknown)
          .first
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('[BlePermissions] adapter state wait failed: $e');
      return BluetoothAdapterState.unavailable;
    }
  }
}
