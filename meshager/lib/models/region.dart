import 'package:flutter_map/flutter_map.dart';

class Region {
  final String id;
  final LatLngBounds bounds;
  final int minZoom;
  final int maxZoom;

  Region({
    required this.id,
    required this.bounds,
    required this.minZoom,
    required this.maxZoom,
  });
} 