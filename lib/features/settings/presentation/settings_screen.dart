import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/features/ble/presentation/bluetooth_scanning_screen.dart';
import 'package:beacon/data/providers/ble_providers.dart';
import 'package:beacon/features/settings/presentation/radio_config_hub_screen.dart';
import 'package:beacon/features/settings/presentation/module_config_hub_screen.dart';
import 'package:beacon/core/presentation/widgets/brand_logo.dart';
import 'package:beacon/core/presentation/widgets/branded_app_bar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectedDevice = ref.watch(connectedDeviceProvider);
    final deviceName = connectedDevice?.platformName ?? 'None connected';

    return Scaffold(
      appBar: const BrandedAppBar(title: 'Settings'),
      body: ListView(
        children: [
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                const BrandLogo(size: 80),
                const SizedBox(height: 16),
                Text(
                  'Beacon',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                ),
                const Text('Version 1.0.0'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Application'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: const Text('System Default'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('Language'),
            subtitle: const Text('English'),
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader(context, 'Device Connection'),
          ListTile(
            leading: const Icon(Icons.bluetooth_outlined),
            title: const Text('Bluetooth Device'),
            subtitle: Text(deviceName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const BluetoothScanningScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Radio Configuration'),
            subtitle: const Text('Node, LoRa, Power, Display'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RadioConfigHubScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.extension_outlined),
            title: const Text('Module Configuration'),
            subtitle: const Text('MQTT, Telemetry, Sensors, TAK'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ModuleConfigHubScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outlined),
            title: const Text('About'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
