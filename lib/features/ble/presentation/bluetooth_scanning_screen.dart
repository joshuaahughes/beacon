import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:beacon/data/providers/ble_providers.dart';

class BluetoothScanningScreen extends ConsumerStatefulWidget {
  const BluetoothScanningScreen({super.key});

  @override
  ConsumerState<BluetoothScanningScreen> createState() => _BluetoothScanningScreenState();
}

class _BluetoothScanningScreenState extends ConsumerState<BluetoothScanningScreen> {
  @override
  void initState() {
    super.initState();
    // Start scan on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bleRepositoryProvider).startScan().catchError((e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to start scan: $e')),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isScanning = ref.watch(bleScanningProvider).value ?? false;
    final scanResults = ref.watch(bleScanResultsProvider).value ?? [];
    final repo = ref.read(bleRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Devices'),
        actions: [
          if (isScanning)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => repo.startScan(),
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: scanResults.length,
        itemBuilder: (context, index) {
          final result = scanResults[index] as ScanResult;
          final device = result.device;
          final name = device.platformName.isNotEmpty ? device.platformName : 'Unknown Device';

          return ListTile(
            leading: const Icon(Icons.bluetooth),
            title: Text(name),
            subtitle: Text(device.remoteId.toString()),
            trailing: Text('${result.rssi} dBm'),
            onTap: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              
              try {
                // Show connecting dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );
                
                await repo.connect(device);
                ref.read(connectedDeviceProvider.notifier).setDevice(device);
                
                if (mounted) {
                  navigator.pop(); // Dismiss loading
                  navigator.pop(); // Go back to settings
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Connected to ${device.platformName}')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  navigator.pop(); // Dismiss loading
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Connection failed: $e')),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }
}
