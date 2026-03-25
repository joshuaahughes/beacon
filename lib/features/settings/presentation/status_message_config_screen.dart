import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/module_config.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/admin.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class StatusMessageConfigScreen extends ConsumerStatefulWidget {
  const StatusMessageConfigScreen({super.key});

  @override
  ConsumerState<StatusMessageConfigScreen> createState() =>
      _StatusMessageConfigScreenState();
}

class _StatusMessageConfigScreenState
    extends ConsumerState<StatusMessageConfigScreen> {
  final _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsServiceProvider).requestModuleConfig(
        AdminMessage_ModuleConfigType.STATUSMESSAGE_CONFIG,
      );
      final config = ref.read(moduleConfigProvider);
      if (config != null && config.hasStatusmessage()) {
        _loadFromConfig(config.statusmessage);
        setState(() {});
      }
    });
  }

  void _loadFromConfig(ModuleConfig_StatusMessageConfig sm) {
    _statusController.text = sm.nodeStatus;
  }

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  void _save() {
    final smConfig = ModuleConfig_StatusMessageConfig(
      nodeStatus: _statusController.text,
    );

    final config = ModuleConfig(statusmessage: smConfig);
    ref.read(settingsServiceProvider).setModuleConfig(config);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved Status Message Config')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ModuleConfig?>(moduleConfigProvider, (previous, next) {
      if (next != null && next.hasStatusmessage()) {
        _loadFromConfig(next.statusmessage);
        setState(() {});
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Status Message Config')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Node Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _statusController,
            decoration: const InputDecoration(
              labelText: 'Status Message',
              helperText: 'Enter a custom status message for your node',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
