import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';

class OfflineMapsScreen extends StatefulWidget {
  const OfflineMapsScreen({super.key});

  @override
  State<OfflineMapsScreen> createState() => _OfflineMapsScreenState();
}

class _OfflineMapsScreenState extends State<OfflineMapsScreen> {
  final MapController _mapController = MapController();
  LatLngBounds? _selectedBounds;
  int _minZoom = 10;
  int _maxZoom = 16;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().initializeCache();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Maps'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showClearCacheDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(0, 0),
                initialZoom: 2,
                onMapReady: () {
                  _mapController.mapEventStream.listen((event) {
                    if (event is MapEventMoveEnd) {
                      setState(() {
                        _selectedBounds = _mapController.camera.visibleBounds;
                      });
                    }
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.meshager',
                ),
                if (_selectedBounds != null)
                  PolygonLayer(
                    polygons: [
                      Polygon(
                        points: [
                          _selectedBounds!.northWest,
                          _selectedBounds!.northEast,
                          _selectedBounds!.southEast,
                          _selectedBounds!.southWest,
                        ],
                        color: Colors.blue.withOpacity(0.2),
                        borderColor: Colors.blue,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Consumer<MapProvider>(
            builder: (context, provider, child) {
              if (provider.isDownloading) {
                return LinearProgressIndicator(
                  value: provider.downloadProgress,
                );
              }
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Min Zoom: $_minZoom'),
                        ),
                        Expanded(
                          child: Slider(
                            value: _minZoom.toDouble(),
                            min: 5,
                            max: 18,
                            divisions: 13,
                            label: _minZoom.toString(),
                            onChanged: (value) {
                              setState(() {
                                _minZoom = value.toInt();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Max Zoom: $_maxZoom'),
                        ),
                        Expanded(
                          child: Slider(
                            value: _maxZoom.toDouble(),
                            min: 5,
                            max: 18,
                            divisions: 13,
                            label: _maxZoom.toString(),
                            onChanged: (value) {
                              setState(() {
                                _maxZoom = value.toInt();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _selectedBounds == null
                          ? null
                          : () => _downloadSelectedRegion(provider),
                      child: const Text('Download Selected Region'),
                    ),
                  ],
                ),
              );
            },
          ),
          if (context.watch<MapProvider>().downloadedRegions.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: context.watch<MapProvider>().downloadedRegions.length,
                itemBuilder: (context, index) {
                  final region = context.watch<MapProvider>().downloadedRegions[index];
                  return ListTile(
                    title: Text('Region ${index + 1}'),
                    subtitle: Text(
                      'Zoom: ${region.minZoom}-${region.maxZoom}\n'
                      'Bounds: ${region.bounds.toString()}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteRegion(region.id),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _downloadSelectedRegion(MapProvider provider) async {
    if (_selectedBounds == null) return;

    await provider.downloadRegion(
      bounds: _selectedBounds!,
      minZoom: _minZoom,
      maxZoom: _maxZoom,
    );

    if (mounted && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteRegion(String regionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Region'),
        content: const Text('Are you sure you want to delete this region?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<MapProvider>().deleteRegion(regionId);
    }
  }

  Future<void> _showClearCacheDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to delete all downloaded regions?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<MapProvider>().clearCache();
    }
  }
} 