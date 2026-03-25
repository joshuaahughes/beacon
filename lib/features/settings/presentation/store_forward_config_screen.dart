import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/module_config.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/admin.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class StoreForwardConfigScreen extends ConsumerStatefulWidget {
  const StoreForwardConfigScreen({super.key});

  @override
  ConsumerState<StoreForwardConfigScreen> createState() =>
      _StoreForwardConfigScreenState();
}

class _StoreForwardConfigScreenState extends ConsumerState<StoreForwardConfigScreen> {
  final _recordsController = TextEditingController();
  final _historyReturnMaxController = TextEditingController();
  final _historyReturnWindowController = TextEditingController();

  bool _enabled = false;
  bool _heartbeat = false;
  bool _isServer = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsServiceProvider).requestModuleConfig(
        AdminMessage_ModuleConfigType.STOREFORWARD_CONFIG,
      );
      final config = ref.read(moduleConfigProvider);
      if (config != null && config.hasStoreForward()) {
        _loadFromConfig(config.storeForward);
        setState(() {});
      }
    });
  }

  void _loadFromConfig(ModuleConfig_StoreForwardConfig sf) {
    _enabled = sf.enabled;
    _heartbeat = sf.heartbeat;
    _recordsController.text = sf.records.toString();
    _historyReturnMaxController.text = sf.historyReturnMax.toString();
    _historyReturnWindowController.text = sf.historyReturnWindow.toString();
    _isServer = sf.isServer;
  }

  @override
  void dispose() {
    _recordsController.dispose();
    _historyReturnMaxController.dispose();
    _historyReturnWindowController.dispose();
    super.dispose();
  }

  void _save() {
    final sfConfig = ModuleConfig_StoreForwardConfig(
      enabled: _enabled,
      heartbeat: _heartbeat,
      records: int.tryParse(_recordsController.text) ?? 0,
      historyReturnMax: int.tryParse(_historyReturnMaxController.text) ?? 0,
      historyReturnWindow: int.tryParse(_historyReturnWindowController.text) ?? 0,
      isServer: _isServer,
    );

    final config = ModuleConfig(storeForward: sfConfig);
    ref.read(settingsServiceProvider).setModuleConfig(config);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved Store & Forward Config')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ModuleConfig?>(moduleConfigProvider, (previous, next) {
      if (next != null && next.hasStoreForward()) {
        _loadFromConfig(next.storeForward);
        setState(() {});
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Store & Forward Config')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Enabled'),
            value: _enabled,
            onChanged: (val) => setState(() => _enabled = val),
          ),
          SwitchListTile(
            title: const Text('Is Server'),
            subtitle: const Text('Node will store and resend messages'),
            value: _isServer,
            onChanged: (val) => setState(() => _isServer = val),
          ),
          SwitchListTile(
            title: const Text('Heartbeat'),
            value: _heartbeat,
            onChanged: (val) => setState(() => _heartbeat = val),
          ),
          const Divider(),
          TextField(
            controller: _recordsController,
            decoration: const InputDecoration(
              labelText: 'Max Records',
              helperText: 'Number of messages to store',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _historyReturnMaxController,
            decoration: const InputDecoration(
              labelText: 'History Return Max',
              helperText: 'Max messages to return upon request',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _historyReturnWindowController,
            decoration: const InputDecoration(
              labelText: 'History Return Window (seconds)',
              helperText: 'Time window for history requests',
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
