import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:beacon/data/repositories/messaging_repository.dart';
import 'package:beacon/domain/models/message_model.dart';
import 'dart:io';

void main() {
  late Database db;
  late MessagingRepository messagingRepository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath, options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
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
    ));
    
    messagingRepository = MessagingRepository(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('MessagingRepository Local Storage', () {
    test('saveMessage stores a new text payload', () async {
      final msg = MeshMessage(
        messageId: 'msg-123',
        senderNumId: 111,
        receiverNumId: 222,
        channelIndex: 0,
        textPayload: 'Hello Meshtastic!',
        timestamp: DateTime.now(),
      );

      await messagingRepository.saveMessage(msg);
      final allMessages = await messagingRepository.getMessagesForChannel(0);

      expect(allMessages.length, 1);
      expect(allMessages.first.textPayload, 'Hello Meshtastic!');
    });

    test('getMessagesForChannel filters by channel index', () async {
      await messagingRepository.saveMessage(MeshMessage(
        messageId: 'msg-1', senderNumId: 1, channelIndex: 0, textPayload: 'Ch 0', timestamp: DateTime.now(),
      ));
      await messagingRepository.saveMessage(MeshMessage(
        messageId: 'msg-2', senderNumId: 1, channelIndex: 1, textPayload: 'Ch 1', timestamp: DateTime.now(),
      ));

      final ch0Messages = await messagingRepository.getMessagesForChannel(0);
      
      expect(ch0Messages.length, 1);
      expect(ch0Messages.first.channelIndex, 0);
      expect(ch0Messages.first.textPayload, 'Ch 0');
    });

    test('updateAcknowledgeStatus marks message as delivered', () async {
      final msg = MeshMessage(
        messageId: 'msg-ack',
        senderNumId: 1,
        channelIndex: 0,
        textPayload: 'Did you get this?',
        timestamp: DateTime.now(),
        isAcknowledged: false,
      );
      
      await messagingRepository.saveMessage(msg);
      await messagingRepository.updateAcknowledgeStatus('msg-ack', true);
      
      final dbMsgs = await messagingRepository.getMessagesForChannel(0);
      expect(dbMsgs.first.isAcknowledged, true);
    });
  });
}
