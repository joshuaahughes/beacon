import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/config.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class SecurityConfigScreen extends ConsumerStatefulWidget {
  const SecurityConfigScreen({super.key});

  @override
  ConsumerState<SecurityConfigScreen> createState() =>
      _SecurityConfigScreenState();
}

class _SecurityConfigScreenState extends ConsumerState<SecurityConfigScreen> {
  final _publicKeyController = TextEditingController();
  final _privateKeyController = TextEditingController();
  final _adminKeyController = TextEditingController();

  bool _isManaged = false;
  bool _serialEnabled = true;
  bool _debugLogApiEnabled = false;
  bool _adminChannelEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = ref.read(deviceConfigProvider);
      if (config != null && config.hasSecurity()) {
        _loadFromConfig(config.security);
        setState(() {});
      }
    });
  }

  void _loadFromConfig(Config_SecurityConfig security) {
    _isManaged = security.isManaged;
    _serialEnabled = security.serialEnabled;
    _debugLogApiEnabled = security.debugLogApiEnabled;
    _adminChannelEnabled = security.adminChannelEnabled;
    if (security.publicKey.isNotEmpty) {
      _publicKeyController.text = '(set)';
    }
    if (security.privateKey.isNotEmpty) {
      _privateKeyController.text = '(set)';
    }
    if (security.adminKey.isNotEmpty) {
      _adminKeyController.text = '${security.adminKey.length} key(s)';
    }
  }

  @override
  void dispose() {
    _publicKeyController.dispose();
    _privateKeyController.dispose();
    _adminKeyController.dispose();
    super.dispose();
  }

  void _save() {
    final securityConfig = Config_SecurityConfig(
      isManaged: _isManaged,
      serialEnabled: _serialEnabled,
      debugLogApiEnabled: _debugLogApiEnabled,
      adminChannelEnabled: _adminChannelEnabled,
    );

    final config = Config(security: securityConfig);
    ref.read(settingsServiceProvider).setConfig(config);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved Security Config')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Config?>(deviceConfigProvider, (previous, next) {
      if (next != null && next.hasSecurity()) {
        _loadFromConfig(next.security);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Security Config')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _publicKeyController,
            decoration: const InputDecoration(
              labelText: 'Public Key',
              helperText: 'Sent to other nodes for shared secret',
            ),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _privateKeyController,
            decoration: const InputDecoration(
              labelText: 'Private Key',
              helperText: 'Used to create shared key with remote device',
            ),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _adminKeyController,
            decoration: const InputDecoration(
              labelText: 'Admin Keys',
              helperText: 'Public keys authorized to send admin messages',
            ),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Managed'),
            subtitle: const Text('Device is managed by mesh administrator'),
            value: _isManaged,
            onChanged: (val) => setState(() => _isManaged = val),
          ),
          SwitchListTile(
            title: const Text('Serial Console'),
            subtitle: const Text('Serial Console over Stream API'),
            value: _serialEnabled,
            onChanged: (val) => setState(() => _serialEnabled = val),
          ),
          SwitchListTile(
            title: const Text('Debug Log API'),
            value: _debugLogApiEnabled,
            onChanged: (val) => setState(() => _debugLogApiEnabled = val),
          ),
          SwitchListTile(
            title: const Text('Admin Channel'),
            value: _adminChannelEnabled,
            onChanged: (val) => setState(() => _adminChannelEnabled = val),
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
