import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/module_config.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/admin.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class NeighborInfoConfigScreen extends ConsumerStatefulWidget {
  const NeighborInfoConfigScreen({super.key});

  @override
  ConsumerState<NeighborInfoConfigScreen> createState() =>
      _NeighborInfoConfigScreenState();
}

class _NeighborInfoConfigScreenState extends ConsumerState<NeighborInfoConfigScreen> {
  final _updateIntervalController = TextEditingController();

  bool _enabled = false;
  bool _transmitOverLora = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsServiceProvider).requestModuleConfig(
        AdminMessage_ModuleConfigType.NEIGHBORINFO_CONFIG,
      );
      final config = ref.read(moduleConfigProvider);
      if (config != null && config.hasNeighborInfo()) {
        _loadFromConfig(config.neighborInfo);
        setState(() {});
      }
    });
  }

  void _loadFromConfig(ModuleConfig_NeighborInfoConfig ni) {
    _enabled = ni.enabled;
    _updateIntervalController.text = ni.updateInterval.toString();
    _transmitOverLora = ni.transmitOverLora;
  }

  @override
  void dispose() {
    _updateIntervalController.dispose();
    super.dispose();
  }

  void _save() {
    final niConfig = ModuleConfig_NeighborInfoConfig(
      enabled: _enabled,
      updateInterval: int.tryParse(_updateIntervalController.text) ?? 0,
      transmitOverLora: _transmitOverLora,
    );

    final config = ModuleConfig(neighborInfo: niConfig);
    ref.read(settingsServiceProvider).setModuleConfig(config);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved Neighbor Info Config')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ModuleConfig?>(moduleConfigProvider, (previous, next) {
      if (next != null && next.hasNeighborInfo()) {
        _loadFromConfig(next.neighborInfo);
        setState(() {});
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Neighbor Info Config')),
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
              helperText: 'How often to update neighbor info',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Transmit over LoRa'),
            value: _transmitOverLora,
            onChanged: (val) => setState(() => _transmitOverLora = val),
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
