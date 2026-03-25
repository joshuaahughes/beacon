import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/module_config.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/admin.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class AmbientLightingConfigScreen extends ConsumerStatefulWidget {
  const AmbientLightingConfigScreen({super.key});

  @override
  ConsumerState<AmbientLightingConfigScreen> createState() =>
      _AmbientLightingConfigScreenState();
}

class _AmbientLightingConfigScreenState
    extends ConsumerState<AmbientLightingConfigScreen> {
  final _currentController = TextEditingController();
  final _redController = TextEditingController();
  final _greenController = TextEditingController();
  final _blueController = TextEditingController();

  bool _ledState = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsServiceProvider).requestModuleConfig(
        AdminMessage_ModuleConfigType.AMBIENTLIGHTING_CONFIG,
      );
      final config = ref.read(moduleConfigProvider);
      if (config != null && config.hasAmbientLighting()) {
        _loadFromConfig(config.ambientLighting);
        setState(() {});
      }
    });
  }

  void _loadFromConfig(ModuleConfig_AmbientLightingConfig al) {
    _ledState = al.ledState;
    _currentController.text = al.current.toString();
    _redController.text = al.red.toString();
    _greenController.text = al.green.toString();
    _blueController.text = al.blue.toString();
  }

  @override
  void dispose() {
    _currentController.dispose();
    _redController.dispose();
    _greenController.dispose();
    _blueController.dispose();
    super.dispose();
  }

  void _save() {
    final alConfig = ModuleConfig_AmbientLightingConfig(
      ledState: _ledState,
      current: int.tryParse(_currentController.text) ?? 10,
      red: int.tryParse(_redController.text) ?? 0,
      green: int.tryParse(_greenController.text) ?? 0,
      blue: int.tryParse(_blueController.text) ?? 0,
    );

    final config = ModuleConfig(ambientLighting: alConfig);
    ref.read(settingsServiceProvider).setModuleConfig(config);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved Ambient Lighting Config')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ModuleConfig?>(moduleConfigProvider, (previous, next) {
      if (next != null && next.hasAmbientLighting()) {
        _loadFromConfig(next.ambientLighting);
        setState(() {});
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Ambient Lighting Config')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('LED State'),
            subtitle: const Text('Turn LED on or off'),
            value: _ledState,
            onChanged: (val) => setState(() => _ledState = val),
          ),
          const Divider(),
          TextField(
            controller: _currentController,
            decoration: const InputDecoration(
              labelText: 'Current',
              helperText: 'Default: 10',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          const Text('Colors (0-255)', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: _redController,
            decoration: const InputDecoration(labelText: 'Red'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _greenController,
            decoration: const InputDecoration(labelText: 'Green'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _blueController,
            decoration: const InputDecoration(labelText: 'Blue'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
