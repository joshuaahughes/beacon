import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/meshtastic_service.dart';
import '../protos/mesh.dart';
import '../models/message.dart';
import '../models/channel.dart';
import 'package:flutter/material.dart';

class MeshtasticProvider with ChangeNotifier {
  final MeshtasticService _meshtasticService;
  List<BluetoothDevice> _discoveredDevices = [];
  BluetoothDevice? _connectedDevice;
  List<Message> _messages = [];
  List<Channel> _channels = [];
  bool _isScanning = false;
  String? _error;
  List<Message> _localMessages = [];
  List<MeshPacket> _messageHistory = [];
  Position? _lastPosition;
  bool _isConnecting = false;
  bool _hasBluetoothPermission = false;
  BluetoothAdapterState _bluetoothState = BluetoothAdapterState.unknown;

  // Getters
  List<BluetoothDevice> get discoveredDevices => _discoveredDevices;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  List<Message> get messages => List.unmodifiable(_messages);
  List<Channel> get channels => List.unmodifiable(_channels);
  bool get isScanning => _isScanning;
  String? get error => _error;
  List<Message> get localMessages => List.unmodifiable(_localMessages);
  List<MeshPacket> get messageHistory => _messageHistory;
  Position? get lastPosition => _lastPosition;
  bool get isConnecting => _isConnecting;
  bool get hasBluetoothPermission => _hasBluetoothPermission;
  BluetoothAdapterState get bluetoothState => _bluetoothState;

  MeshtasticProvider(this._meshtasticService) {
    print('Initializing MeshtasticProvider...');
    _initialize();
    _listenToMessages();
    _initializeChannels();
  }

  void _initialize() {
    print('Setting up MeshtasticProvider...');
    
    // Listen to scan results
    _meshtasticService.scanResults.listen((results) {
      print('Received scan results: ${results.length} devices');
      for (var result in results) {
        print('Found device: ${result.device.platformName} (${result.device.remoteId})');
      }
      _discoveredDevices = results.map((r) => r.device).toList();
      print('Updated discovered devices list: ${_discoveredDevices.length} devices');
      notifyListeners();
    });

    // Listen to packet stream
    _meshtasticService.packetStream.listen((packet) {
      print('Received packet: ${packet.decoded.portnum}');
      _messageHistory.add(packet);
      notifyListeners();
    });

    // Listen to position updates
    _meshtasticService.positionStream.listen((position) {
      print('Received position update');
      _lastPosition = position;
      notifyListeners();
    });

    // Check initial Bluetooth state
    print('Checking initial Bluetooth state...');
    _checkBluetoothState();
  }

  void _initializeChannels() {
    // Add default broadcast channel
    _channels.add(Channel.broadcast(0, 'Broadcast'));
    notifyListeners();
  }

  List<Message> getMessagesForChannel(String contactKey) {
    return _messages.where((m) {
      final channelIndex = contactKey[0];
      final nodeId = contactKey.substring(1);
      return m.senderId == nodeId || m.receiverId == nodeId;
    }).toList();
  }

  Future<void> _checkBluetoothState() async {
    print('Checking Bluetooth state...');
    try {
      _hasBluetoothPermission = await _meshtasticService.bluetoothHandler.hasPermissions;
      _bluetoothState = _meshtasticService.bluetoothHandler.currentState;
      print('Bluetooth state: $_bluetoothState, Has permissions: $_hasBluetoothPermission');
      notifyListeners();
    } catch (e) {
      print('Error checking Bluetooth state: $e');
      _error = 'Failed to check Bluetooth state: $e';
      notifyListeners();
    }
  }

  void _listenToMessages() {
    _meshtasticService.packetStream.listen(
      (packet) {
        if (packet.decoded.portnum == PortNum.textMessageApp) {
          final message = Message(
            senderId: packet.from.toString(),
            receiverId: packet.to.toString(),
            content: String.fromCharCodes(packet.decoded.payload),
            timestamp: DateTime.now(),
          );
          _messages.add(message);
          
          // Update channel
          final contactKey = '0${packet.from}'; // Default to channel 0 for now
          final channelIdx = _channels.indexWhere((c) => c.contactKey == contactKey);
          if (channelIdx == -1) {
            // Create new channel for this node
            _channels.add(Channel.direct(
              0, // Default to channel 0 for now
              packet.from.toString(),
              'Node ${packet.from}',
            ));
          } else {
            // Update existing channel
            _channels[channelIdx] = _channels[channelIdx].copyWith(
              lastMessage: message.content,
              lastMessageTime: message.timestamp,
              unreadCount: _channels[channelIdx].unreadCount + 1,
            );
          }
          
          notifyListeners();
        }
      },
      onError: (error) {
        _error = 'Error receiving message: $error';
        notifyListeners();
      },
    );
  }

  Future<void> startScan() async {
    if (_isScanning) return;

    try {
      print('Starting scan...');
      _isScanning = true;
      _error = null;
      notifyListeners();

      // Check Bluetooth state
      print('Checking Bluetooth state...');
      await _checkBluetoothState();
      if (!_hasBluetoothPermission || _bluetoothState != BluetoothAdapterState.on) {
        print('Bluetooth not available: hasPermission=$_hasBluetoothPermission, state=$_bluetoothState');
        throw Exception('Bluetooth is not available');
      }

      // Start scanning
      print('Starting BLE scan...');
      await _meshtasticService.startScan();
      print('BLE scan started');

      // Wait for scan to complete
      print('Waiting for scan results...');
      await Future.delayed(const Duration(seconds: 4));
      print('Scan complete. Found ${_discoveredDevices.length} devices');
      _isScanning = false;
      notifyListeners();
    } catch (e) {
      print('Error during scan: $e');
      _error = e.toString();
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> stopScan() async {
    await _meshtasticService.stopScan();
    _isScanning = false;
    notifyListeners();
  }

  Future<void> connect(BluetoothDevice device) async {
    if (_isConnecting) return;

    _isConnecting = true;
    _error = null;
    notifyListeners();

    try {
      await _meshtasticService.connect(device);
      _connectedDevice = device;
      
      // Get initial node info
      final nodeInfo = await _meshtasticService.getNodeInfo();
      print('Connected to node: ${nodeInfo.longName}');
      
    } catch (e) {
      _error = 'Failed to connect: $e';
      if (_connectedDevice != null) {
        await disconnect();
      }
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    try {
      await _meshtasticService.disconnect();
      _connectedDevice = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to disconnect: $e';
      notifyListeners();
    }
  }

  Future<void> sendTextMessage(String text, String toNodeId, {int channelIndex = 0}) async {
    if (_connectedDevice == null) {
      throw Exception('No device connected');
    }

    try {
      await _meshtasticService.sendTextMessage(text, toNodeId);
      
      // Add message to local list
      final message = Message(
        senderId: 'ME',
        receiverId: toNodeId,
        content: text,
        timestamp: DateTime.now(),
      );
      _messages.add(message);
      
      // Update channel
      final contactKey = '$channelIndex$toNodeId';
      final channelIdx = _channels.indexWhere((c) => c.contactKey == contactKey);
      if (channelIdx != -1) {
        _channels[channelIdx] = _channels[channelIdx].copyWith(
          lastMessage: text,
          lastMessageTime: DateTime.now(),
        );
      }
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to send message: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> sendVoiceMessage(Uint8List audioData, String toNodeId) async {
    if (_connectedDevice == null) {
      throw Exception('No device connected');
    }

    try {
      await _meshtasticService.sendVoiceMessage(audioData, toNodeId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to send voice message: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<NodeInfo> getNodeInfo() async {
    if (_connectedDevice == null) {
      throw Exception('No device connected');
    }

    try {
      final nodeInfo = await _meshtasticService.getNodeInfo();
      _error = null;
      notifyListeners();
      return nodeInfo;
    } catch (e) {
      _error = 'Failed to get node info: $e';
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _meshtasticService.dispose();
    super.dispose();
  }
} 