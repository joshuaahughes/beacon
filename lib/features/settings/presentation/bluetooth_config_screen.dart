import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/config.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class BluetoothConfigScreen extends ConsumerStatefulWidget {
  const BluetoothConfigScreen({super.key});

  @override
  ConsumerState<BluetoothConfigScreen> createState() =>
      _BluetoothConfigScreenState();
}

class _BluetoothConfigScreenState extends ConsumerState<BluetoothConfigScreen> {
  final _fixedPinController = TextEditingController();

  bool _enabled = true;
  Config_BluetoothConfig_PairingMode _mode =
      Config_BluetoothConfig_PairingMode.RANDOM_PIN;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = ref.read(deviceConfigProvider);
      if (config != null && config.hasBluetooth()) {
        _loadFromConfig(config.bluetooth);
        setState(() {});
      }
    });
  }

  void _loadFromConfig(Config_BluetoothConfig bluetooth) {
    _enabled = bluetooth.enabled;
    _mode = bluetooth.mode;
    _fixedPinController.text = bluetooth.fixedPin.toString();
  }

  @override
  void dispose() {
    _fixedPinController.dispose();
    super.dispose();
  }

  void _save() {
    final bluetoothConfig = Config_BluetoothConfig(
      enabled: _enabled,
      mode: _mode,
      fixedPin: int.tryParse(_fixedPinController.text) ?? 0,
    );

    final config = Config(bluetooth: bluetoothConfig);
    ref.read(settingsServiceProvider).setConfig(config);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved Bluetooth Config')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Config?>(deviceConfigProvider, (previous, next) {
      if (next != null && next.hasBluetooth()) {
        _loadFromConfig(next.bluetooth);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth Config')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Bluetooth Enabled'),
            value: _enabled,
            onChanged: (val) => setState(() => _enabled = val),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Config_BluetoothConfig_PairingMode>(
            value: _mode,
            decoration: const InputDecoration(labelText: 'Pairing Mode'),
            items: Config_BluetoothConfig_PairingMode.values.map((m) {
              return DropdownMenuItem(value: m, child: Text(m.name));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _mode = val);
            },
          ),
          if (_mode == Config_BluetoothConfig_PairingMode.FIXED_PIN) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _fixedPinController,
              decoration: const InputDecoration(
                labelText: 'Fixed PIN',
                helperText: '6-digit PIN for pairing',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
