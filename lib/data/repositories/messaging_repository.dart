import 'package:sqflite_common/sqlite_api.dart';
import 'package:beacon/domain/models/message_model.dart';

class MessagingRepository {
  final Database db;
  static const String tableName = 'mesh_messages';

  MessagingRepository({required this.db});

  Future<void> saveMessage(MeshMessage message) async {
    await db.insert(
      tableName,
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MeshMessage>> getMessagesForChannel(int channelIndex) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'channelIndex = ?',
      whereArgs: [channelIndex],
      orderBy: 'timestamp ASC'
    );

    return List.generate(maps.length, (i) {
      return MeshMessage.fromMap(maps[i]);
    });
  }

  Future<void> updateAcknowledgeStatus(String messageId, bool isAcknowledged) async {
    await db.update(
      tableName,
      {'isAcknowledged': isAcknowledged ? 1 : 0},
      where: 'messageId = ?',
      whereArgs: [messageId]
    );
  }
}
