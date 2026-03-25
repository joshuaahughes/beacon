import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/module_config.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/admin.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class CannedMessageConfigScreen extends ConsumerStatefulWidget {
  const CannedMessageConfigScreen({super.key});

  @override
  ConsumerState<CannedMessageConfigScreen> createState() =>
      _CannedMessageConfigScreenState();
}

class _CannedMessageConfigScreenState extends ConsumerState<CannedMessageConfigScreen> {
  final _pinAController = TextEditingController();
  final _pinBController = TextEditingController();
  final _pinPressController = TextEditingController();

  bool _rotary1Enabled = false;
  bool _updown1Enabled = false;
  bool _sendBell = false;

  ModuleConfig_CannedMessageConfig_InputEventChar _eventCw =
      ModuleConfig_CannedMessageConfig_InputEventChar.NONE;
  ModuleConfig_CannedMessageConfig_InputEventChar _eventCcw =
      ModuleConfig_CannedMessageConfig_InputEventChar.NONE;
  ModuleConfig_CannedMessageConfig_InputEventChar _eventPress =
      ModuleConfig_CannedMessageConfig_InputEventChar.NONE;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsServiceProvider).requestModuleConfig(
        AdminMessage_ModuleConfigType.CANNEDMSG_CONFIG,
      );
      final config = ref.read(moduleConfigProvider);
      if (config != null && config.hasCannedMessage()) {
        _loadFromConfig(config.cannedMessage);
        setState(() {});
      }
    });
  }

  void _loadFromConfig(ModuleConfig_CannedMessageConfig cm) {
    _rotary1Enabled = cm.rotary1Enabled;
    _pinAController.text = cm.inputbrokerPinA.toString();
    _pinBController.text = cm.inputbrokerPinB.toString();
    _pinPressController.text = cm.inputbrokerPinPress.toString();
    _eventCw = cm.inputbrokerEventCw;
    _eventCcw = cm.inputbrokerEventCcw;
    _eventPress = cm.inputbrokerEventPress;
    _updown1Enabled = cm.updown1Enabled;
    _sendBell = cm.sendBell;
  }

  @override
  void dispose() {
    _pinAController.dispose();
    _pinBController.dispose();
    _pinPressController.dispose();
    super.dispose();
  }

  void _save() {
    final cmConfig = ModuleConfig_CannedMessageConfig(
      rotary1Enabled: _rotary1Enabled,
      inputbrokerPinA: int.tryParse(_pinAController.text) ?? 0,
      inputbrokerPinB: int.tryParse(_pinBController.text) ?? 0,
      inputbrokerPinPress: int.tryParse(_pinPressController.text) ?? 0,
      inputbrokerEventCw: _eventCw,
      inputbrokerEventCcw: _eventCcw,
      inputbrokerEventPress: _eventPress,
      updown1Enabled: _updown1Enabled,
      sendBell: _sendBell,
    );

    final config = ModuleConfig(cannedMessage: cmConfig);
    ref.read(settingsServiceProvider).setModuleConfig(config);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved Canned Message Config')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ModuleConfig?>(moduleConfigProvider, (previous, next) {
      if (next != null && next.hasCannedMessage()) {
        _loadFromConfig(next.cannedMessage);
        setState(() {});
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Canned Message Config')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Rotary 1 Enabled'),
            value: _rotary1Enabled,
            onChanged: (val) => setState(() => _rotary1Enabled = val),
          ),
          SwitchListTile(
            title: const Text('Up/Down 1 Enabled'),
            value: _updown1Enabled,
            onChanged: (val) => setState(() => _updown1Enabled = val),
          ),
          SwitchListTile(
            title: const Text('Send Bell'),
            subtitle: const Text('Send bell character with messages'),
            value: _sendBell,
            onChanged: (val) => setState(() => _sendBell = val),
          ),
          const Divider(),
          const Text('Input Broker Pins', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: _pinAController,
            decoration: const InputDecoration(labelText: 'Pin A'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _pinBController,
            decoration: const InputDecoration(labelText: 'Pin B'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _pinPressController,
            decoration: const InputDecoration(labelText: 'Pin Press'),
            keyboardType: TextInputType.number,
          ),
          const Divider(),
          const Text('Events', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButtonFormField<ModuleConfig_CannedMessageConfig_InputEventChar>(
            value: _eventCw,
            decoration: const InputDecoration(labelText: 'CW Event'),
            items: ModuleConfig_CannedMessageConfig_InputEventChar.values.map((e) {
              return DropdownMenuItem(value: e, child: Text(e.name));
            }).toList(),
            onChanged: (val) => setState(() => _eventCw = val!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ModuleConfig_CannedMessageConfig_InputEventChar>(
            value: _eventCcw,
            decoration: const InputDecoration(labelText: 'CCW Event'),
            items: ModuleConfig_CannedMessageConfig_InputEventChar.values.map((e) {
              return DropdownMenuItem(value: e, child: Text(e.name));
            }).toList(),
            onChanged: (val) => setState(() => _eventCcw = val!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ModuleConfig_CannedMessageConfig_InputEventChar>(
            value: _eventPress,
            decoration: const InputDecoration(labelText: 'Press Event'),
            items: ModuleConfig_CannedMessageConfig_InputEventChar.values.map((e) {
              return DropdownMenuItem(value: e, child: Text(e.name));
            }).toList(),
            onChanged: (val) => setState(() => _eventPress = val!),
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
