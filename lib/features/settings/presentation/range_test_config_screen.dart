import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/module_config.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/admin.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class RangeTestConfigScreen extends ConsumerStatefulWidget {
  const RangeTestConfigScreen({super.key});

  @override
  ConsumerState<RangeTestConfigScreen> createState() =>
      _RangeTestConfigScreenState();
}

class _RangeTestConfigScreenState extends ConsumerState<RangeTestConfigScreen> {
  final _senderController = TextEditingController();

  bool _enabled = false;
  bool _saveToCsv = false;
  bool _clearOnReboot = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsServiceProvider).requestModuleConfig(
        AdminMessage_ModuleConfigType.RANGETEST_CONFIG,
      );
      final config = ref.read(moduleConfigProvider);
      if (config != null && config.hasRangeTest()) {
        _loadFromConfig(config.rangeTest);
        setState(() {});
      }
    });
  }

  void _loadFromConfig(ModuleConfig_RangeTestConfig rt) {
    _enabled = rt.enabled;
    _senderController.text = rt.sender.toString();
    _saveToCsv = rt.save;
    _clearOnReboot = rt.clearOnReboot;
  }

  @override
  void dispose() {
    _senderController.dispose();
    super.dispose();
  }

  void _save() {
    final rtConfig = ModuleConfig_RangeTestConfig(
      enabled: _enabled,
      sender: int.tryParse(_senderController.text) ?? 0,
      save: _saveToCsv,
      clearOnReboot: _clearOnReboot,
    );

    final config = ModuleConfig(rangeTest: rtConfig);
    ref.read(settingsServiceProvider).setModuleConfig(config);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved Range Test Config')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ModuleConfig?>(moduleConfigProvider, (previous, next) {
      if (next != null && next.hasRangeTest()) {
        _loadFromConfig(next.rangeTest);
        setState(() {});
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Range Test Config')),
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
            controller: _senderController,
            decoration: const InputDecoration(
              labelText: 'Sender Interval',
              helperText: 'Send range test messages at this interval',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Save to CSV'),
            subtitle: const Text('ESP32 only'),
            value: _saveToCsv,
            onChanged: (val) => setState(() => _saveToCsv = val),
          ),
          SwitchListTile(
            title: const Text('Clear on Reboot'),
            subtitle: const Text('Delete CSV file on reboot'),
            value: _clearOnReboot,
            onChanged: (val) => setState(() => _clearOnReboot = val),
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
