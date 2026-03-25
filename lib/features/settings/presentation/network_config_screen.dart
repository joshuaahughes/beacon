import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/config.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class NetworkConfigScreen extends ConsumerStatefulWidget {
  const NetworkConfigScreen({super.key});

  @override
  ConsumerState<NetworkConfigScreen> createState() =>
      _NetworkConfigScreenState();
}

class _NetworkConfigScreenState extends ConsumerState<NetworkConfigScreen> {
  final _wifiSsidController = TextEditingController();
  final _wifiPskController = TextEditingController();
  final _ntpServerController = TextEditingController();
  final _rsyslogServerController = TextEditingController();

  bool _wifiEnabled = false;
  bool _ethEnabled = false;
  bool _ipv6Enabled = false;
  Config_NetworkConfig_AddressMode _addressMode =
      Config_NetworkConfig_AddressMode.DHCP;
  Config_NetworkConfig_IpV4Config _ipv4Config =
      Config_NetworkConfig_IpV4Config();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = ref.read(deviceConfigProvider);
      if (config != null && config.hasNetwork()) {
        _loadFromConfig(config.network);
        setState(() {});
      }
    });
  }

  void _loadFromConfig(Config_NetworkConfig network) {
    _wifiEnabled = network.wifiEnabled;
    _wifiSsidController.text = network.wifiSsid;
    _wifiPskController.text = network.wifiPsk;
    _ntpServerController.text = network.ntpServer;
    _ethEnabled = network.ethEnabled;
    _addressMode = network.addressMode;
    _ipv4Config = network.hasIpv4Config()
        ? network.ipv4Config
        : Config_NetworkConfig_IpV4Config();
    _rsyslogServerController.text = network.rsyslogServer;
    _ipv6Enabled = network.ipv6Enabled;
  }

  @override
  void dispose() {
    _wifiSsidController.dispose();
    _wifiPskController.dispose();
    _ntpServerController.dispose();
    _rsyslogServerController.dispose();
    super.dispose();
  }

  void _save() {
    final networkConfig = Config_NetworkConfig(
      wifiEnabled: _wifiEnabled,
      wifiSsid: _wifiSsidController.text,
      wifiPsk: _wifiPskController.text,
      ntpServer: _ntpServerController.text,
      ethEnabled: _ethEnabled,
      addressMode: _addressMode,
      ipv4Config: _ipv4Config,
      rsyslogServer: _rsyslogServerController.text,
      ipv6Enabled: _ipv6Enabled,
    );

    final config = Config(network: networkConfig);
    ref.read(settingsServiceProvider).setConfig(config);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved Network Config')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Config?>(deviceConfigProvider, (previous, next) {
      if (next != null && next.hasNetwork()) {
        _loadFromConfig(next.network);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Network Config')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('WiFi Enabled'),
            subtitle: const Text('Enable WiFi (disables Bluetooth)'),
            value: _wifiEnabled,
            onChanged: (val) => setState(() => _wifiEnabled = val),
          ),
          if (_wifiEnabled) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _wifiSsidController,
              decoration: const InputDecoration(labelText: 'WiFi SSID'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _wifiPskController,
              decoration: const InputDecoration(labelText: 'WiFi Password'),
              obscureText: true,
            ),
          ],
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Ethernet Enabled'),
            value: _ethEnabled,
            onChanged: (val) => setState(() => _ethEnabled = val),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Config_NetworkConfig_AddressMode>(
            value: _addressMode,
            decoration: const InputDecoration(labelText: 'Address Mode'),
            items: Config_NetworkConfig_AddressMode.values.map((mode) {
              return DropdownMenuItem(value: mode, child: Text(mode.name));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _addressMode = val);
            },
          ),
          if (_addressMode == Config_NetworkConfig_AddressMode.STATIC) ...[
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Static IP'),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                _ipv4Config = Config_NetworkConfig_IpV4Config(
                  ip: int.tryParse(val),
                  gateway: _ipv4Config.gateway,
                  subnet: _ipv4Config.subnet,
                  dns: _ipv4Config.dns,
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Gateway'),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                _ipv4Config = Config_NetworkConfig_IpV4Config(
                  ip: _ipv4Config.ip,
                  gateway: int.tryParse(val),
                  subnet: _ipv4Config.subnet,
                  dns: _ipv4Config.dns,
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Subnet'),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                _ipv4Config = Config_NetworkConfig_IpV4Config(
                  ip: _ipv4Config.ip,
                  gateway: _ipv4Config.gateway,
                  subnet: int.tryParse(val),
                  dns: _ipv4Config.dns,
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'DNS'),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                _ipv4Config = Config_NetworkConfig_IpV4Config(
                  ip: _ipv4Config.ip,
                  gateway: _ipv4Config.gateway,
                  subnet: _ipv4Config.subnet,
                  dns: int.tryParse(val),
                );
              },
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _ntpServerController,
            decoration: const InputDecoration(
              labelText: 'NTP Server',
              helperText: 'Defaults to meshtastic.pool.ntp.org',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _rsyslogServerController,
            decoration: const InputDecoration(labelText: 'Rsyslog Server'),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('IPv6 Enabled'),
            value: _ipv6Enabled,
            onChanged: (val) => setState(() => _ipv6Enabled = val),
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
