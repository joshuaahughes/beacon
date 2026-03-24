import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// A wrapper around FlutterBluePlus static methods to enable mocking and TDD.
class BleAdapter {
  Future<void> startScan({
    List<Guid> withServices = const [],
    Duration? timeout,
  }) async {
    await FlutterBluePlus.startScan(
        withServices: withServices, timeout: timeout);
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  bool get isScanningNow => FlutterBluePlus.isScanningNow;
}
