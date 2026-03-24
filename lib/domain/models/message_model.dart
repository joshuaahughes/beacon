class MeshMessage {
  int? id;

  String messageId;
  int senderNumId;
  int? receiverNumId; // null implies broadcast to channel
  int channelIndex;
  
  String textPayload;
  DateTime timestamp;
  bool isAcknowledged;

  MeshMessage({
    this.id,
    required this.messageId,
    required this.senderNumId,
    this.receiverNumId,
    required this.channelIndex,
    required this.textPayload,
    required this.timestamp,
    this.isAcknowledged = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'messageId': messageId,
      'senderNumId': senderNumId,
      'receiverNumId': receiverNumId,
      'channelIndex': channelIndex,
      'textPayload': textPayload,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isAcknowledged': isAcknowledged ? 1 : 0, // SQLite boolean map
    };
  }

  factory MeshMessage.fromMap(Map<String, dynamic> map) {
    return MeshMessage(
      id: map['id'],
      messageId: map['messageId'],
      senderNumId: map['senderNumId'],
      receiverNumId: map['receiverNumId'],
      channelIndex: map['channelIndex'],
      textPayload: map['textPayload'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isAcknowledged: map['isAcknowledged'] == 1,
    );
  }
}
