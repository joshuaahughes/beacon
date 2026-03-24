import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';

class MapDownloadScreen extends StatefulWidget {
  final LatLng center;

  const MapDownloadScreen({super.key, required this.center});

  @override
  State<MapDownloadScreen> createState() => _MapDownloadScreenState();
}

class _MapDownloadScreenState extends State<MapDownloadScreen> {
  final _nameController = TextEditingController(text: 'MyRegion');
  double _radiusKm = 5.0;
  int _minZoom = 0;
  int _maxZoom = 16;
  bool _isDownloading = false;
  double _progress = 0;
  String _status = 'Ready';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _startDownload() async {
    if (_nameController.text.isEmpty) return;

    setState(() {
      _isDownloading = true;
      _status = 'Calculating tiles...';
    });

    try {
      final store = FMTCStore(_nameController.text);
      
      if (!await store.manage.ready) {
        setState(() => _status = 'Creating store...');
        await store.manage.create();
      }
      
      final downloadableRegion = CircleRegion(widget.center, _radiusKm).toDownloadable(
        minZoom: _minZoom,
        maxZoom: _maxZoom,
        options: TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.beacon.beacon',
        ),
      );

      final downloadInstance = store.download.startForeground(
        region: downloadableRegion,
        parallelThreads: 5,
      );

      await for (final progress in downloadInstance.downloadProgress) {
        if (!mounted) break;
        setState(() {
          _progress = (progress.percentageProgress) / 100;
          _status = 'Downloading... ${progress.successfulTilesCount}/${progress.maxTilesCount}';
        });
        
        if (progress.percentageProgress >= 100) {
           setState(() {
             _status = 'Download Complete!';
             _isDownloading = false;
           });
           break;
        }
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _status = 'Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Download Region')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Store Name',
                helperText: 'e.g. Home_Area',
              ),
            ),
            const SizedBox(height: 24),
            Text('Radius: ${_radiusKm.toStringAsFixed(1)} km'),
            Slider(
              value: _radiusKm,
              min: 1,
              max: 20,
              onChanged: _isDownloading ? null : (v) => setState(() => _radiusKm = v),
            ),
            const SizedBox(height: 16),
            Text('Min Zoom: $_minZoom'),
            Slider(
              value: _minZoom.toDouble(),
              min: 0,
              max: 18,
              divisions: 18,
              onChanged: _isDownloading ? null : (v) => setState(() => _minZoom = v.toInt()),
            ),
            const SizedBox(height: 16),
            Text('Max Zoom: $_maxZoom'),
            Slider(
              value: _maxZoom.toDouble(),
              min: 1,
              max: 18,
              divisions: 17,
              onChanged: _isDownloading ? null : (v) => setState(() => _maxZoom = v.toInt()),
            ),
            const SizedBox(height: 32),
            if (_isDownloading) ...[
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 16),
            ],
            Center(
              child: Text(
                _status,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isDownloading ? null : _startDownload,
                icon: const Icon(Icons.download),
                label: const Text('Start Download'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
