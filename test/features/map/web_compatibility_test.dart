import 'package:flutter_test/flutter_test.dart';
import 'package:beacon/features/map/domain/repositories/offline_map_repository.dart';
import 'dart:io';

void main() {
  test('OfflineMapRepository handles non-existent storage directory gracefully', () async {
    // This simulates the behavior we expect on web where the directory won't exist or be accessible
    final nonExistentDir = Directory('/non/existent/path/for/test');
    final repository = OfflineMapRepository(storageDirectory: nonExistentDir);

    final regions = await repository.getDownloadedRegions();
    
    expect(regions, isEmpty);
  });
}
