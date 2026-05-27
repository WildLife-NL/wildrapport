import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wildrapport/services/contact_tracing_ble.dart';

void main() {
  group('ContactTracingBle.resolveHardwareAddress', () {
    test('uses Android-style remoteId when it is a MAC', () {
      final result = _scanResult(
        remoteId: 'AA:BB:CC:DD:EE:FF',
        advName: '',
        manufacturerData: const {},
      );

      expect(
        ContactTracingBle.resolveHardwareAddress(result),
        'AA:BB:CC:DD:EE:FF',
      );
    });

    test('extracts MAC from Smart Parks manufacturer data', () {
      final result = _scanResult(
        remoteId: '6920A902-BA0E-4A13-A35F-6BC91161C517',
        advName: '',
        manufacturerData: {
          ContactTracingBle.smartParksCompanyId: [
            0xAA,
            0xBB,
            0xCC,
            0xDD,
            0xEE,
            0xFF,
          ],
        },
      );

      expect(
        ContactTracingBle.resolveHardwareAddress(result),
        'AA:BB:CC:DD:EE:FF',
      );
    });

    test('extracts MAC from SP-prefixed advertised name on iOS', () {
      final result = _scanResult(
        remoteId: '6920A902-BA0E-4A13-A35F-6BC91161C517',
        advName: 'SP1A2B3C4D5E6F',
        manufacturerData: const {},
      );

      expect(
        ContactTracingBle.resolveHardwareAddress(result),
        '1A:2B:3C:4D:5E:6F',
      );
    });

    test('returns null when iOS UUID has no embedded MAC', () {
      final result = _scanResult(
        remoteId: '6920A902-BA0E-4A13-A35F-6BC91161C517',
        advName: 'Unknown',
        manufacturerData: const {},
      );

      expect(ContactTracingBle.resolveHardwareAddress(result), isNull);
    });
  });
}

ScanResult _scanResult({
  required String remoteId,
  required String advName,
  required Map<int, List<int>> manufacturerData,
}) {
  return ScanResult(
    device: BluetoothDevice.fromId(remoteId),
    advertisementData: AdvertisementData(
      advName: advName,
      txPowerLevel: null,
      appearance: null,
      connectable: true,
      manufacturerData: manufacturerData,
      serviceData: const {},
      serviceUuids: const [],
    ),
    rssi: -60,
    timeStamp: DateTime.now(),
  );
}
