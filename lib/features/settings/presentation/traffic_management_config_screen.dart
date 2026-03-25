import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/module_config.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/admin.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class TrafficManagementConfigScreen extends ConsumerStatefulWidget {
  const TrafficManagementConfigScreen({super.key});

  @override
  ConsumerState<TrafficManagementConfigScreen> createState() =>
      _TrafficManagementConfigScreenState();
}

class _TrafficManagementConfigScreenState
    extends ConsumerState<TrafficManagementConfigScreen> {
  final _positionPrecisionBitsController = TextEditingController();
  final _positionMinIntervalSecsController = TextEditingController();
  final _nodeinfoDirectResponseMaxHopsController = TextEditingController();
  final _rateLimitWindowSecsController = TextEditingController();
  final _rateLimitMaxPacketsController = TextEditingController();
  final _unknownPacketThresholdController = TextEditingController();

  bool _enabled = false;
  bool _positionDedupEnabled = false;
  bool _nodeinfoDirectResponse = false;
  bool _rateLimitEnabled = false;
  bool _dropUnknownEnabled = false;
  bool _exhaustHopTelemetry = false;
  bool _exhaustHopPosition = false;
  bool _routerPreserveHops = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsServiceProvider).requestModuleConfig(
        AdminMessage_ModuleConfigType.TRAFFICMANAGEMENT_CONFIG,
      );
      final config = ref.read(moduleConfigProvider);
      if (config != null && config.hasTrafficManagement()) {
        _loadFromConfig(config.trafficManagement);
        setState(() {});
      }
    });
  }

  void _loadFromConfig(ModuleConfig_TrafficManagementConfig tm) {
    _enabled = tm.enabled;
    _positionDedupEnabled = tm.positionDedupEnabled;
    _positionPrecisionBitsController.text = tm.positionPrecisionBits.toString();
    _positionMinIntervalSecsController.text = tm.positionMinIntervalSecs.toString();
    _nodeinfoDirectResponse = tm.nodeinfoDirectResponse;
    _nodeinfoDirectResponseMaxHopsController.text =
        tm.nodeinfoDirectResponseMaxHops.toString();
    _rateLimitEnabled = tm.rateLimitEnabled;
    _rateLimitWindowSecsController.text = tm.rateLimitWindowSecs.toString();
    _rateLimitMaxPacketsController.text = tm.rateLimitMaxPackets.toString();
    _dropUnknownEnabled = tm.dropUnknownEnabled;
    _unknownPacketThresholdController.text = tm.unknownPacketThreshold.toString();
    _exhaustHopTelemetry = tm.exhaustHopTelemetry;
    _exhaustHopPosition = tm.exhaustHopPosition;
    _routerPreserveHops = tm.routerPreserveHops;
  }

  @override
  void dispose() {
    _positionPrecisionBitsController.dispose();
    _positionMinIntervalSecsController.dispose();
    _nodeinfoDirectResponseMaxHopsController.dispose();
    _rateLimitWindowSecsController.dispose();
    _rateLimitMaxPacketsController.dispose();
    _unknownPacketThresholdController.dispose();
    super.dispose();
  }

  void _save() {
    final tmConfig = ModuleConfig_TrafficManagementConfig(
      enabled: _enabled,
      positionDedupEnabled: _positionDedupEnabled,
      positionPrecisionBits: int.tryParse(_positionPrecisionBitsController.text) ?? 0,
      positionMinIntervalSecs:
          int.tryParse(_positionMinIntervalSecsController.text) ?? 0,
      nodeinfoDirectResponse: _nodeinfoDirectResponse,
      nodeinfoDirectResponseMaxHops:
          int.tryParse(_nodeinfoDirectResponseMaxHopsController.text) ?? 0,
      rateLimitEnabled: _rateLimitEnabled,
      rateLimitWindowSecs: int.tryParse(_rateLimitWindowSecsController.text) ?? 0,
      rateLimitMaxPackets: int.tryParse(_rateLimitMaxPacketsController.text) ?? 0,
      dropUnknownEnabled: _dropUnknownEnabled,
      unknownPacketThreshold: int.tryParse(_unknownPacketThresholdController.text) ?? 0,
      exhaustHopTelemetry: _exhaustHopTelemetry,
      exhaustHopPosition: _exhaustHopPosition,
      routerPreserveHops: _routerPreserveHops,
    );

    final config = ModuleConfig(trafficManagement: tmConfig);
    ref.read(settingsServiceProvider).setModuleConfig(config);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved Traffic Management Config')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ModuleConfig?>(moduleConfigProvider, (previous, next) {
      if (next != null && next.hasTrafficManagement()) {
        _loadFromConfig(next.trafficManagement);
        setState(() {});
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Traffic Management')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Enabled'),
            value: _enabled,
            onChanged: (val) => setState(() => _enabled = val),
          ),
          const Divider(),
          const Text('Position Optimization', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Position Dedup'),
            value: _positionDedupEnabled,
            onChanged: (val) => setState(() => _positionDedupEnabled = val),
          ),
          TextField(
            controller: _positionPrecisionBitsController,
            decoration: const InputDecoration(labelText: 'Precision Bits'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _positionMinIntervalSecsController,
            decoration: const InputDecoration(labelText: 'Min Interval (s)'),
            keyboardType: TextInputType.number,
          ),
          const Divider(),
          const Text('NodeInfo Response', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Direct Response'),
            value: _nodeinfoDirectResponse,
            onChanged: (val) => setState(() => _nodeinfoDirectResponse = val),
          ),
          TextField(
            controller: _nodeinfoDirectResponseMaxHopsController,
            decoration: const InputDecoration(labelText: 'Max Hops'),
            keyboardType: TextInputType.number,
          ),
          const Divider(),
          const Text('Rate Limiting', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Rate Limit Enabled'),
            value: _rateLimitEnabled,
            onChanged: (val) => setState(() => _rateLimitEnabled = val),
          ),
          TextField(
            controller: _rateLimitWindowSecsController,
            decoration: const InputDecoration(labelText: 'Window (s)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _rateLimitMaxPacketsController,
            decoration: const InputDecoration(labelText: 'Max Packets'),
            keyboardType: TextInputType.number,
          ),
          const Divider(),
          const Text('Other Controls', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Drop Unknown Enabled'),
            value: _dropUnknownEnabled,
            onChanged: (val) => setState(() => _dropUnknownEnabled = val),
          ),
          TextField(
            controller: _unknownPacketThresholdController,
            decoration: const InputDecoration(labelText: 'Unknown Threshold'),
            keyboardType: TextInputType.number,
          ),
          SwitchListTile(
            title: const Text('Exhaust Hop Telemetry'),
            value: _exhaustHopTelemetry,
            onChanged: (val) => setState(() => _exhaustHopTelemetry = val),
          ),
          SwitchListTile(
            title: const Text('Exhaust Hop Position'),
            value: _exhaustHopPosition,
            onChanged: (val) => setState(() => _exhaustHopPosition = val),
          ),
          SwitchListTile(
            title: const Text('Router Preserve Hops'),
            value: _routerPreserveHops,
            onChanged: (val) => setState(() => _routerPreserveHops = val),
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
