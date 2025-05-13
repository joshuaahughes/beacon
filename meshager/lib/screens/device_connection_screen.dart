import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import '../providers/meshtastic_provider.dart';

class DeviceConnectionScreen extends StatefulWidget {
  const DeviceConnectionScreen({super.key});

  @override
  State<DeviceConnectionScreen> createState() => _DeviceConnectionScreenState();
}

class _DeviceConnectionScreenState extends State<DeviceConnectionScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connected Devices'),
      ),
      body: Consumer<MeshtasticProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              if (provider.error != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red[100],
                  child: Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(
                child: ListView(
                  children: [
                    // Connected devices section
                    if (provider.connectedDevice != null)
                      ListTile(
                        leading: const Icon(Icons.bluetooth_connected, color: Colors.green),
                        title: Text(provider.connectedDevice!.platformName),
                        subtitle: Text(provider.connectedDevice!.remoteId.str),
                        trailing: IconButton(
                          icon: const Icon(Icons.bluetooth_disabled),
                          onPressed: () => provider.disconnect(),
                        ),
                      ),
                    // Scan button
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed: provider.isScanning ? null : provider.startScan,
                        icon: provider.isScanning 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.bluetooth_searching),
                        label: Text(provider.isScanning ? 'Scanning...' : 'Scan for New Devices'),
                      ),
                    ),
                    // Discovered devices section
                    if (provider.discoveredDevices.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Available Devices',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...provider.discoveredDevices.map((device) {
                        final isConnected = provider.connectedDevice?.remoteId == device.remoteId;
                        return ListTile(
                          leading: Icon(
                            isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                            color: isConnected ? Colors.green : Colors.grey,
                          ),
                          title: Text(device.platformName),
                          subtitle: Text(device.remoteId.str),
                          trailing: isConnected
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : TextButton(
                                  onPressed: () async {
                                    try {
                                      await provider.connect(device);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Connected to device successfully'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Failed to connect: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text('Connect'),
                                ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 