import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothStateHandler {
  bool _isInitialized = false;
  bool _hasPermissions = false;
  BluetoothAdapterState _currentState = BluetoothAdapterState.unknown;
  StreamSubscription<BluetoothAdapterState>? _stateSubscription;

  bool get hasPermissions => _hasPermissions;
  BluetoothAdapterState get currentState => _currentState;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Listen for Bluetooth state changes
    _stateSubscription = FlutterBluePlus.adapterState.listen((state) async {
      print('Bluetooth state changed: $state');
      _currentState = state;
      if (state == BluetoothAdapterState.on) {
        await _checkPermissions();
      }
    });

    // Check initial state
    _currentState = await FlutterBluePlus.adapterState.first;
    print('Initial Bluetooth state: $_currentState');
    if (_currentState == BluetoothAdapterState.on) {
      await _checkPermissions();
    }

    _isInitialized = true;
  }

  Future<void> _checkPermissions() async {
    try {
      // Check location permission (required for BLE scanning)
      final locationStatus = await Permission.location.status;
      if (!locationStatus.isGranted) {
        print('Requesting location permission...');
        final result = await Permission.location.request();
        if (!result.isGranted) {
          print('Location permission denied');
          _hasPermissions = false;
          return;
        }
      }

      // Check Bluetooth permission
      if (await Permission.bluetooth.status.isDenied) {
        print('Requesting Bluetooth permission...');
        final result = await Permission.bluetooth.request();
        if (!result.isGranted) {
          print('Bluetooth permission denied');
          _hasPermissions = false;
          return;
        }
      }

      // Check Bluetooth scan permission
      if (await Permission.bluetoothScan.status.isDenied) {
        print('Requesting Bluetooth scan permission...');
        final result = await Permission.bluetoothScan.request();
        if (!result.isGranted) {
          print('Bluetooth scan permission denied');
          _hasPermissions = false;
          return;
        }
      }

      // Check Bluetooth connect permission
      if (await Permission.bluetoothConnect.status.isDenied) {
        print('Requesting Bluetooth connect permission...');
        final result = await Permission.bluetoothConnect.request();
        if (!result.isGranted) {
          print('Bluetooth connect permission denied');
          _hasPermissions = false;
          return;
        }
      }

      print('All Bluetooth permissions granted');
      _hasPermissions = true;
    } catch (e) {
      print('Error checking permissions: $e');
      _hasPermissions = false;
    }
  }

  Future<bool> isBluetoothAvailable() async {
    if (!_isInitialized) {
      await initialize();
    }

    final state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on && _hasPermissions;
  }

  void dispose() {
    _stateSubscription?.cancel();
    _isInitialized = false;
  }
} 