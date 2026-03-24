import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:beacon/core/proto/gen/meshtastic/mesh.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/portnums.pbenum.dart';
import 'package:beacon/core/proto/gen/meshtastic/admin.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/config.pb.dart';
import 'package:beacon/features/ble/data/repositories/ble_repository.dart';
import 'package:beacon/data/providers/ble_providers.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class MockBleRepository extends Mock implements BleRepository {}

void main() {
  late ProviderContainer container;
  late MockBleRepository mockBleRepo;
  late StreamController<FromRadio> incomingMessagesController;

  setUpAll(() {
    registerFallbackValue(ToRadio());
  });

  setUp(() {
    mockBleRepo = MockBleRepository();
    incomingMessagesController = StreamController<FromRadio>.broadcast();

    when(() => mockBleRepo.incomingMessages)
        .thenAnswer((_) => incomingMessagesController.stream);
        
    when(() => mockBleRepo.sendToRadio(any())).thenAnswer((_) async {});
    
    container = ProviderContainer(
      overrides: [
        bleRepositoryProvider.overrideWithValue(mockBleRepo),
      ],
    );
    
    // Initialize the service so it listens to stream
    container.read(settingsServiceProvider);
  });

  tearDown(() {
    incomingMessagesController.close();
    container.dispose();
  });

  group('SettingsService AdminMessage Handling', () {
    test('requestConfig encapsulates request into ToRadio and sends', () async {
      final service = container.read(settingsServiceProvider);
      
      await service.requestConfig(AdminMessage_ConfigType.LORA_CONFIG);
      
      final captured = verify(() => mockBleRepo.sendToRadio(captureAny())).captured;
      expect(captured.isNotEmpty, isTrue);
      
      final toRadio = captured.first as ToRadio;
      expect(toRadio.hasPacket(), isTrue);
      
      final meshPacket = toRadio.packet;
      expect(meshPacket.hasDecoded(), isTrue);
      expect(meshPacket.decoded.portnum, PortNum.ADMIN_APP);
      
      final adminMsg = AdminMessage.fromBuffer(meshPacket.decoded.payload);
      expect(adminMsg.hasGetConfigRequest(), isTrue);
      expect(adminMsg.getConfigRequest, AdminMessage_ConfigType.LORA_CONFIG);
    });

    test('Receiving FromRadio with get_config_response updates the correct provider', () async {
      final loraConfig = Config_LoRaConfig(
        region: Config_LoRaConfig_RegionCode.US,
        hopLimit: 3,
      );
      
      final config = Config(lora: loraConfig);
      
      final adminMsg = AdminMessage(
        getConfigResponse: config,
      );
      
      final data = Data(
        portnum: PortNum.ADMIN_APP,
        payload: adminMsg.writeToBuffer(),
      );
      
      final meshPacket = MeshPacket(
        decoded: data,
      );
      
      final fromRadioMsg = FromRadio(
        packet: meshPacket,
      );
      
      incomingMessagesController.add(fromRadioMsg);
      await Future.delayed(Duration.zero);
      
      final currentConfigHolder = container.read(deviceConfigProvider);
      expect(currentConfigHolder?.lora.region, Config_LoRaConfig_RegionCode.US);
      expect(currentConfigHolder?.lora.hopLimit, 3);
    });
    
    test('setConfig wraps config in AdminMessage and sends over BLE', () async {
      final service = container.read(settingsServiceProvider);
      
      final loraConfig = Config_LoRaConfig(
        region: Config_LoRaConfig_RegionCode.EU_868,
      );
      final config = Config(lora: loraConfig);
      
      await service.setConfig(config);
      
      final captured = verify(() => mockBleRepo.sendToRadio(captureAny())).captured;
      final toRadio = captured.first as ToRadio;
      final meshPacket = toRadio.packet;
      final adminMsg = AdminMessage.fromBuffer(meshPacket.decoded.payload);
      
      expect(adminMsg.hasSetConfig(), isTrue);
      expect(adminMsg.setConfig.lora.region, Config_LoRaConfig_RegionCode.EU_868);
    });
  });
}
