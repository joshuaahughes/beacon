import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:beacon/core/proto/gen/meshtastic/config.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';
import 'package:beacon/features/settings/presentation/position_config_screen.dart';

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
        home: PositionConfigScreen(),
      ),
    );
  }

  group('PositionConfigScreen Tests', () {
    testWidgets('Populates form fields with current position config state', (WidgetTester tester) async {
      final config = Config(
        position: Config_PositionConfig(
          positionBroadcastSecs: 600,
          positionBroadcastSmartEnabled: true,
          fixedPosition: false,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(initialConfig: config));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, '600'), findsOneWidget);
      final switches = find.byType(Switch);
      expect(tester.widget<Switch>(switches.first).value, isTrue); // smart enabled
    });

    testWidgets('Tapping save calls setConfig with updated position config', (WidgetTester tester) async {
      final config = Config(
        position: Config_PositionConfig(
          positionBroadcastSecs: 900,
          positionBroadcastSmartEnabled: false,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(initialConfig: config));
      await tester.pumpAndSettle();

      // Change broadcast secs
      await tester.enterText(find.byType(TextField).first, '300');
      await tester.pumpAndSettle();

      // Toggle smart mode
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      // Tap save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final captured = verify(() => mockSettingsService.setConfig(captureAny())).captured;
      final savedConfig = captured.first as Config;
      expect(savedConfig.position.positionBroadcastSecs, 300);
      expect(savedConfig.position.positionBroadcastSmartEnabled, isTrue);
    });
  });
}
