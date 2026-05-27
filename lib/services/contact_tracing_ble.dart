import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:wildrapport/utils/ble_mac_format.dart';

/// Smart Parks / Ranger BLE identifiers (collar contact tracing).
class ContactTracingBle {
  ContactTracingBle._();

  static const String rangerServiceUuid =
      '84aa6074-528a-8b86-d34c-b71d1ddc538d';
  static const int smartParksCompanyId = 0x0A61;

  static final RegExp _twelveHex = RegExp(r'[0-9A-Fa-f]{12}');

  static bool isSmartParksAdvertisement(ScanResult result) {
    final name = result.device.platformName.trim();
    final advName = result.advertisementData.advName.trim();
    final hasSpName = name.toUpperCase().startsWith('SP') ||
        advName.toUpperCase().startsWith('SP');
    final hasRangerService = result.advertisementData.serviceUuids.any(
      (u) => u.str.toLowerCase() == rangerServiceUuid,
    );
    final hasManufacturer = result.advertisementData.manufacturerData
        .containsKey(smartParksCompanyId);
    return hasSpName || hasRangerService || hasManufacturer;
  }

  static String deviceLabel(ScanResult result) {
    final name = result.device.platformName.trim();
    if (name.isNotEmpty) return name;
    final adv = result.advertisementData.advName.trim();
    if (adv.isNotEmpty) return adv;
    return 'Onbekend apparaat';
  }

  /// Resolves the collar EUI-48 address for the contact API.
  ///
  /// Android uses the BLE MAC as [BluetoothDevice.remoteId]. iOS uses a random
  /// UUID, so we fall back to manufacturer data and advertised names.
  static String? resolveHardwareAddress(ScanResult result) {
    final fromRemoteId = formatBleHardwareAddress(result.device.remoteId.str);
    if (isValidBleHardwareAddress(fromRemoteId)) return fromRemoteId;

    final fromManufacturer =
        _macFromManufacturerData(result.advertisementData.manufacturerData);
    if (fromManufacturer != null) return fromManufacturer;

    final fromName = _macFromAdvertisedNames(result);
    if (fromName != null) return fromName;

    return null;
  }

  static String? _macFromAdvertisedNames(ScanResult result) {
    for (final raw in [
      result.advertisementData.advName,
      result.device.platformName,
    ]) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) continue;

      final upper = trimmed.toUpperCase();
      if (upper.startsWith('SP')) {
        final afterPrefix = upper.substring(2).replaceAll(RegExp(r'[^0-9A-F]'), '');
        if (afterPrefix.length == 12) {
          final mac = formatBleHardwareAddress(afterPrefix);
          if (isValidBleHardwareAddress(mac)) return mac;
        }
      }

      final match = _twelveHex.firstMatch(trimmed.replaceAll(':', '').replaceAll('-', ''));
      if (match != null) {
        final mac = formatBleHardwareAddress(match.group(0)!);
        if (isValidBleHardwareAddress(mac)) return mac;
      }
    }
    return null;
  }

  static String? _macFromManufacturerData(Map<int, List<int>> data) {
    final preferred = data[smartParksCompanyId];
    if (preferred != null) {
      final mac = _macFromBytes(preferred);
      if (mac != null) return mac;
    }

    for (final bytes in data.values) {
      final mac = _macFromBytes(bytes);
      if (mac != null) return mac;
    }
    return null;
  }

  static String? _macFromBytes(List<int> bytes) {
    if (bytes.length < 6) return null;

    final candidates = <List<int>>[
      if (bytes.length == 6) bytes,
      if (bytes.length >= 6) bytes.sublist(0, 6),
      if (bytes.length >= 7) bytes.sublist(1, 7),
      if (bytes.length >= 12) bytes.sublist(6, 12),
      if (bytes.length >= 6) bytes.sublist(bytes.length - 6),
    ];

    for (final candidate in candidates) {
      if (candidate.length != 6) continue;
      final mac = _bytesToMac(candidate);
      if (isValidBleHardwareAddress(mac)) return mac;
    }
    return null;
  }

  static String _bytesToMac(List<int> bytes) {
    return bytes
        .map((b) => (b & 0xFF).toRadixString(16).padLeft(2, '0'))
        .join(':')
        .toUpperCase();
  }

  static Future<void> startCollarScan({required Duration timeout}) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return FlutterBluePlus.startScan(
        withServices: [Guid(rangerServiceUuid)],
        timeout: timeout,
      );
    }
    return FlutterBluePlus.startScan(timeout: timeout);
  }
}
