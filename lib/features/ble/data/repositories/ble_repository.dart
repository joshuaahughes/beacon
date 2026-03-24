import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:beacon/core/proto/gen/meshtastic/mesh.pb.dart';

class BleRepository {
  // Meshtastic UUIDs
  static const String meshServiceUuid = '6ba1b218-15a8-461f-9fa8-5dcae273eafd';
  static const String fromRadioUuid = '2c55e69e-4993-11ed-b878-0242ac120002';
  static const String fromNumUuid = 'ed9da18c-a800-4f66-a670-aa7547e34453';
  static const String toRadioUuid = 'f75c76d2-129e-4dad-a1dd-7866124401e7';

  Timer? _fromRadioPollingTimer;
  BluetoothCharacteristic? _toRadioChar;

  final StreamController<FromRadio> _incomingMessagesController = StreamController<FromRadio>.broadcast();
  Stream<FromRadio> get incomingMessages => _incomingMessagesController.stream;

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
    // Connect to the device
    await device.connect(license: License.free);
    
    // Request a larger MTU to ensure we can receive full Meshtastic packets
    await device.requestMtu(512);
    
    // Discover BLE services
    final services = await device.discoverServices();
    
    // Find the Meshtastic Service
    final meshService = services.firstWhere(
      (s) => s.serviceUuid.toString().toLowerCase() == meshServiceUuid.toLowerCase(),
      orElse: () {
        final available = services.map((s) => s.serviceUuid.toString()).join(', ');
        throw Exception('Meshtastic service not found. Available: $available');
      },
    );

    // Find FromRadio characteristic
    final fromRadio = meshService.characteristics.firstWhere(
      (c) => c.characteristicUuid.toString().toLowerCase() == fromRadioUuid.toLowerCase(),
      orElse: () {
        final available = meshService.characteristics.map((c) => c.characteristicUuid.toString()).join(', ');
        throw Exception('FromRadio char not found. Available: $available');
      },
    );

    // Find FromNum characteristic
    final fromNum = meshService.characteristics.firstWhere(
      (c) => c.characteristicUuid.toString().toLowerCase() == fromNumUuid.toLowerCase(),
      orElse: () {
        final available = meshService.characteristics.map((c) => c.characteristicUuid.toString()).join(', ');
        throw Exception('FromNum char not found. Available: $available');
      },
    );
    
    // Find ToRadio characteristic
    _toRadioChar = meshService.characteristics.firstWhere(
      (c) => c.characteristicUuid.toString().toLowerCase() == toRadioUuid.toLowerCase(),
      orElse: () {
        final available = meshService.characteristics.map((c) => c.characteristicUuid.toString()).join(', ');
        throw Exception('ToRadio char not found. Available: $available');
      },
    );

    // Listen for incoming indications on FromNum FIRST before setting notify value
    // This strictly prevents missing ultra-fast edge triggered notifications.
    fromNum.onValueReceived.listen((value) async {
      debugPrint('🔔 FromNum Notified! Queue state: $value');
      // Loop to read all available packets from FromRadio
      while (true) {
        try {
          final bytes = await fromRadio.read();
          if (bytes.isEmpty) break;
          final fromRadioMsg = FromRadio.fromBuffer(bytes);
          _incomingMessagesController.add(fromRadioMsg);
        } catch (e) {
          debugPrint('Error reading fromRadio: $e');
          break;
        }
      }
    });

    // NOW subscribe to FromNum notifications
    await fromNum.setNotifyValue(true);
    
    // Give it a tiny moment to ensure notifications are established
    await Future.delayed(const Duration(milliseconds: 100));

    // Do an initial blind read of FromRadio to clear the buffer
    // and process any pre-existing messages.
    while (true) {
      try {
        final bytes = await fromRadio.read();
        if (bytes.isEmpty) break;
        final fromRadioMsg = FromRadio.fromBuffer(bytes);
        _incomingMessagesController.add(fromRadioMsg);
      } catch (e) {
        debugPrint('Initial blind read complete or errored: $e');
        break;
      }
    }

    // Set up a gentle 15-second fallback poll as a safety net in case 
    // the radio firmware drops a notification edge trigger.
    _fromRadioPollingTimer?.cancel();
    _fromRadioPollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
       try {
         // If disconnected, cancel timer
         if (device.isDisconnected) {
           timer.cancel();
           return;
         }
         
         while (true) {
            final bytes = await fromRadio.read();
            if (bytes.isEmpty) break; // Break if no new packets
            
            debugPrint('Polled packet recovered (Notification was dropped)! Size: ${bytes.length}');
            final fromRadioMsg = FromRadio.fromBuffer(bytes);
            _incomingMessagesController.add(fromRadioMsg);
         }
       } catch (e) {
         debugPrint('Recovery polling error: $e');
       }
    });

    // Send want_config_id signal to begin receiving node/radio data
    final wantConfigId = DateTime.now().millisecondsSinceEpoch & 0xFFFFFFFF; // Random 32-bit int
    final toRadioMsg = ToRadio(wantConfigId: wantConfigId);
    
    await _toRadioChar!.write(toRadioMsg.writeToBuffer(), withoutResponse: false);
  }

  Future<void> sendToRadio(ToRadio msg) async {
    if (_toRadioChar == null) {
      throw Exception('Not connected to a device or toRadio characteristic not found');
    }
    await _toRadioChar!.write(msg.writeToBuffer(), withoutResponse: false);
  }

  Future<void> disconnect(BluetoothDevice device) async {
    _fromRadioPollingTimer?.cancel();
    await device.disconnect();
  }
  
  void dispose() {
    _fromRadioPollingTimer?.cancel();
    _incomingMessagesController.close();
  }
}
