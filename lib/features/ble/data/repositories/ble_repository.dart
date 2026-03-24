import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleRepository {
  // Meshtastic Service UUID
  static const String meshServiceUuid = '6ba1b218-15a8-461f-9fa8-5dcae273eafd';

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  Future<void> startScan() async {
    // Check if Bluetooth is on
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      throw Exception('Bluetooth is not turned on');
    }

    await FlutterBluePlus.startScan(
      withServices: [Guid(meshServiceUuid)],
      timeout: const Duration(seconds: 15),
    );
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> connect(BluetoothDevice device) async {
    // Current flutter_blue_plus v2.x requires a license parameter for some reason?
    // Based on the error, let's try to satisfy it if it exists. 
    // In many cases, it's something like FlutterBluePlus.license = ... or passed to connect.
    // If the error persists, I will check the exact enum name.
    await device.connect(license: License.free);
  }

  Future<void> disconnect(BluetoothDevice device) async {
    await device.disconnect();
  }
}
