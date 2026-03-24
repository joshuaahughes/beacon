import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:beacon/core/proto/gen/meshtastic/config.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';
import 'package:beacon/features/settings/presentation/device_config_screen.dart';

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
        home: DeviceConfigScreen(),
      ),
    );
  }

  group('DeviceConfigScreen Tests', () {
    testWidgets('Populates form fields with current device config state', (WidgetTester tester) async {
      final config = Config(
        device: Config_DeviceConfig(
          role: Config_DeviceConfig_Role.ROUTER,
          ledHeartbeatDisabled: true,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(initialConfig: config));
      await tester.pumpAndSettle();

      expect(find.text('ROUTER'), findsOneWidget);
      final switchFinder = find.byType(Switch);
      expect(tester.widget<Switch>(switchFinder).value, isTrue);
    });

    testWidgets('Tapping save calls setConfig with updated device config', (WidgetTester tester) async {
      final config = Config(
        device: Config_DeviceConfig(
          role: Config_DeviceConfig_Role.CLIENT,
          ledHeartbeatDisabled: false,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(initialConfig: config));
      await tester.pumpAndSettle();

      // Change role
      await tester.tap(find.text('CLIENT'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('TRACKER').last);
      await tester.pumpAndSettle();

      // Toggle switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Tap save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final captured = verify(() => mockSettingsService.setConfig(captureAny())).captured;
      final savedConfig = captured.first as Config;
      expect(savedConfig.device.role, Config_DeviceConfig_Role.TRACKER);
      expect(savedConfig.device.ledHeartbeatDisabled, isTrue);
    });
  });
}
