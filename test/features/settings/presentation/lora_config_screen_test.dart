import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:beacon/core/proto/gen/meshtastic/config.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';
import 'package:beacon/features/settings/presentation/lora_config_screen.dart';

class MockSettingsService extends Mock implements SettingsService {}

class InitialDeviceConfigNotifier extends DeviceConfigNotifier {
  final Config? initialConfig;
  InitialDeviceConfigNotifier(this.initialConfig);

  @override
  Config? build() => initialConfig;
}

void main() {
  late MockSettingsService mockSettingsService;

  setUpAll(() {
    registerFallbackValue(Config());
  });

  setUp(() {
    mockSettingsService = MockSettingsService();
    when(() => mockSettingsService.setConfig(any())).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest({Config? initialConfig}) {
    return ProviderScope(
      overrides: [
        settingsServiceProvider.overrideWithValue(mockSettingsService),
        deviceConfigProvider.overrideWith(() => InitialDeviceConfigNotifier(initialConfig)),
      ],
      child: const MaterialApp(
        home: LoraConfigScreen(),
      ),
    );
  }

  group('LoraConfigScreen Tests', () {
    testWidgets('Populates form fields with current config state', (WidgetTester tester) async {
      final config = Config(
        lora: Config_LoRaConfig(
          region: Config_LoRaConfig_RegionCode.US,
          hopLimit: 5,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(initialConfig: config));
      await tester.pumpAndSettle();

      // Find the dropdown or text displaying the region
      expect(find.text('US'), findsOneWidget);
      
      // Find the hop limit textfield
      expect(find.widgetWithText(TextField, '5'), findsOneWidget);
    });

    testWidgets('Tapping save calls setConfig on SettingsService', (WidgetTester tester) async {
      final config = Config(
        lora: Config_LoRaConfig(
          region: Config_LoRaConfig_RegionCode.US,
          hopLimit: 3,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(initialConfig: config));
      await tester.pumpAndSettle();

      // Enter a new hop limit
      await tester.enterText(find.byType(TextField).first, '7');
      await tester.pumpAndSettle();

      // Tap the save button
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final captured = verify(() => mockSettingsService.setConfig(captureAny())).captured;
      expect(captured.isNotEmpty, isTrue);

      final savedConfig = captured.first as Config;
      expect(savedConfig.hasLora(), isTrue);
      expect(savedConfig.lora.hopLimit, 7);
    });
  });
}
