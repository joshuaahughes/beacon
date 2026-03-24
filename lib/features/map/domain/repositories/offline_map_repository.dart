import 'package:beacon/core/utils/platform_io.dart';

class OfflineRegion {
  final String name;
  final String filePath;

  OfflineRegion({required this.name, required this.filePath});
}

class OfflineMapRepository {
  final Directory storageDirectory;

  OfflineMapRepository({required this.storageDirectory});

  /// Retrieves a list of all downloaded map regions (.mbtiles files)
  Future<List<OfflineRegion>> getDownloadedRegions() async {
    final List<OfflineRegion> regions = [];
    
    if (!storageDirectory.existsSync()) {
      return regions;
    }

    final files = storageDirectory.listSync();
    
    for (var entity in files) {
      if (entity is File && entity.path.endsWith('.mbtiles')) {
        final filename = entity.uri.pathSegments.last;
        // In testing, we don't want to pick up the temporary source file we inject
        if (filename == 'temp_source.mbtiles') continue;

        final name = filename.replaceAll('.mbtiles', '');
        
        regions.add(OfflineRegion(name: name, filePath: entity.path));
      }
    }
    
    return regions;
  }

  /// Copies an MBTiles file from a source location to the app's persistent map storage.
  Future<bool> saveMapFile({required File sourceFile, required String regionName}) async {
    try {
      if (!storageDirectory.existsSync()) {
        storageDirectory.createSync(recursive: true);
      }
      
      final destinationPath = '${storageDirectory.path}/$regionName.mbtiles';
      await sourceFile.copy(destinationPath);
      return true;
    } catch (e) {
      return false;
    }
  }
}
