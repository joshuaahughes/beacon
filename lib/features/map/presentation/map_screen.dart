import 'package:flutter/foundation.dart';
import 'package:beacon/core/utils/platform_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:beacon/features/map/presentation/offline_map_view.dart';
import 'package:beacon/features/map/domain/repositories/offline_map_repository.dart';

import 'package:beacon/features/map/presentation/map_download_screen.dart';
import 'package:beacon/data/providers/database_providers.dart';
import 'package:beacon/domain/models/node_model.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:beacon/core/presentation/widgets/branded_app_bar.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  late OfflineMapRepository _mapRepository;
  bool _isLoading = true;
  LatLng _currentLocation = const LatLng(0, 0); // Default
  OfflineRegion? _selectedOfflineRegion;
  bool _isOfflineMode = false;
  String? _selectedStoreName;
  List<String> _availableStores = [];

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  Future<void> _initMap() async {
    await _determinePosition();
    if (!kIsWeb) {
      await _initStorage();
    }
    setState(() => _isLoading = false);
    if (!kIsWeb) {
      _refreshStores();
    }
  }

  Future<void> _refreshStores() async {
    if (kIsWeb) return;
    final stores = await FMTCRoot.stats.storesAvailable;
    setState(() {
      _availableStores = stores.map((s) => s.storeName).toList();
      if (_availableStores.isNotEmpty && _selectedStoreName == null) {
        _selectedStoreName = _availableStores.first;
      }
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _initStorage() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final mapDir = Directory('${docsDir.path}/maps');
    _mapRepository = OfflineMapRepository(storageDirectory: mapDir);
    
    final regions = await _mapRepository.getDownloadedRegions();
    if (regions.isNotEmpty) {
      setState(() {
        _selectedOfflineRegion = regions.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final nodesAsync = ref.watch(nodesProvider);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Marker> nodeMarkers = [];
    nodesAsync.whenData((nodes) {
      for (final node in nodes) {
        if (node.latitude != null && node.longitude != null) {
          nodeMarkers.add(Marker(
            point: LatLng(node.latitude!, node.longitude!),
            width: 40,
            height: 40,
            child: const Icon(Icons.person_pin_circle, color: Colors.red, size: 30),
          ));
        }
      }
    });

    return Scaffold(
      appBar: BrandedAppBar(
        title: 'Map',
        actions: [
          IconButton(
            icon: Icon(_isOfflineMode ? Icons.cloud_off : Icons.cloud_queue),
            onPressed: () {
              if (_selectedOfflineRegion == null && _availableStores.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No offline maps available. Download one first.')),
                );
                return;
              }
              setState(() => _isOfflineMode = !_isOfflineMode);
            },
            tooltip: _isOfflineMode ? 'Switch to Online' : 'Switch to Offline',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
               await Navigator.of(context).push(
                 MaterialPageRoute(
                   builder: (context) => MapDownloadScreen(center: _currentLocation),
                 ),
               );
               _refreshStores();
            },
          ),
          if (_availableStores.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.layers),
              onSelected: (val) => setState(() => _selectedStoreName = val),
              itemBuilder: (context) => _availableStores.map((s) => 
                PopupMenuItem(value: s, child: Text('Store: $s'))
              ).toList(),
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_isOfflineMode)
             _buildOfflineView(nodeMarkers)
          else
            _buildOnlineMap(nodeMarkers),
          
          // User location button
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              onPressed: _determinePosition,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineView(List<Marker> extraMarkers) {
    // If user has selected a specific Store from the PopupMenu, show that
    if (_selectedStoreName != null) {
      return FlutterMap(
        options: MapOptions(
          initialCenter: _currentLocation,
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.beacon.beacon',
            tileProvider: FMTCTileProvider(
              stores: {_selectedStoreName!: BrowseStoreStrategy.read},
            ),
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _currentLocation,
                width: 30,
                height: 30,
                child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 30),
              ),
              ...extraMarkers,
            ],
          ),
        ],
      );
    }

    // Otherwise fallback to MBTiles if available
    if (_selectedOfflineRegion != null) {
      return OfflineMapView(
        key: ValueKey(_selectedOfflineRegion!.filePath),
        mbtilesPath: _selectedOfflineRegion!.filePath,
        initialCenter: _currentLocation,
        extraMarkers: extraMarkers,
      );
    }

    return const Center(child: Text('No offline data selected.'));
  }

  Widget _buildOnlineMap(List<Marker> extraMarkers) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: _currentLocation,
        initialZoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.beacon.beacon',
          // Optionally cache even in online mode
          tileProvider: _selectedStoreName != null 
            ? FMTCTileProvider(
                stores: {_selectedStoreName!: BrowseStoreStrategy.readUpdateCreate},
              )
            : null,
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _currentLocation,
              width: 30,
              height: 30,
              child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 30),
            ),
            ...extraMarkers,
          ],
        ),
      ],
    );
  }
}
