import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/module_config.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/admin.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class ExternalNotificationConfigScreen extends ConsumerStatefulWidget {
  const ExternalNotificationConfigScreen({super.key});

  @override
  ConsumerState<ExternalNotificationConfigScreen> createState() =>
      _ExternalNotificationConfigScreenState();
}

class _ExternalNotificationConfigScreenState
    extends ConsumerState<ExternalNotificationConfigScreen> {
  final _outputMsController = TextEditingController();
  final _outputPinController = TextEditingController();
  final _outputVibraController = TextEditingController();
  final _outputBuzzerController = TextEditingController();
  final _nagTimeoutController = TextEditingController();

  bool _enabled = false;
  bool _activeHigh = false;
  bool _alertMessage = false;
  bool _alertBell = false;
  bool _usePwm = false;
  bool _alertMessageVibra = false;
  bool _alertMessageBuzzer = false;
  bool _alertBellVibra = false;
  bool _alertBellBuzzer = false;
  bool _useI2sAsBuzzer = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsServiceProvider).requestModuleConfig(
        AdminMessage_ModuleConfigType.EXTNOTIF_CONFIG,
      );
      final config = ref.read(moduleConfigProvider);
      if (config != null && config.hasExternalNotification()) {
        _loadFromConfig(config.externalNotification);
        setState(() {});
      }
    });
  }

  void _loadFromConfig(ModuleConfig_ExternalNotificationConfig en) {
    _enabled = en.enabled;
    _outputMsController.text = en.outputMs.toString();
    _outputPinController.text = en.output.toString();
    _activeHigh = en.active;
    _alertMessage = en.alertMessage;
    _alertBell = en.alertBell;
    _usePwm = en.usePwm;
    _outputVibraController.text = en.outputVibra.toString();
    _outputBuzzerController.text = en.outputBuzzer.toString();
    _alertMessageVibra = en.alertMessageVibra;
    _alertMessageBuzzer = en.alertMessageBuzzer;
    _alertBellVibra = en.alertBellVibra;
    _alertBellBuzzer = en.alertBellBuzzer;
    _nagTimeoutController.text = en.nagTimeout.toString();
    _useI2sAsBuzzer = en.useI2sAsBuzzer;
  }

  @override
  void dispose() {
    _outputMsController.dispose();
    _outputPinController.dispose();
    _outputVibraController.dispose();
    _outputBuzzerController.dispose();
    _nagTimeoutController.dispose();
    super.dispose();
  }

  void _save() {
    final enConfig = ModuleConfig_ExternalNotificationConfig(
      enabled: _enabled,
      outputMs: int.tryParse(_outputMsController.text) ?? 0,
      output: int.tryParse(_outputPinController.text) ?? 0,
      active: _activeHigh,
      alertMessage: _alertMessage,
      alertBell: _alertBell,
      usePwm: _usePwm,
      outputVibra: int.tryParse(_outputVibraController.text) ?? 0,
      outputBuzzer: int.tryParse(_outputBuzzerController.text) ?? 0,
      alertMessageVibra: _alertMessageVibra,
      alertMessageBuzzer: _alertMessageBuzzer,
      alertBellVibra: _alertBellVibra,
      alertBellBuzzer: _alertBellBuzzer,
      nagTimeout: int.tryParse(_nagTimeoutController.text) ?? 0,
      useI2sAsBuzzer: _useI2sAsBuzzer,
    );

    final config = ModuleConfig(externalNotification: enConfig);
    ref.read(settingsServiceProvider).setModuleConfig(config);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved External Notification Config')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ModuleConfig?>(moduleConfigProvider, (previous, next) {
      if (next != null && next.hasExternalNotification()) {
        _loadFromConfig(next.externalNotification);
        setState(() {});
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('External Notification')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Enabled'),
            value: _enabled,
            onChanged: (val) => setState(() => _enabled = val),
          ),
          const Divider(),
          TextField(
            controller: _outputPinController,
            decoration: const InputDecoration(
              labelText: 'Output Pin',
              helperText: 'GPIO pin for notification',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _outputMsController,
            decoration: const InputDecoration(
              labelText: 'Output Duration (ms)',
              helperText: 'How long to keep the output on',
            ),
            keyboardType: TextInputType.number,
          ),
          SwitchListTile(
            title: const Text('Active High'),
            subtitle: const Text('False means active low'),
            value: _activeHigh,
            onChanged: (val) => setState(() => _activeHigh = val),
          ),
          const Divider(),
          const Text('Triggers', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Alert on Message'),
            value: _alertMessage,
            onChanged: (val) => setState(() => _alertMessage = val),
          ),
          SwitchListTile(
            title: const Text('Alert on Bell'),
            value: _alertBell,
            onChanged: (val) => setState(() => _alertBell = val),
          ),
          const Divider(),
          const Text('Advanced', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Use PWM'),
            subtitle: const Text('Uses device.buzzer_gpio'),
            value: _usePwm,
            onChanged: (val) => setState(() => _usePwm = val),
          ),
          TextField(
            controller: _outputVibraController,
            decoration: const InputDecoration(labelText: 'Vibra Motor Pin'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _outputBuzzerController,
            decoration: const InputDecoration(labelText: 'Buzzer Pin'),
            keyboardType: TextInputType.number,
          ),
          SwitchListTile(
            title: const Text('Alert Message (Vibra)'),
            value: _alertMessageVibra,
            onChanged: (val) => setState(() => _alertMessageVibra = val),
          ),
          SwitchListTile(
            title: const Text('Alert Message (Buzzer)'),
            value: _alertMessageBuzzer,
            onChanged: (val) => setState(() => _alertMessageBuzzer = val),
          ),
          SwitchListTile(
            title: const Text('Alert Bell (Vibra)'),
            value: _alertBellVibra,
            onChanged: (val) => setState(() => _alertBellVibra = val),
          ),
          SwitchListTile(
            title: const Text('Alert Bell (Buzzer)'),
            value: _alertBellBuzzer,
            onChanged: (val) => setState(() => _alertBellBuzzer = val),
          ),
          TextField(
            controller: _nagTimeoutController,
            decoration: const InputDecoration(
              labelText: 'Nag Timeout (seconds)',
              helperText: '0 to disable repeat',
            ),
            keyboardType: TextInputType.number,
          ),
          SwitchListTile(
            title: const Text('Use I2S as Buzzer'),
            value: _useI2sAsBuzzer,
            onChanged: (val) => setState(() => _useI2sAsBuzzer = val),
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
