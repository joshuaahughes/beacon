import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:beacon/features/map/domain/repositories/offline_map_repository.dart';

void main() {
  late OfflineMapRepository mapRepository;
  late Directory tempStorageDir;

  setUp(() async {
    tempStorageDir = await Directory.systemTemp.createTemp('mbtiles_test');
    mapRepository = OfflineMapRepository(storageDirectory: tempStorageDir);
  });

  tearDown(() async {
    if (tempStorageDir.existsSync()) {
      tempStorageDir.deleteSync(recursive: true);
    }
  });

  group('OfflineMapRepository', () {
    test('getDownloadedRegions returns empty array initially', () async {
      // Act
      final regions = await mapRepository.getDownloadedRegions();

      // Assert
      expect(regions, isEmpty);
    });

    test('saveMapFile saves a file to the correct directory and it becomes available', () async {
      // Arrange
      final dummyPdfFile = File('${tempStorageDir.path}/temp_source.mbtiles');
      await dummyPdfFile.writeAsString('fake_mbtiles_data');

      // Act
      final success = await mapRepository.saveMapFile(
        sourceFile: dummyPdfFile,
        regionName: 'test_region'
      );

      final regions = await mapRepository.getDownloadedRegions();

      // Assert
      expect(success, isTrue);
      expect(regions.length, 1);
      
      // The region name corresponds to the filename without extension
      expect(regions.first.name, 'test_region');
      expect(regions.first.filePath.contains('test_region.mbtiles'), isTrue);
    });
  });
}
