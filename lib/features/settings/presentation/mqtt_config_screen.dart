import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/module_config.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/admin.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class MqttConfigScreen extends ConsumerStatefulWidget {
  const MqttConfigScreen({super.key});

  @override
  ConsumerState<MqttConfigScreen> createState() => _MqttConfigScreenState();
}

class _MqttConfigScreenState extends ConsumerState<MqttConfigScreen> {
  final _addressController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rootController = TextEditingController();
  final _publishIntervalSecsController = TextEditingController();
  final _positionPrecisionController = TextEditingController();

  bool _enabled = false;
  bool _encryptionEnabled = false;
  bool _jsonEnabled = false;
  bool _tlsEnabled = false;
  bool _proxyToClientEnabled = false;
  bool _mapReportingEnabled = false;
  bool _shouldReportLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsServiceProvider).requestModuleConfig(
        AdminMessage_ModuleConfigType.MQTT_CONFIG,
      );
      final config = ref.read(moduleConfigProvider);
      if (config != null && config.hasMqtt()) {
        _loadFromConfig(config.mqtt);
        setState(() {});
      }
    });
  }

  void _loadFromConfig(ModuleConfig_MQTTConfig mqtt) {
    _enabled = mqtt.enabled;
    _addressController.text = mqtt.address;
    _usernameController.text = mqtt.username;
    _passwordController.text = mqtt.password;
    _encryptionEnabled = mqtt.encryptionEnabled;
    _jsonEnabled = mqtt.jsonEnabled;
    _tlsEnabled = mqtt.tlsEnabled;
    _rootController.text = mqtt.root;
    _proxyToClientEnabled = mqtt.proxyToClientEnabled;
    _mapReportingEnabled = mqtt.mapReportingEnabled;

    if (mqtt.hasMapReportSettings()) {
      _publishIntervalSecsController.text =
          mqtt.mapReportSettings.publishIntervalSecs.toString();
      _positionPrecisionController.text =
          mqtt.mapReportSettings.positionPrecision.toString();
      _shouldReportLocation = mqtt.mapReportSettings.shouldReportLocation;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _rootController.dispose();
    _publishIntervalSecsController.dispose();
    _positionPrecisionController.dispose();
    super.dispose();
  }

  void _save() {
    final mqttConfig = ModuleConfig_MQTTConfig(
      enabled: _enabled,
      address: _addressController.text,
      username: _usernameController.text,
      password: _passwordController.text,
      encryptionEnabled: _encryptionEnabled,
      jsonEnabled: _jsonEnabled,
      tlsEnabled: _tlsEnabled,
      root: _rootController.text,
      proxyToClientEnabled: _proxyToClientEnabled,
      mapReportingEnabled: _mapReportingEnabled,
      mapReportSettings: ModuleConfig_MapReportSettings(
        publishIntervalSecs:
            int.tryParse(_publishIntervalSecsController.text) ?? 0,
        positionPrecision: int.tryParse(_positionPrecisionController.text) ?? 0,
        shouldReportLocation: _shouldReportLocation,
      ),
    );

    final config = ModuleConfig(mqtt: mqttConfig);
    ref.read(settingsServiceProvider).setModuleConfig(config);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved MQTT Config')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ModuleConfig?>(moduleConfigProvider, (previous, next) {
      if (next != null && next.hasMqtt()) {
        _loadFromConfig(next.mqtt);
        setState(() {});
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('MQTT Config')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Enabled'),
            subtitle: const Text('Enable MQTT gateway'),
            value: _enabled,
            onChanged: (val) => setState(() => _enabled = val),
          ),
          const Divider(),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Server Address',
              helperText: 'e.g. mqtt.meshtastic.org',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _rootController,
            decoration: const InputDecoration(
              labelText: 'Root Topic',
              helperText: 'Default: msh',
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Encryption Enabled'),
            value: _encryptionEnabled,
            onChanged: (val) => setState(() => _encryptionEnabled = val),
          ),
          SwitchListTile(
            title: const Text('JSON Enabled'),
            value: _jsonEnabled,
            onChanged: (val) => setState(() => _jsonEnabled = val),
          ),
          SwitchListTile(
            title: const Text('TLS Enabled'),
            value: _tlsEnabled,
            onChanged: (val) => setState(() => _tlsEnabled = val),
          ),
          SwitchListTile(
            title: const Text('Proxy to Client'),
            subtitle: const Text('Use phone instead of direct WiFi/Ethernet'),
            value: _proxyToClientEnabled,
            onChanged: (val) => setState(() => _proxyToClientEnabled = val),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Map Reporting'),
            value: _mapReportingEnabled,
            onChanged: (val) => setState(() => _mapReportingEnabled = val),
          ),
          if (_mapReportingEnabled) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _publishIntervalSecsController,
                    decoration: const InputDecoration(
                      labelText: 'Publish Interval (seconds)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _positionPrecisionController,
                    decoration: const InputDecoration(
                      labelText: 'Position Precision (bits)',
                      helperText: '32 for full precision',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SwitchListTile(
                    title: const Text('Report Location'),
                    value: _shouldReportLocation,
                    onChanged: (val) => setState(() => _shouldReportLocation = val),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
