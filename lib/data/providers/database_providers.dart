import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:beacon/data/repositories/node_repository.dart';
import 'package:beacon/domain/models/node_model.dart';
import 'package:beacon/data/repositories/messaging_repository.dart';
import 'package:beacon/domain/models/message_model.dart';

// Provides the initialized database instance
final databaseProvider = FutureProvider<Database>((ref) async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'beacon_db.sqlite');

  return await openDatabase(
    path,
    version: 2,
    onCreate: (Database db, int version) async {
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
      await db.execute('''
        CREATE TABLE mesh_messages(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          messageId TEXT UNIQUE,
          senderNumId INTEGER,
          receiverNumId INTEGER,
          channelIndex INTEGER,
          textPayload TEXT,
          timestamp INTEGER,
          isAcknowledged INTEGER
        )
      ''');
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute('''
          CREATE TABLE mesh_messages(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            messageId TEXT UNIQUE,
            senderNumId INTEGER,
            receiverNumId INTEGER,
            channelIndex INTEGER,
            textPayload TEXT,
            timestamp INTEGER,
            isAcknowledged INTEGER
          )
        ''');
      }
    },
  );
});

// Exposes the NodeRepository injected with the Database
final nodeRepositoryProvider = FutureProvider<NodeRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return NodeRepository(db: db);
});

// A stream that UI can listen to containing the current list of MeshNodes
final nodesProvider = StreamProvider((ref) async* {
  final repo = await ref.watch(nodeRepositoryProvider.future);
  
  // Initially yield what we have
  yield await repo.getAllNodes();
  
  // Note: For a live app we would need a Stream controller inside the repo
  // or use tools like `sqflite_common_ffi` watch APIs to emit updates.
  // For the prototype we mock this by yielding again whenever invalidated.
});

// Exposes the MessagingRepository
final messagingRepositoryProvider = FutureProvider<MessagingRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return MessagingRepository(db: db);
});

// A stream providing real-time messages for a specific channel index
final channelMessagesProvider = StreamProvider.family<List<MeshMessage>, int>((ref, channelIndex) async* {
  final repo = await ref.watch(messagingRepositoryProvider.future);
  yield await repo.getMessagesForChannel(channelIndex);
});
