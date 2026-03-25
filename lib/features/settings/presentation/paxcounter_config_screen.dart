import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/module_config.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/admin.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class PaxcounterConfigScreen extends ConsumerStatefulWidget {
  const PaxcounterConfigScreen({super.key});

  @override
  ConsumerState<PaxcounterConfigScreen> createState() => _PaxcounterConfigScreenState();
}

class _PaxcounterConfigScreenState extends ConsumerState<PaxcounterConfigScreen> {
  final _updateIntervalController = TextEditingController();
  final _wifiThresholdController = TextEditingController();
  final _bleThresholdController = TextEditingController();

  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsServiceProvider).requestModuleConfig(
        AdminMessage_ModuleConfigType.PAXCOUNTER_CONFIG,
      );
      final config = ref.read(moduleConfigProvider);
      if (config != null && config.hasPaxcounter()) {
        _loadFromConfig(config.paxcounter);
        setState(() {});
      }
    });
  }

  void _loadFromConfig(ModuleConfig_PaxcounterConfig pc) {
    _enabled = pc.enabled;
    _updateIntervalController.text = pc.paxcounterUpdateInterval.toString();
    _wifiThresholdController.text = pc.wifiThreshold.toString();
    _bleThresholdController.text = pc.bleThreshold.toString();
  }

  @override
  void dispose() {
    _updateIntervalController.dispose();
    _wifiThresholdController.dispose();
    _bleThresholdController.dispose();
    super.dispose();
  }

  void _save() {
    final pcConfig = ModuleConfig_PaxcounterConfig(
      enabled: _enabled,
      paxcounterUpdateInterval: int.tryParse(_updateIntervalController.text) ?? 0,
      wifiThreshold: int.tryParse(_wifiThresholdController.text) ?? 0,
      bleThreshold: int.tryParse(_bleThresholdController.text) ?? 0,
    );

    final config = ModuleConfig(paxcounter: pcConfig);
    ref.read(settingsServiceProvider).setModuleConfig(config);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved Paxcounter Config')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ModuleConfig?>(moduleConfigProvider, (previous, next) {
      if (next != null && next.hasPaxcounter()) {
        _loadFromConfig(next.paxcounter);
        setState(() {});
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Paxcounter Config')),
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
            controller: _updateIntervalController,
            decoration: const InputDecoration(
              labelText: 'Update Interval (seconds)',
              helperText: 'How often to update counts',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _wifiThresholdController,
            decoration: const InputDecoration(
              labelText: 'WiFi Threshold',
              helperText: 'Signal strength threshold for WiFi devices',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bleThresholdController,
            decoration: const InputDecoration(
              labelText: 'BLE Threshold',
              helperText: 'Signal strength threshold for BLE devices',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
