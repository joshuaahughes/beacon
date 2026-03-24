import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/config.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class DeviceConfigScreen extends ConsumerStatefulWidget {
  const DeviceConfigScreen({super.key});

  @override
  ConsumerState<DeviceConfigScreen> createState() => _DeviceConfigScreenState();
}

class _DeviceConfigScreenState extends ConsumerState<DeviceConfigScreen> {
  Config_DeviceConfig_Role _selectedRole = Config_DeviceConfig_Role.CLIENT;
  bool _ledHeartbeatDisabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = ref.read(deviceConfigProvider);
      if (config != null && config.hasDevice()) {
        _selectedRole = config.device.role;
        _ledHeartbeatDisabled = config.device.ledHeartbeatDisabled;
        setState(() {});
      }
    });
  }

  void _save() {
    final deviceConfig = Config_DeviceConfig(
      role: _selectedRole,
      ledHeartbeatDisabled: _ledHeartbeatDisabled,
    );
    
    final config = Config(device: deviceConfig);
    ref.read(settingsServiceProvider).setConfig(config);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved Device Config')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Config?>(deviceConfigProvider, (previous, next) {
      if (next != null && next.hasDevice()) {
        if (previous == null) {
          _selectedRole = next.device.role;
          _ledHeartbeatDisabled = next.device.ledHeartbeatDisabled;
          setState(() {});
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Config'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<Config_DeviceConfig_Role>(
            value: _selectedRole,
            decoration: const InputDecoration(labelText: 'Device Role'),
            items: Config_DeviceConfig_Role.values.map((role) {
              return DropdownMenuItem(
                value: role,
                child: Text(role.name),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedRole = val);
              }
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Disable LED Heartbeat'),
            value: _ledHeartbeatDisabled,
            onChanged: (val) {
              setState(() => _ledHeartbeatDisabled = val);
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
