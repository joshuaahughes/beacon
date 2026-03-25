import 'package:flutter/material.dart';
import 'package:beacon/features/settings/presentation/lora_config_screen.dart';
import 'package:beacon/features/settings/presentation/device_config_screen.dart';
import 'package:beacon/features/settings/presentation/position_config_screen.dart';
import 'package:beacon/features/settings/presentation/user_config_screen.dart';
import 'package:beacon/features/settings/presentation/power_config_screen.dart';
import 'package:beacon/features/settings/presentation/network_config_screen.dart';
import 'package:beacon/features/settings/presentation/display_config_screen.dart';
import 'package:beacon/features/settings/presentation/bluetooth_config_screen.dart';
import 'package:beacon/features/settings/presentation/security_config_screen.dart';

class RadioConfigHubScreen extends StatelessWidget {
  const RadioConfigHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Radio Configuration')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('User Config'),
            subtitle: const Text('Node Name, Initials'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UserConfigScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_input_antenna),
            title: const Text('LoRa Config'),
            subtitle: const Text('Region, Hop Limit, TX Power'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoraConfigScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.router),
            title: const Text('Device Config'),
            subtitle: const Text('Role, LED Heartbeat'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DeviceConfigScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.place),
            title: const Text('Position Config'),
            subtitle: const Text('Broadcast Interval, Smart Mode'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PositionConfigScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.battery_charging_full),
            title: const Text('Power Config'),
            subtitle: const Text('Sleep settings, Battery, ADC'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PowerConfigScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.wifi),
            title: const Text('Network Config'),
            subtitle: const Text('WiFi, Ethernet, IP Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NetworkConfigScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.screen_lock_landscape),
            title: const Text('Display Config'),
            subtitle: const Text('Screen, Units, OLED Type'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DisplayConfigScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bluetooth),
            title: const Text('Bluetooth Config'),
            subtitle: const Text('Enabled, Pairing Mode, PIN'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BluetoothConfigScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Security Config'),
            subtitle: const Text('Keys, Managed, Serial Console'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SecurityConfigScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
