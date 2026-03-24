import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_adapter.dart';

class BleRepository {
  final BleAdapter bleAdapter;

  // The primary service UUID for Meshtastic
  static const meshtasticServiceUuidStr = 'CB0B9710-984C-11E5-86E0-0800200C9A66';
  static final meshtasticServiceUuid = Guid(meshtasticServiceUuidStr);

  BleRepository({required this.bleAdapter});

  /// Starts scanning for Meshtastic BLE devices.
  Future<void> startScanning() async {
    // Check if we are already scanning to prevent errors.
    if (bleAdapter.isScanningNow) {
      return;
    }

    await bleAdapter.startScan(
      withServices: [meshtasticServiceUuid],
      timeout: const Duration(seconds: 15),
    );
  }

  /// Stops scanning for devices.
  Future<void> stopScanning() async {
    await bleAdapter.stopScan();
  }
}
