import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:beacon/features/ble/data/repositories/ble_repository.dart';
import 'package:beacon/core/proto/gen/meshtastic/mesh.pb.dart';

class MockBluetoothDevice extends Mock implements BluetoothDevice {}
class MockBluetoothService extends Mock implements BluetoothService {}
class MockBluetoothCharacteristic extends Mock implements BluetoothCharacteristic {}

void main() {
  late BleRepository bleRepository;
  late MockBluetoothDevice mockDevice;
  late MockBluetoothService mockService;
  late MockBluetoothCharacteristic fromRadioChar;
  late MockBluetoothCharacteristic fromNumChar;
  late MockBluetoothCharacteristic toRadioChar;

  setUpAll(() {
    registerFallbackValue(License.free);
    registerFallbackValue(<int>[]);
  });

  setUp(() {
    bleRepository = BleRepository();
    mockDevice = MockBluetoothDevice();
    mockService = MockBluetoothService();
    fromRadioChar = MockBluetoothCharacteristic();
    fromNumChar = MockBluetoothCharacteristic();
    toRadioChar = MockBluetoothCharacteristic();

    when(() => mockDevice.connect(license: any(named: 'license')))
        .thenAnswer((_) async {});
    when(() => mockDevice.requestMtu(any()))
        .thenAnswer((_) async => 512);
    when(() => mockDevice.discoverServices())
        .thenAnswer((_) async => [mockService]);

    when(() => mockService.serviceUuid)
        .thenReturn(Guid(BleRepository.meshServiceUuid));
    when(() => mockService.characteristics)
        .thenReturn([fromRadioChar, fromNumChar, toRadioChar]);

    when(() => fromRadioChar.characteristicUuid)
        .thenReturn(Guid('2c55e69e-4993-11ed-b878-0242ac120002'));

    when(() => fromNumChar.characteristicUuid)
        .thenReturn(Guid('ed9da18c-a800-4f66-a670-aa7547e34453'));
    when(() => fromNumChar.setNotifyValue(any()))
        .thenAnswer((_) async => true);
        
    // By default, no notifications
    when(() => fromNumChar.onValueReceived)
        .thenAnswer((_) => const Stream.empty());

    when(() => fromRadioChar.read())
        .thenAnswer((_) async => <int>[]);

    when(() => toRadioChar.characteristicUuid)
        .thenReturn(Guid('f75c76d2-129e-4dad-a1dd-7866124401e7'));
    when(() => toRadioChar.write(any(), withoutResponse: any(named: 'withoutResponse')))
        .thenAnswer((_) async {});
  });

  group('BleRepository Meshtastic Handshake', () {
    test('connect performs handshake: negotiates MTU, discovers services, and sends want_config_id', () async {
      await bleRepository.connect(mockDevice);

      verify(() => mockDevice.connect(license: License.free)).called(1);
      verify(() => mockDevice.requestMtu(512)).called(1);
      verify(() => mockDevice.discoverServices()).called(1);

      // Verify FromNum characteristic is subscribed to correctly
      verify(() => fromNumChar.setNotifyValue(true)).called(1);

      // Verify the blind read occurred
      verify(() => fromRadioChar.read()).called(greaterThanOrEqualTo(1));

      // Verify ToRadio characteristic receives the want_config_id protobuf 
      final captured = verify(() => toRadioChar.write(captureAny(), withoutResponse: false)).captured;
      expect(captured.isNotEmpty, isTrue, reason: 'Should write to ToRadio characteristic');

      final toRadioBytes = captured.first as List<int>;
      final toRadio = ToRadio.fromBuffer(toRadioBytes);
      expect(toRadio.wantConfigId, isNonZero, reason: 'ToRadio should contain a non-zero wantConfigId');
    });

    test('incomingMessages stream emits FromRadio when fromNum notifies', () async {
      final mockFromNumStream = Stream.fromIterable([<int>[1]]);
      when(() => fromNumChar.onValueReceived).thenAnswer((_) => mockFromNumStream);

      // Create a dummy FromRadio packet
      final msg = FromRadio(id: 12345);
      final msgBytes = msg.writeToBuffer();

      int readCount = 0;
      when(() => fromRadioChar.read()).thenAnswer((_) async {
        readCount++;
        // First read: the blind read during connect() returns empty
        if (readCount == 1) return <int>[];
        // Second read: triggered by fromNum stream. Returns msgBytes.
        if (readCount == 2) return msgBytes;
        // Third read: breaks the loop
        return <int>[];
      });

      // Start listening to the exposed stream
      final events = <FromRadio>[];
      bleRepository.incomingMessages.listen(events.add);

      await bleRepository.connect(mockDevice);
      
      // Wait for stream to process
      await Future.delayed(Duration.zero);
      
      expect(events.length, 1);
      expect(events.first.id, 12345);
      // Called once for initial block reading, and twice for the value received loop
      verify(() => fromRadioChar.read()).called(3);
    });
  });

  group('BleRepository out-bound ToRadio messages', () {
    test('sendToRadio throws exception if not connected to device', () async {
      final msg = ToRadio(wantConfigId: 123);
      expect(
        () => bleRepository.sendToRadio(msg),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Not connected to a device'))),
      );
    });

    test('sendToRadio writes buffer to toRadio characteristic when connected', () async {
      when(() => fromNumChar.onValueReceived).thenAnswer((_) => const Stream.empty());
      when(() => fromRadioChar.read()).thenAnswer((_) async => <int>[]);
      
      // Connect first to initialize the characteristics
      await bleRepository.connect(mockDevice);
      
      clearInteractions(toRadioChar);
      
      final msg = ToRadio(wantConfigId: 123);
      await bleRepository.sendToRadio(msg);

      // Verify that write was called on toRadio char with the message buffer
      verify(() => toRadioChar.write(
        msg.writeToBuffer(), 
        withoutResponse: false
      )).called(1);
    });
  });
}
