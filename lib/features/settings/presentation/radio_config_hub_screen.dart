import 'package:flutter/material.dart';
import 'package:beacon/features/settings/presentation/lora_config_screen.dart';
import 'package:beacon/features/settings/presentation/device_config_screen.dart';
import 'package:beacon/features/settings/presentation/position_config_screen.dart';
import 'package:beacon/features/settings/presentation/user_config_screen.dart';

class RadioConfigHubScreen extends StatelessWidget {
  const RadioConfigHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Radio Configuration'),
      ),
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
          const ListTile(
            leading: Icon(Icons.battery_charging_full),
            title: Text('Power Config'),
            subtitle: Text('Sleep settings, Battery (Coming soon)'),
            enabled: false,
          ),
        ],
      ),
    );
  }
}
