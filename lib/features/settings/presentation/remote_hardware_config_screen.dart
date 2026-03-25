import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/module_config.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/admin.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class RemoteHardwareConfigScreen extends ConsumerStatefulWidget {
  const RemoteHardwareConfigScreen({super.key});

  @override
  ConsumerState<RemoteHardwareConfigScreen> createState() =>
      _RemoteHardwareConfigScreenState();
}

class _RemoteHardwareConfigScreenState
    extends ConsumerState<RemoteHardwareConfigScreen> {
  bool _enabled = false;
  bool _allowUndefinedPinAccess = false;
  List<RemoteHardwarePin> _availablePins = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsServiceProvider).requestModuleConfig(
        AdminMessage_ModuleConfigType.REMOTEHARDWARE_CONFIG,
      );
      final config = ref.read(moduleConfigProvider);
      if (config != null && config.hasRemoteHardware()) {
        _loadFromConfig(config.remoteHardware);
        setState(() {});
      }
    });
  }

  void _loadFromConfig(ModuleConfig_RemoteHardwareConfig rh) {
    _enabled = rh.enabled;
    _allowUndefinedPinAccess = rh.allowUndefinedPinAccess;
    _availablePins = List.from(rh.availablePins);
  }

  void _save() {
    final rhConfig = ModuleConfig_RemoteHardwareConfig(
      enabled: _enabled,
      allowUndefinedPinAccess: _allowUndefinedPinAccess,
      availablePins: _availablePins,
    );

    final config = ModuleConfig(remoteHardware: rhConfig);
    ref.read(settingsServiceProvider).setModuleConfig(config);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved Remote Hardware Config')));
    Navigator.of(context).pop();
  }

  void _addPin() {
    setState(() {
      _availablePins.add(
        RemoteHardwarePin(
          gpioPin: 0,
          name: 'New Pin',
          type: RemoteHardwarePinType.DIGITAL_READ,
        ),
      );
    });
  }

  void _removePin(int index) {
    setState(() {
      _availablePins.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ModuleConfig?>(moduleConfigProvider, (previous, next) {
      if (next != null && next.hasRemoteHardware()) {
        _loadFromConfig(next.remoteHardware);
        setState(() {});
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Remote Hardware Config')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Enabled'),
            value: _enabled,
            onChanged: (val) => setState(() => _enabled = val),
          ),
          SwitchListTile(
            title: const Text('Allow Undefined Pin Access'),
            subtitle: const Text('Dangerous! Allows access to any GPIO'),
            value: _allowUndefinedPinAccess,
            onChanged: (val) => setState(() => _allowUndefinedPinAccess = val),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Pins',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(onPressed: _addPin, icon: const Icon(Icons.add)),
            ],
          ),
          ..._availablePins.asMap().entries.map((entry) {
            final index = entry.key;
            final pin = entry.value;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: pin.name,
                            decoration: const InputDecoration(labelText: 'Pin Name'),
                            onChanged: (val) => pin.name = val,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removePin(index),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: pin.gpioPin.toString(),
                            decoration: const InputDecoration(labelText: 'GPIO Pin'),
                            keyboardType: TextInputType.number,
                            onChanged: (val) =>
                                pin.gpioPin = int.tryParse(val) ?? 0,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<RemoteHardwarePinType>(
                            value: pin.type,
                            decoration: const InputDecoration(labelText: 'Type'),
                            items: RemoteHardwarePinType.values.map((t) {
                              return DropdownMenuItem(value: t, child: Text(t.name));
                            }).toList(),
                            onChanged: (val) => setState(() => pin.type = val!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
