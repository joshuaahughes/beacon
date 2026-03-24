import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:beacon/features/ble/data/repositories/ble_repository.dart';

class MockFlutterBluePlus extends Mock {}
class MockBluetoothDevice extends Mock implements BluetoothDevice {}
class MockBluetoothService extends Mock implements BluetoothService {}
class MockBluetoothCharacteristic extends Mock implements BluetoothCharacteristic {}

void main() {
  late BleRepository bleRepository;
  late MockBluetoothDevice mockDevice;

  setUpAll(() {
    registerFallbackValue(const Duration(seconds: 0));
    registerFallbackValue(License.free);
  });

  setUp(() {
    mockDevice = MockBluetoothDevice();
    // BleRepository will likely take an optional FlutterBluePlus-like interface if we want to mock the static calls,
    // but flutter_blue_plus is mostly static. We might need a wrapper or use the instance if available in newer versions.
    // In v1.x, FlutterBluePlus use static methods. 
    // For TDD, let's assume we have a way to inject or wrap it.
    bleRepository = BleRepository();
  });

  group('BleRepository', () {
    test('scanResults should emit discovered devices', () async {
      // This is a placeholder since flutter_blue_plus is static and hard to mock without a wrapper.
      // In a real TDD scenario, I'd create a wrapper interface.
      expect(bleRepository.scanResults, isA<Stream<List<ScanResult>>>());
    });

    test('connect should initiate connection with the device', () async {
      when(() => mockDevice.connect(
        timeout: any(named: 'timeout'),
        license: any(named: 'license'),
      )).thenAnswer((_) async => {});
      when(() => mockDevice.discoverServices()).thenAnswer((_) async => []);
      
      await bleRepository.connect(mockDevice);
      
      verify(() => mockDevice.connect(
        timeout: any(named: 'timeout'),
        license: any(named: 'license'),
      )).called(1);
    });
  });
}
