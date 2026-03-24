import 'package:sqflite_common/sqlite_api.dart';
import 'package:beacon/domain/models/node_model.dart';

class NodeRepository {
  final Database db;
  static const String tableName = 'mesh_nodes';

  NodeRepository({required this.db});

  /// Saves or updates a MeshNode. Uses numId as the logical unique key to avoid duplication.
  Future<void> saveNode(MeshNode node) async {
    await db.insert(
      tableName,
      node.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves all known MeshNodes from local storage.
  Future<List<MeshNode>> getAllNodes() async {
    final List<Map<String, dynamic>> maps = await db.query(tableName);

    return List.generate(maps.length, (i) {
      return MeshNode.fromMap(maps[i]);
    });
  }

  /// Retrieves a specific MeshNode by its core numId.
  Future<MeshNode?> getNodeByNumId(int numId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'numId = ?',
      whereArgs: [numId],
      limit: 1
    );

    if (maps.isNotEmpty) {
      return MeshNode.fromMap(maps.first);
    }
    
    return null;
  }
}
