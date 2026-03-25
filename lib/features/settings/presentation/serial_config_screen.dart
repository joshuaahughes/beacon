import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/module_config.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/admin.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class SerialConfigScreen extends ConsumerStatefulWidget {
  const SerialConfigScreen({super.key});

  @override
  ConsumerState<SerialConfigScreen> createState() => _SerialConfigScreenState();
}

class _SerialConfigScreenState extends ConsumerState<SerialConfigScreen> {
  final _rxdController = TextEditingController();
  final _txdController = TextEditingController();
  final _timeoutController = TextEditingController();

  bool _enabled = false;
  bool _echo = false;
  bool _overrideConsoleSerialPort = false;
  ModuleConfig_SerialConfig_Serial_Baud _baud =
      ModuleConfig_SerialConfig_Serial_Baud.BAUD_DEFAULT;
  ModuleConfig_SerialConfig_Serial_Mode _mode =
      ModuleConfig_SerialConfig_Serial_Mode.DEFAULT;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsServiceProvider).requestModuleConfig(
        AdminMessage_ModuleConfigType.SERIAL_CONFIG,
      );
      final config = ref.read(moduleConfigProvider);
      if (config != null && config.hasSerial()) {
        _loadFromConfig(config.serial);
        setState(() {});
      }
    });
  }

  void _loadFromConfig(ModuleConfig_SerialConfig serial) {
    _enabled = serial.enabled;
    _echo = serial.echo;
    _rxdController.text = serial.rxd.toString();
    _txdController.text = serial.txd.toString();
    _baud = serial.baud;
    _timeoutController.text = serial.timeout.toString();
    _mode = serial.mode;
    _overrideConsoleSerialPort = serial.overrideConsoleSerialPort;
  }

  @override
  void dispose() {
    _rxdController.dispose();
    _txdController.dispose();
    _timeoutController.dispose();
    super.dispose();
  }

  void _save() {
    final serialConfig = ModuleConfig_SerialConfig(
      enabled: _enabled,
      echo: _echo,
      rxd: int.tryParse(_rxdController.text) ?? 0,
      txd: int.tryParse(_txdController.text) ?? 0,
      baud: _baud,
      timeout: int.tryParse(_timeoutController.text) ?? 0,
      mode: _mode,
      overrideConsoleSerialPort: _overrideConsoleSerialPort,
    );

    final config = ModuleConfig(serial: serialConfig);
    ref.read(settingsServiceProvider).setModuleConfig(config);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved Serial Config')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ModuleConfig?>(moduleConfigProvider, (previous, next) {
      if (next != null && next.hasSerial()) {
        _loadFromConfig(next.serial);
        setState(() {});
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Serial Config')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Enabled'),
            value: _enabled,
            onChanged: (val) => setState(() => _enabled = val),
          ),
          SwitchListTile(
            title: const Text('Echo'),
            value: _echo,
            onChanged: (val) => setState(() => _echo = val),
          ),
          const Divider(),
          TextField(
            controller: _rxdController,
            decoration: const InputDecoration(
              labelText: 'RX Pin',
              helperText: 'GPIO pin number',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _txdController,
            decoration: const InputDecoration(
              labelText: 'TX Pin',
              helperText: 'GPIO pin number',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ModuleConfig_SerialConfig_Serial_Baud>(
            value: _baud,
            decoration: const InputDecoration(labelText: 'Baud Rate'),
            items: ModuleConfig_SerialConfig_Serial_Baud.values.map((b) {
              return DropdownMenuItem(value: b, child: Text(b.name));
            }).toList(),
            onChanged: (val) => setState(() => _baud = val!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _timeoutController,
            decoration: const InputDecoration(labelText: 'Timeout (ms)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ModuleConfig_SerialConfig_Serial_Mode>(
            value: _mode,
            decoration: const InputDecoration(labelText: 'Mode'),
            items: ModuleConfig_SerialConfig_Serial_Mode.values.map((m) {
              return DropdownMenuItem(value: m, child: Text(m.name));
            }).toList(),
            onChanged: (val) => setState(() => _mode = val!),
          ),
          SwitchListTile(
            title: const Text('Override Console Serial Port'),
            value: _overrideConsoleSerialPort,
            onChanged: (val) => setState(() => _overrideConsoleSerialPort = val),
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
