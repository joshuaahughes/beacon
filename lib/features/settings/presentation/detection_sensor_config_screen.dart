import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/module_config.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/admin.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class DetectionSensorConfigScreen extends ConsumerStatefulWidget {
  const DetectionSensorConfigScreen({super.key});

  @override
  ConsumerState<DetectionSensorConfigScreen> createState() =>
      _DetectionSensorConfigScreenState();
}

class _DetectionSensorConfigScreenState
    extends ConsumerState<DetectionSensorConfigScreen> {
  final _nameController = TextEditingController();
  final _minimumBroadcastSecsController = TextEditingController();
  final _stateBroadcastSecsController = TextEditingController();
  final _monitorPinController = TextEditingController();

  bool _enabled = false;
  bool _sendBell = false;
  bool _usePullup = false;
  ModuleConfig_DetectionSensorConfig_TriggerType _triggerType =
      ModuleConfig_DetectionSensorConfig_TriggerType.LOGIC_LOW;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsServiceProvider).requestModuleConfig(
        AdminMessage_ModuleConfigType.DETECTIONSENSOR_CONFIG,
      );
      final config = ref.read(moduleConfigProvider);
      if (config != null && config.hasDetectionSensor()) {
        _loadFromConfig(config.detectionSensor);
        setState(() {});
      }
    });
  }

  void _loadFromConfig(ModuleConfig_DetectionSensorConfig ds) {
    _enabled = ds.enabled;
    _nameController.text = ds.name;
    _minimumBroadcastSecsController.text = ds.minimumBroadcastSecs.toString();
    _stateBroadcastSecsController.text = ds.stateBroadcastSecs.toString();
    _monitorPinController.text = ds.monitorPin.toString();
    _sendBell = ds.sendBell;
    _usePullup = ds.usePullup;
    _triggerType = ds.detectionTriggerType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minimumBroadcastSecsController.dispose();
    _stateBroadcastSecsController.dispose();
    _monitorPinController.dispose();
    super.dispose();
  }

  void _save() {
    final dsConfig = ModuleConfig_DetectionSensorConfig(
      enabled: _enabled,
      name: _nameController.text,
      minimumBroadcastSecs:
          int.tryParse(_minimumBroadcastSecsController.text) ?? 0,
      stateBroadcastSecs: int.tryParse(_stateBroadcastSecsController.text) ?? 0,
      monitorPin: int.tryParse(_monitorPinController.text) ?? 0,
      sendBell: _sendBell,
      usePullup: _usePullup,
      detectionTriggerType: _triggerType,
    );

    final config = ModuleConfig(detectionSensor: dsConfig);
    ref.read(settingsServiceProvider).setModuleConfig(config);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved Detection Sensor Config')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ModuleConfig?>(moduleConfigProvider, (previous, next) {
      if (next != null && next.hasDetectionSensor()) {
        _loadFromConfig(next.detectionSensor);
        setState(() {});
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Detection Sensor')),
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
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Sensor Name',
              helperText: 'e.g. Motion, Door',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _monitorPinController,
            decoration: const InputDecoration(
              labelText: 'Monitor Pin',
              helperText: 'GPIO pin to watch',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ModuleConfig_DetectionSensorConfig_TriggerType>(
            value: _triggerType,
            decoration: const InputDecoration(labelText: 'Trigger Type'),
            items: ModuleConfig_DetectionSensorConfig_TriggerType.values.map((t) {
              return DropdownMenuItem(value: t, child: Text(t.name));
            }).toList(),
            onChanged: (val) => setState(() => _triggerType = val!),
          ),
          const Divider(),
          TextField(
            controller: _minimumBroadcastSecsController,
            decoration: const InputDecoration(
              labelText: 'Minimum Broadcast Interval (s)',
              helperText: 'Throttles consecutive triggers',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _stateBroadcastSecsController,
            decoration: const InputDecoration(
              labelText: 'State Broadcast Interval (s)',
              helperText: 'Heartbeat interval (0 to disable)',
            ),
            keyboardType: TextInputType.number,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Send Bell'),
            value: _sendBell,
            onChanged: (val) => setState(() => _sendBell = val),
          ),
          SwitchListTile(
            title: const Text('Use Pullup'),
            value: _usePullup,
            onChanged: (val) => setState(() => _usePullup = val),
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
