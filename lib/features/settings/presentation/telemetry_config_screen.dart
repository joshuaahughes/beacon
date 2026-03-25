import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/module_config.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/admin.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class TelemetryConfigScreen extends ConsumerStatefulWidget {
  const TelemetryConfigScreen({super.key});

  @override
  ConsumerState<TelemetryConfigScreen> createState() => _TelemetryConfigScreenState();
}

class _TelemetryConfigScreenState extends ConsumerState<TelemetryConfigScreen> {
  final _deviceUpdateIntervalController = TextEditingController();
  final _environmentUpdateIntervalController = TextEditingController();
  final _airQualityIntervalController = TextEditingController();
  final _powerUpdateIntervalController = TextEditingController();
  final _healthUpdateIntervalController = TextEditingController();

  bool _deviceTelemetryEnabled = false;
  bool _environmentMeasurementEnabled = false;
  bool _environmentScreenEnabled = false;
  bool _environmentDisplayFahrenheit = false;
  bool _airQualityEnabled = false;
  bool _airQualityScreenEnabled = false;
  bool _powerMeasurementEnabled = false;
  bool _powerScreenEnabled = false;
  bool _healthMeasurementEnabled = false;
  bool _healthScreenEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsServiceProvider).requestModuleConfig(
        AdminMessage_ModuleConfigType.TELEMETRY_CONFIG,
      );
      final config = ref.read(moduleConfigProvider);
      if (config != null && config.hasTelemetry()) {
        _loadFromConfig(config.telemetry);
        setState(() {});
      }
    });
  }

  void _loadFromConfig(ModuleConfig_TelemetryConfig t) {
    _deviceUpdateIntervalController.text = t.deviceUpdateInterval.toString();
    _environmentUpdateIntervalController.text =
        t.environmentUpdateInterval.toString();
    _airQualityIntervalController.text = t.airQualityInterval.toString();
    _powerUpdateIntervalController.text = t.powerUpdateInterval.toString();
    _healthUpdateIntervalController.text = t.healthUpdateInterval.toString();

    _deviceTelemetryEnabled = t.deviceTelemetryEnabled;
    _environmentMeasurementEnabled = t.environmentMeasurementEnabled;
    _environmentScreenEnabled = t.environmentScreenEnabled;
    _environmentDisplayFahrenheit = t.environmentDisplayFahrenheit;
    _airQualityEnabled = t.airQualityEnabled;
    _airQualityScreenEnabled = t.airQualityScreenEnabled;
    _powerMeasurementEnabled = t.powerMeasurementEnabled;
    _powerScreenEnabled = t.powerScreenEnabled;
    _healthMeasurementEnabled = t.healthMeasurementEnabled;
    _healthScreenEnabled = t.healthScreenEnabled;
  }

  @override
  void dispose() {
    _deviceUpdateIntervalController.dispose();
    _environmentUpdateIntervalController.dispose();
    _airQualityIntervalController.dispose();
    _powerUpdateIntervalController.dispose();
    _healthUpdateIntervalController.dispose();
    super.dispose();
  }

  void _save() {
    final tConfig = ModuleConfig_TelemetryConfig(
      deviceUpdateInterval: int.tryParse(_deviceUpdateIntervalController.text) ?? 0,
      environmentUpdateInterval:
          int.tryParse(_environmentUpdateIntervalController.text) ?? 0,
      airQualityInterval: int.tryParse(_airQualityIntervalController.text) ?? 0,
      powerUpdateInterval: int.tryParse(_powerUpdateIntervalController.text) ?? 0,
      healthUpdateInterval: int.tryParse(_healthUpdateIntervalController.text) ?? 0,
      deviceTelemetryEnabled: _deviceTelemetryEnabled,
      environmentMeasurementEnabled: _environmentMeasurementEnabled,
      environmentScreenEnabled: _environmentScreenEnabled,
      environmentDisplayFahrenheit: _environmentDisplayFahrenheit,
      airQualityEnabled: _airQualityEnabled,
      airQualityScreenEnabled: _airQualityScreenEnabled,
      powerMeasurementEnabled: _powerMeasurementEnabled,
      powerScreenEnabled: _powerScreenEnabled,
      healthMeasurementEnabled: _healthMeasurementEnabled,
      healthScreenEnabled: _healthScreenEnabled,
    );

    final config = ModuleConfig(telemetry: tConfig);
    ref.read(settingsServiceProvider).setModuleConfig(config);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved Telemetry Config')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ModuleConfig?>(moduleConfigProvider, (previous, next) {
      if (next != null && next.hasTelemetry()) {
        _loadFromConfig(next.telemetry);
        setState(() {});
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Telemetry Config')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Device Metrics', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Device Telemetry Enabled'),
            value: _deviceTelemetryEnabled,
            onChanged: (val) => setState(() => _deviceTelemetryEnabled = val),
          ),
          TextField(
            controller: _deviceUpdateIntervalController,
            decoration: const InputDecoration(labelText: 'Update Interval (seconds)'),
            keyboardType: TextInputType.number,
          ),
          const Divider(),
          const Text('Environment Metrics', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Environment Measurement'),
            value: _environmentMeasurementEnabled,
            onChanged: (val) => setState(() => _environmentMeasurementEnabled = val),
          ),
          SwitchListTile(
            title: const Text('Show on Screen'),
            value: _environmentScreenEnabled,
            onChanged: (val) => setState(() => _environmentScreenEnabled = val),
          ),
          SwitchListTile(
            title: const Text('Display Fahrenheit'),
            value: _environmentDisplayFahrenheit,
            onChanged: (val) => setState(() => _environmentDisplayFahrenheit = val),
          ),
          TextField(
            controller: _environmentUpdateIntervalController,
            decoration: const InputDecoration(labelText: 'Update Interval (seconds)'),
            keyboardType: TextInputType.number,
          ),
          const Divider(),
          const Text('Air Quality Metrics', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Air Quality Enabled'),
            value: _airQualityEnabled,
            onChanged: (val) => setState(() => _airQualityEnabled = val),
          ),
          SwitchListTile(
            title: const Text('Show on Screen'),
            value: _airQualityScreenEnabled,
            onChanged: (val) => setState(() => _airQualityScreenEnabled = val),
          ),
          TextField(
            controller: _airQualityIntervalController,
            decoration: const InputDecoration(labelText: 'Update Interval (seconds)'),
            keyboardType: TextInputType.number,
          ),
          const Divider(),
          const Text('Power Metrics', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Power Measurement'),
            value: _powerMeasurementEnabled,
            onChanged: (val) => setState(() => _powerMeasurementEnabled = val),
          ),
          SwitchListTile(
            title: const Text('Show on Screen'),
            value: _powerScreenEnabled,
            onChanged: (val) => setState(() => _powerScreenEnabled = val),
          ),
          TextField(
            controller: _powerUpdateIntervalController,
            decoration: const InputDecoration(labelText: 'Update Interval (seconds)'),
            keyboardType: TextInputType.number,
          ),
          const Divider(),
          const Text('Health Metrics', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Health Measurement'),
            value: _healthMeasurementEnabled,
            onChanged: (val) => setState(() => _healthMeasurementEnabled = val),
          ),
          SwitchListTile(
            title: const Text('Show on Screen'),
            value: _healthScreenEnabled,
            onChanged: (val) => setState(() => _healthScreenEnabled = val),
          ),
          TextField(
            controller: _healthUpdateIntervalController,
            decoration: const InputDecoration(labelText: 'Update Interval (seconds)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
