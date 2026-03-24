import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/config.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class PositionConfigScreen extends ConsumerStatefulWidget {
  const PositionConfigScreen({super.key});

  @override
  ConsumerState<PositionConfigScreen> createState() => _PositionConfigScreenState();
}

class _PositionConfigScreenState extends ConsumerState<PositionConfigScreen> {
  final _broadcastSecsController = TextEditingController();
  bool _smartEnabled = false;
  bool _fixedPosition = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = ref.read(deviceConfigProvider);
      if (config != null && config.hasPosition()) {
        _broadcastSecsController.text = config.position.positionBroadcastSecs.toString();
        _smartEnabled = config.position.positionBroadcastSmartEnabled;
        _fixedPosition = config.position.fixedPosition;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _broadcastSecsController.dispose();
    super.dispose();
  }

  void _save() {
    final broadcastSecs = int.tryParse(_broadcastSecsController.text) ?? 900;
    
    final positionConfig = Config_PositionConfig(
      positionBroadcastSecs: broadcastSecs,
      positionBroadcastSmartEnabled: _smartEnabled,
      fixedPosition: _fixedPosition,
    );
    
    final config = Config(position: positionConfig);
    ref.read(settingsServiceProvider).setConfig(config);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved Position Config')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Config?>(deviceConfigProvider, (previous, next) {
      if (next != null && next.hasPosition()) {
        if (_broadcastSecsController.text.isEmpty || previous == null) {
          _broadcastSecsController.text = next.position.positionBroadcastSecs.toString();
        }
        if (previous == null) {
          _smartEnabled = next.position.positionBroadcastSmartEnabled;
          _fixedPosition = next.position.fixedPosition;
          setState(() {});
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Position Config'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _broadcastSecsController,
            decoration: const InputDecoration(labelText: 'Broadcast Interval (secs)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Smart Broadcast'),
            value: _smartEnabled,
            onChanged: (val) {
              setState(() => _smartEnabled = val);
            },
          ),
          SwitchListTile(
            title: const Text('Fixed Position'),
            value: _fixedPosition,
            onChanged: (val) {
              setState(() => _fixedPosition = val);
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
