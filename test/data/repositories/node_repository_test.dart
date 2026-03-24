import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:beacon/data/repositories/node_repository.dart';
import 'package:beacon/domain/models/node_model.dart';
import 'dart:io';
import 'package:path/path.dart';

void main() {
  late Database db;
  late NodeRepository nodeRepository;

  setUpAll(() {
    // Initialize FFI for headless desktop database testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Use an in-memory database for fast isolation
    db = await databaseFactory.openDatabase(inMemoryDatabasePath, options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE mesh_nodes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            numId INTEGER UNIQUE,
            longName TEXT,
            shortName TEXT,
            hardwareModel TEXT,
            latitude REAL,
            longitude REAL,
            altitude REAL,
            batteryLevel INTEGER,
            lastHeard INTEGER
          )
        ''');
      }
    ));
    
    nodeRepository = NodeRepository(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('NodeRepository Local Storage (SQLite)', () {
    test('saveNode inserts a new node when it does not exist', () async {
      // Arrange
      final node = MeshNode(numId: 12345, longName: 'Test Node', shortName: 'TST');

      // Act
      await nodeRepository.saveNode(node);
      final retrievedNodes = await nodeRepository.getAllNodes();

      // Assert
      expect(retrievedNodes.length, 1);
      expect(retrievedNodes.first.numId, 12345);
      expect(retrievedNodes.first.longName, 'Test Node');
    });

    test('saveNode updates an existing node based on numId conflicts', () async {
      // Arrange
      final initialNode = MeshNode(numId: 54321, longName: 'Initial Name', shortName: 'INI');
      await nodeRepository.saveNode(initialNode);

      // Act: Receive an update for the same node number
      final updatedNode = MeshNode(numId: 54321, longName: 'Updated Name', shortName: 'UPD', batteryLevel: 100);
      await nodeRepository.saveNode(updatedNode);
      final retrievedNodes = await nodeRepository.getAllNodes();

      // Assert
      expect(retrievedNodes.length, 1); // Should not duplicate
      expect(retrievedNodes.first.longName, 'Updated Name');
      expect(retrievedNodes.first.batteryLevel, 100);
    });

    test('getNodeByNumId retrieves specific node', () async {
      // Arrange
      final node1 = MeshNode(numId: 111, longName: 'Node 1', shortName: 'N1');
      final node2 = MeshNode(numId: 222, longName: 'Node 2', shortName: 'N2');
      
      await nodeRepository.saveNode(node1);
      await nodeRepository.saveNode(node2);

      // Act
      final result = await nodeRepository.getNodeByNumId(222);

      // Assert
      expect(result, isNotNull);
      expect(result!.numId, 222);
      expect(result.longName, 'Node 2');
    });
  });
}
