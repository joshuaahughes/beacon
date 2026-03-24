import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beacon/data/repositories/ble_adapter.dart';
import 'package:beacon/data/repositories/ble_repository.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockBleAdapter extends Mock implements BleAdapter {}

void main() {
  late BleRepository bleRepository;
  late MockBleAdapter mockBleAdapter;

  setUpAll(() {
    registerFallbackValue(Guid('00000000-0000-0000-0000-000000000000'));
    registerFallbackValue(const Duration(seconds: 0));
  });

  setUp(() {
    mockBleAdapter = MockBleAdapter();
    bleRepository = BleRepository(bleAdapter: mockBleAdapter);
  });

  group('BleRepository Navigation & Scanning', () {
    test('startScan invokes BleAdapter.startScan with core Meshtastic service UUIDs', () async {
      // Arrange
      when(() => mockBleAdapter.isScanningNow).thenReturn(false);
      when(() => mockBleAdapter.startScan(
            withServices: any(named: 'withServices'),
            timeout: any(named: 'timeout'),
          )).thenAnswer((_) async {});

      // Act
      await bleRepository.startScanning();

      // Assert
      verify(() => mockBleAdapter.startScan(
            withServices: [Guid('CB0B9710-984C-11E5-86E0-0800200C9A66')], // Standard Meshtastic UUID
            timeout: const Duration(seconds: 15),
          )).called(1);
    });

    test('startScan does nothing if already scanning', () async {
      // Arrange
      when(() => mockBleAdapter.isScanningNow).thenReturn(true);

      // Act
      await bleRepository.startScanning();

      // Assert
      verifyNever(() => mockBleAdapter.startScan(
            withServices: any(named: 'withServices'),
             timeout: any(named: 'timeout'),
          ));
    });

    test('stopScan invokes BleAdapter.stopScan', () async {
      // Arrange
      when(() => mockBleAdapter.stopScan()).thenAnswer((_) async {});

      // Act
      await bleRepository.stopScanning();

      // Assert
      verify(() => mockBleAdapter.stopScan()).called(1);
    });
  });
}
