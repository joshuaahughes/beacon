import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/device.dart';

class LoraDiscoveryScreen extends StatefulWidget {
  const LoraDiscoveryScreen({super.key});

  @override
  State<LoraDiscoveryScreen> createState() => _LoraDiscoveryScreenState();
}

class _LoraDiscoveryScreenState extends State<LoraDiscoveryScreen> {
  List<Device> _loraDevices = [];
  bool _isScanning = false;
  final MapController _mapController = MapController();
  static const LatLng _defaultLocation = LatLng(37.7749, -122.4194); // Example coordinates

  Future<void> _startLoraScan() async {
    setState(() {
      _isScanning = true;
      _loraDevices = [];
    });

    // TODO: Implement actual Lora device scanning
    // This is a placeholder that simulates finding Lora devices
    await Future.delayed(const Duration(seconds: 3));
    
    setState(() {
      _loraDevices = [
        Device(
          id: '1',
          name: 'Lora Device 1',
          address: 'LORA_001',
          signalStrength: -65,
        ),
        Device(
          id: '2',
          name: 'Lora Device 2',
          address: 'LORA_002',
          signalStrength: -72,
        ),
      ];
      _isScanning = false;
    });
  }

  Future<void> _connectToLoraDevice(Device device) async {
    // TODO: Implement actual Lora device connection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Connecting to ${device.name}...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lora Discovery'),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.refresh),
            onPressed: _isScanning ? null : _startLoraScan,
          ),
        ],
      ),
      body: Column(
        children: [
          // Map section
          Expanded(
            flex: 2,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _defaultLocation,
                initialZoom: 12.0,
                onTap: (tapPosition, point) {
                  debugPrint('Map tapped at: ${point.latitude}, ${point.longitude}');
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.meshager',
                ),
                MarkerLayer(
                  markers: _loraDevices.map((device) {
                    return Marker(
                      point: _defaultLocation, // TODO: Replace with actual device location
                      width: 80,
                      height: 80,
                      child: Column(
                        children: [
                          const Icon(
                            Icons.radar,
                            color: Colors.blue,
                            size: 30,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              device.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // Device list section
          Expanded(
            flex: 1,
            child: _isScanning
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _loraDevices.length,
                    itemBuilder: (context, index) {
                      final device = _loraDevices[index];
                      return ListTile(
                        leading: Icon(
                          device.isConnected ? Icons.radar : Icons.radar_outlined,
                          color: device.isConnected ? Colors.green : Colors.grey,
                        ),
                        title: Text(device.name),
                        subtitle: Text('Signal: ${device.signalStrength} dBm'),
                        trailing: device.isConnected
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : TextButton(
                                onPressed: () => _connectToLoraDevice(device),
                                child: const Text('Connect'),
                              ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 