import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:meshager/providers/meshtastic_provider.dart';
import 'package:meshager/protos/mesh.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _updateMarkers();
  }

  void _updateMarkers() {
    final provider = Provider.of<MeshtasticProvider>(context, listen: false);
    final position = provider.lastPosition;
    
    if (position != null && position.hasLatitude() && position.hasLongitude()) {
      final lat = position.latitude / 1e7; // Convert from fixed-point to decimal
      final lng = position.longitude / 1e7;
      
      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            point: LatLng(lat, lng),
            width: 40,
            height: 40,
            child: Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40,
            ),
          ),
        );
      });

      // Center map on device position
      _mapController.move(LatLng(lat, lng), _mapController.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: Consumer<MeshtasticProvider>(
        builder: (context, provider, _) {
          // Update markers when position changes
          if (provider.lastPosition != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _updateMarkers());
          }

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(0, 0),
              zoom: 2.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.meshager',
              ),
              MarkerLayer(
                markers: _markers.toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
} 