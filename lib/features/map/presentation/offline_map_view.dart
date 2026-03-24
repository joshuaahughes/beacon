import 'package:flutter/foundation.dart';
import 'package:beacon/core/utils/platform_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:latlong2/latlong.dart';

class OfflineMapView extends StatefulWidget {
  final String mbtilesPath;
  final LatLng? initialCenter;
  
  const OfflineMapView({
    super.key, 
    required this.mbtilesPath,
    this.initialCenter,
  });

  @override
  State<OfflineMapView> createState() => _OfflineMapViewState();
}

class _OfflineMapViewState extends State<OfflineMapView> {
  late Future<MbTiles> _mbtilesFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the DB parser for the MBTiles file
    _mbtilesFuture = _loadMbTiles();
  }

  Future<MbTiles> _loadMbTiles() async {
    if (kIsWeb) {
      throw Exception('MBTiles are not supported on the web platform.');
    }
    try {
      final file = File(widget.mbtilesPath);
      if (!await file.exists()) {
        throw Exception('File does not exist at ${widget.mbtilesPath}');
      }
      return MbTiles(mbtilesPath: widget.mbtilesPath);
    } catch (e) {
      // Re-throw with more context
      throw Exception('MBTiles Error: $e\nEnsure the file is a valid .mbtiles SQLite database.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MbTiles>(
      future: _mbtilesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.grey[200],
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load offline map',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('Map data empty.'));
        }

        final mbtiles = snapshot.data!;
        final metadata = mbtiles.getMetadata();
        
        LatLng viewCenter = widget.initialCenter ?? const LatLng(0, 0);
        if (widget.initialCenter == null && metadata.defaultCenter != null) {
           viewCenter = LatLng(metadata.defaultCenter!.latitude, metadata.defaultCenter!.longitude);
        }

        return FlutterMap(
          options: MapOptions(
            initialCenter: viewCenter,
            initialZoom: widget.initialCenter != null ? 13 : (metadata.defaultZoom ?? 2),
          ),
          children: [
            TileLayer(
              tileProvider: MbTilesTileProvider(mbtiles: mbtiles),
              maxNativeZoom: metadata.maxZoom?.toInt() ?? 18,
              minNativeZoom: metadata.minZoom?.toInt() ?? 0,
            ),
            // Inject Meshtastic Node markers
            MarkerLayer(
              markers: [
                Marker(
                  point: viewCenter, 
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.person_pin_circle,
                    color: Colors.blue,
                    size: 30,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
