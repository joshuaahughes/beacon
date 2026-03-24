import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:beacon/core/proto/gen/meshtastic/mesh.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';
import 'package:beacon/features/settings/presentation/user_config_screen.dart';

class MockSettingsService extends Mock implements SettingsService {}

class InitialNodeUserNotifier extends NodeUserNotifier {
  final User? initialUser;
  InitialNodeUserNotifier(this.initialUser);

  @override
  User? build() => initialUser;
}

void main() {
  late MockSettingsService mockSettingsService;

  setUpAll(() {
    registerFallbackValue(User());
  });

  setUp(() {
    mockSettingsService = MockSettingsService();
    when(() => mockSettingsService.setOwner(any())).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest({User? initialUser}) {
    return ProviderScope(
      overrides: [
        settingsServiceProvider.overrideWithValue(mockSettingsService),
        nodeUserProvider.overrideWith(() => InitialNodeUserNotifier(initialUser)),
      ],
      child: const MaterialApp(
        home: UserConfigScreen(),
      ),
    );
  }

  group('UserConfigScreen Tests', () {
    testWidgets('Populates form fields with current user state', (WidgetTester tester) async {
      final user = User(
        longName: 'Test Node',
        shortName: 'TN',
      );

      await tester.pumpWidget(createWidgetUnderTest(initialUser: user));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Test Node'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'TN'), findsOneWidget);
    });

    testWidgets('Tapping save calls setOwner with updated user info', (WidgetTester tester) async {
      final user = User(
        longName: 'Old Name',
        shortName: 'ON',
      );

      await tester.pumpWidget(createWidgetUnderTest(initialUser: user));
      await tester.pumpAndSettle();

      // Change names
      await tester.enterText(find.byType(TextField).first, 'New Name');
      await tester.enterText(find.byType(TextField).last, 'NN');
      await tester.pumpAndSettle();

      // Tap save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final captured = verify(() => mockSettingsService.setOwner(captureAny())).captured;
      final savedUser = captured.first as User;
      expect(savedUser.longName, 'New Name');
      expect(savedUser.shortName, 'NN');
    });
  });
}
