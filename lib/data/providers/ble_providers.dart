import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:beacon/features/ble/data/repositories/ble_repository.dart';

final bleRepositoryProvider = Provider<BleRepository>((ref) {
  return BleRepository();
});

final bleScanningProvider = StreamProvider<bool>((ref) {
  final repo = ref.watch(bleRepositoryProvider);
  return repo.isScanning;
});

final bleScanResultsProvider = StreamProvider<List<dynamic>>((ref) {
  final repo = ref.watch(bleRepositoryProvider);
  return repo.scanResults;
});

class ConnectedDeviceNotifier extends Notifier<BluetoothDevice?> {
  @override
  BluetoothDevice? build() => null;
  
  void setDevice(BluetoothDevice? device) {
    state = device;
  }
}

final connectedDeviceProvider = NotifierProvider<ConnectedDeviceNotifier, BluetoothDevice?>(ConnectedDeviceNotifier.new);

final connectionStateProvider = StreamProvider.family<BluetoothConnectionState, BluetoothDevice>((ref, device) {
  return device.connectionState;
});
