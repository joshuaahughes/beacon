import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:meshager/protos/mesh.dart';
import 'bluetooth_state_handler.dart';
import 'package:flutter/foundation.dart';

class MeshtasticService {
  static final MeshtasticService _instance = MeshtasticService._internal();
  factory MeshtasticService() => _instance;
  MeshtasticService._internal();

  final BluetoothStateHandler bluetoothHandler = BluetoothStateHandler();
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _characteristic;

  final StreamController<MeshPacket> _packetController =
      StreamController<MeshPacket>.broadcast();
  final StreamController<Position> _positionController =
      StreamController<Position>.broadcast();
  Stream<MeshPacket> get packetStream => _packetController.stream;
  Stream<Position> get positionStream => _positionController.stream;
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  // Meshtastic service and characteristic UUIDs
  static const String SERVICE_UUID = "6ba1b218-15a8-461f-9fa8-5dcae273eafd";
  static const String FROMRADIO_CHARACTERISTIC_UUID =
      "2c55e69e-4993-11ed-b878-0242ac120002";
  static const String TORADIO_CHARACTERISTIC_UUID =
      "f75c76d2-129e-4dad-a1dd-7866124401e7";
  static const String FROMNUM_CHARACTERISTIC_UUID =
      "ed9da18c-a800-4f66-a670-aa7547e34453";

  // BLE name pattern from Android implementation
  static const String BLE_NAME_PATTERN = r'^.*_([0-9a-fA-F]{4})$';

  // Connection state
  bool _isFirstSend = true;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int MAX_RECONNECT_ATTEMPTS = 3;
  static const Duration RECONNECT_DELAY = Duration(seconds: 2);

  Future<void> initialize() async {
    await bluetoothHandler.initialize();
  }

  Future<List<BluetoothDevice>> scanForDevices() async {
    if (!await bluetoothHandler.isBluetoothAvailable()) {
      throw Exception('Bluetooth is not available');
    }

    List<BluetoothDevice> discoveredDevices = [];

    try {
      // First check bonded devices (already connected)
      print('Checking bonded devices...');
      final bondedDevices = await FlutterBluePlus.bondedDevices;
      print('Found ${bondedDevices.length} bonded devices');
      for (var device in bondedDevices) {
        print('Bonded device: ${device.platformName} (${device.remoteId})');
        if (device.platformName.isNotEmpty &&
            RegExp(BLE_NAME_PATTERN).hasMatch(device.platformName)) {
          discoveredDevices.add(device);
        }
      }

      // Then scan for new devices
      print('Starting scan for new devices...');
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 4),
        androidUsesFineLocation: true,
      );

      // Listen for scan results
      await for (List<ScanResult> results in FlutterBluePlus.scanResults) {
        print('Received ${results.length} scan results');
        for (ScanResult result in results) {
          print(
              'Found device: ${result.device.platformName} (${result.device.remoteId})');
          if (result.device.platformName.isNotEmpty &&
              RegExp(BLE_NAME_PATTERN).hasMatch(result.device.platformName) &&
              !discoveredDevices
                  .any((d) => d.remoteId == result.device.remoteId)) {
            discoveredDevices.add(result.device);
          }
        }
      }
    } catch (e) {
      print('Error scanning for devices: $e');
      rethrow;
    } finally {
      await FlutterBluePlus.stopScan();
      print('Scan complete. Found ${discoveredDevices.length} total devices');
    }

    return discoveredDevices;
  }

  Future<void> connect(BluetoothDevice device) async {
    StreamSubscription<BluetoothConnectionState>? connectionSubscription;
    try {
      print('Starting connection to device: ${device.platformName}');

      // First disconnect if already connected
      if (device.isConnected) {
        print('Device already connected, disconnecting first...');
        await device.disconnect();
      }

      // Monitor connection state
      connectionSubscription = device.connectionState.listen((state) {
        print('Connection state changed: $state');
        if (state == BluetoothConnectionState.disconnected) {
          _scheduleReconnect('Device disconnected');
        }
      });

      // Connect with service UUIDs
      print('Connecting to device...');
      await device.connect(
        timeout: const Duration(seconds: 4),
        autoConnect: false,
      );
      print('Basic connection established');

      // Wait for connection to be fully established
      print('Waiting for connection to stabilize...');
      await Future.delayed(const Duration(seconds: 1));

      // Verify connection state
      if (!device.isConnected) {
        print('Device not connected after delay');
        throw Exception('Failed to establish connection');
      }

      // Request MTU based on platform
      if (!kIsWeb) {
        print('Requesting MTU...');
        try {
          if (defaultTargetPlatform == TargetPlatform.android) {
            await device.requestMtu(512);
          } else if (defaultTargetPlatform == TargetPlatform.iOS) {
            await device.requestMtu(185);
          }
          print('MTU request completed');
        } catch (e) {
          print('MTU request failed, continuing anyway: $e');
        }
      }

      _connectedDevice = device;

      // Discover services with retry
      print('Discovering services...');
      List<BluetoothService> services = [];
      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          // Verify connection before each attempt
          if (!device.isConnected) {
            print('Device disconnected during service discovery');
            throw Exception('Device disconnected');
          }

          // Try to get services first
          print('Attempting to get services...');
          services = await device.discoverServices();
          print(
              'Services discovered: ${services.map((s) => s.uuid.toString()).join(', ')}');

          // Check if this is a Meshtastic device
          bool hasMeshtasticService =
              services.any((s) => s.uuid.toString() == SERVICE_UUID);
          if (!hasMeshtasticService) {
            print('Device does not have Meshtastic service, disconnecting...');
            await device.disconnect();
            throw Exception('This device is not a Meshtastic device');
          }
          break;
        } catch (e) {
          retryCount++;
          if (retryCount >= maxRetries) {
            print('Failed to discover services after $maxRetries attempts: $e');
            await device.disconnect();
            throw Exception('Failed to discover services: $e');
          }
          print('Service discovery attempt $retryCount failed: $e');
          // Wait longer between retries
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      BluetoothService? service = services.firstWhere(
        (s) => s.uuid.toString() == SERVICE_UUID,
        orElse: () => throw Exception('Meshtastic service not found'),
      );
      print('Found Meshtastic service');

      // Find characteristics
      print('Looking for characteristics...');
      BluetoothCharacteristic? fromRadioChar =
          service.characteristics.firstWhere(
        (c) => c.uuid.toString() == FROMRADIO_CHARACTERISTIC_UUID,
        orElse: () => throw Exception('FromRadio characteristic not found'),
      );
      print('Found FromRadio characteristic');

      BluetoothCharacteristic? toRadioChar = service.characteristics.firstWhere(
        (c) => c.uuid.toString() == TORADIO_CHARACTERISTIC_UUID,
        orElse: () => throw Exception('ToRadio characteristic not found'),
      );
      print('Found ToRadio characteristic');

      BluetoothCharacteristic? fromNumChar = service.characteristics.firstWhere(
        (c) => c.uuid.toString() == FROMNUM_CHARACTERISTIC_UUID,
        orElse: () => throw Exception('FromNum characteristic not found'),
      );
      print('Found FromNum characteristic');

      // Setup characteristics
      print('Setting up characteristics...');
      await fromRadioChar.setNotifyValue(true);
      await fromNumChar.setNotifyValue(true);

      // Store characteristics for later use
      _characteristic = toRadioChar;
      _fromRadioChar = fromRadioChar;
      _fromNumChar = fromNumChar;

      // Listen for FromNum notifications
      _fromNumChar!.onValueReceived.listen((value) {
        print('FromNum notification received');
        _handleFromNumNotification(value);
      });

      // Listen for FromRadio notifications
      _fromRadioChar!.onValueReceived.listen((value) {
        print('FromRadio notification received');
        _handleFromRadioNotification(value);
      });

      print('Connection and setup completed successfully');
    } catch (e) {
      print('Error during connection: $e');
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        _connectedDevice = null;
      }
      rethrow;
    } finally {
      connectionSubscription?.cancel();
    }
  }

  BluetoothCharacteristic? _fromRadioChar;
  BluetoothCharacteristic? _fromNumChar;

  void _scheduleReconnect(String reason) {
    if (_reconnectTimer == null &&
        _reconnectAttempts < MAX_RECONNECT_ATTEMPTS) {
      print('Scheduling reconnect because $reason');
      _reconnectTimer = Timer(RECONNECT_DELAY, () async {
        _reconnectTimer = null;
        _reconnectAttempts++;
        try {
          if (_connectedDevice != null) {
            await connect(_connectedDevice!);
            _reconnectAttempts = 0; // Reset on successful connection
          }
        } catch (e) {
          print('Reconnect attempt $_reconnectAttempts failed: $e');
          if (_reconnectAttempts < MAX_RECONNECT_ATTEMPTS) {
            _scheduleReconnect('Reconnect attempt failed');
          }
        }
      });
    } else {
      print('Skipping reconnect for $reason');
    }
  }

  Future<void> _handleFromNumNotification(List<int> value) async {
    try {
      print('Handling FromNum notification');
      // Read from FromRadio characteristic
      if (_fromRadioChar != null) {
        final readValue = await _fromRadioChar!.read();
        if (readValue.isNotEmpty) {
          print('Received ${readValue.length} bytes from radio');
          _handleReceivedData(readValue);

          // If this is the first send, start reading from radio
          if (_isFirstSend) {
            _isFirstSend = false;
            _doReadFromRadio(true);
          }
        }
      }
    } catch (e) {
      print('Error handling FromNum notification: $e');
      _scheduleReconnect('Error during FromNum notification handling');
    }
  }

  Future<void> _doReadFromRadio(bool firstRead) async {
    try {
      if (_fromRadioChar != null) {
        final readValue = await _fromRadioChar!.read();
        if (readValue.isNotEmpty) {
          print('Received ${readValue.length} bytes from radio');
          _handleReceivedData(readValue);

          // Queue up another read until we run out of packets
          _doReadFromRadio(firstRead);
        } else {
          print('Done reading from radio, fromradio is empty');
          if (firstRead) {
            // If we just finished our initial download, start watching FromNum
            _startWatchingFromNum();
          }
        }
      }
    } catch (e) {
      print('Error during doReadFromRadio: $e');
      _scheduleReconnect('Error during doReadFromRadio');
    }
  }

  void _startWatchingFromNum() {
    print('Starting to watch FromNum characteristic');
    // The FromNum characteristic is already set up for notifications
    // in the connect method, so we don't need to do anything here
  }

  void _handleFromRadioNotification(List<int> value) {
    try {
      print('Handling FromRadio notification');
      _handleReceivedData(value);
    } catch (e) {
      print('Error handling FromRadio notification: $e');
      _scheduleReconnect('Error during FromRadio notification handling');
    }
  }

  void _handleReceivedData(List<int> data) {
    try {
      // Parse the received data as a MeshPacket
      final packet = MeshPacket();
      packet.mergeFromBuffer(Uint8List.fromList(data));
      _packetController.add(packet);

      // If this is a position packet, also emit it on the position stream
      if (packet.decoded.hasPortnum() && packet.decoded.portnum == PortNum.positionApp) {
        final position = Position();
        position.mergeFromBuffer(packet.decoded.payload);
        if (position.hasLatitude() && position.hasLongitude()) {
          _positionController.add(position);
        }
      }
    } catch (e) {
      print('Error parsing received data: $e');
    }
  }

  Future<void> sendToRadio(List<int> data) async {
    try {
      if (_characteristic == null) {
        throw Exception('Not connected to a device');
      }

      print('Sending ${data.length} bytes to radio');
      await _characteristic!.write(data);

      // If this is the first send, start reading from radio
      if (_isFirstSend) {
        _isFirstSend = false;
        _doReadFromRadio(false);
      }
    } catch (e) {
      print('Error sending data to radio: $e');
      _scheduleReconnect('Error during sendToRadio');
      rethrow;
    }
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
    _isFirstSend = true;

    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
    }

    _fromRadioChar = null;
    _fromNumChar = null;
    _characteristic = null;
  }

  void dispose() {
    disconnect();
    _packetController.close();
    _positionController.close();
    _reconnectTimer?.cancel();
  }

  Future<void> startScan() async {
    if (!await bluetoothHandler.isBluetoothAvailable()) {
      throw Exception('Bluetooth is not available');
    }

    print('Starting BLE scan with parameters:');
    print('- Timeout: 4 seconds');
    print('- Using fine location: true');
    print(
        '- Service UUIDs: $SERVICE_UUID, $FROMRADIO_CHARACTERISTIC_UUID, $TORADIO_CHARACTERISTIC_UUID, $FROMNUM_CHARACTERISTIC_UUID');

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 4),
        androidUsesFineLocation: true,
        // Remove service UUIDs to scan for all devices
        // withServices: [
        //   Guid(SERVICE_UUID),
        //   Guid(FROMRADIO_CHARACTERISTIC_UUID),
        //   Guid(TORADIO_CHARACTERISTIC_UUID),
        //   Guid(FROMNUM_CHARACTERISTIC_UUID),
        // ],
      );
      print('BLE scan started successfully');
    } catch (e) {
      print('Error starting BLE scan: $e');
      rethrow;
    }
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> sendPacket(MeshPacket packet) async {
    if (_characteristic == null) {
      throw Exception('Not connected to a device');
    }

    Uint8List data = packet.writeToBuffer();
    await _characteristic!.write(data);
  }

  Future<NodeInfo> getNodeInfo() async {
    if (_characteristic == null) {
      throw Exception('No device connected');
    }

    try {
      // Create admin message to request node info
      final adminMessage = AdminMessage()..getNodeInfoRequest = true;

      // Create mesh packet
      final packet = MeshPacket()
        ..to = 0xffffffff // Broadcast
        ..decoded.portnum = PortNum.adminApp
        ..decoded.payload = adminMessage.writeToBuffer();

      // Send the request
      await _characteristic!.write(packet.writeToBuffer());

      // Wait for response
      final completer = Completer<NodeInfo>();
      Timer? timeout;

      // Listen for response
      final subscription = _packetController.stream.listen((packet) {
        if (packet.decoded.portnum == PortNum.adminApp && packet.decoded.hasPayload()) {
          try {
            // Create a new AdminMessage instance
            final adminMessage = AdminMessage();
            // Parse the payload into the admin message
            adminMessage.mergeFromBuffer(packet.decoded.payload);

            // Check if we have node info
            if (adminMessage.hasNodeInfo()) {
              final nodeInfo = adminMessage.nodeInfo;
              // Verify we have the required fields
              if (nodeInfo.hasLongName() && nodeInfo.hasNum()) {
                completer.complete(nodeInfo);
                timeout?.cancel();
              }
            }
          } catch (e) {
            print('Error parsing admin message: $e');
            print('Payload length: ${packet.decoded.payload.length}');
            print(
                'Payload hex: ${packet.decoded.payload.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
          }
        }
      });

      // Set timeout
      timeout = Timer(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          subscription.cancel();
          completer.completeError('Timeout waiting for node info');
        }
      });

      return completer.future;
    } catch (e) {
      print('Error getting node info: $e');
      rethrow;
    }
  }

  Future<void> sendTextMessage(String text, String toNodeId) async {
    if (_characteristic == null) {
      throw Exception('Not connected to a device');
    }

    try {
      final textMessage = TextMessage()..text = text;

      final packet = MeshPacket()
        ..from = 0 // Will be filled by the device
        ..to = int.parse(toNodeId)
        ..decoded.payload = textMessage.writeToBuffer()
        ..decoded.portnum = PortNum.textMessageApp;

      await _characteristic!.write(packet.writeToBuffer());
    } catch (e) {
      print('Error sending text message: $e');
      rethrow;
    }
  }

  Future<void> sendVoiceMessage(Uint8List audioData, String toNodeId) async {
    if (_characteristic == null) {
      throw Exception('Not connected to a device');
    }

    try {
      final packet = MeshPacket()
        ..from = 0 // Will be filled by the device
        ..to = int.parse(toNodeId)
        ..decoded.payload = audioData
        ..decoded.portnum = PortNum.telemetryApp;

      await _characteristic!.write(packet.writeToBuffer());
    } catch (e) {
      print('Error sending voice message: $e');
      rethrow;
    }
  }
}
