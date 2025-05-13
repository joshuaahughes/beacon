import 'package:uuid/uuid.dart';

class Channel {
  final String id;
  final String name;
  final int channelIndex;
  final String? nodeId; // null for broadcast channels
  final DateTime lastMessageTime;
  final String lastMessage;
  final int unreadCount;
  final bool isMuted;
  final bool isFavorite;

  Channel({
    String? id,
    required this.name,
    required this.channelIndex,
    this.nodeId,
    DateTime? lastMessageTime,
    this.lastMessage = '',
    this.unreadCount = 0,
    this.isMuted = false,
    this.isFavorite = false,
  })  : id = id ?? const Uuid().v4(),
        lastMessageTime = lastMessageTime ?? DateTime.now();

  // Create a broadcast channel
  factory Channel.broadcast(int channelIndex, String name) {
    return Channel(
      name: name,
      channelIndex: channelIndex,
      nodeId: null,
    );
  }

  // Create a direct message channel
  factory Channel.direct(int channelIndex, String nodeId, String name) {
    return Channel(
      name: name,
      channelIndex: channelIndex,
      nodeId: nodeId,
    );
  }

  String get contactKey => '$channelIndex${nodeId ?? ''}';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'channelIndex': channelIndex,
      'nodeId': nodeId,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'isMuted': isMuted,
      'isFavorite': isFavorite,
    };
  }

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'],
      name: json['name'],
      channelIndex: json['channelIndex'],
      nodeId: json['nodeId'],
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
      lastMessage: json['lastMessage'],
      unreadCount: json['unreadCount'],
      isMuted: json['isMuted'],
      isFavorite: json['isFavorite'],
    );
  }

  Channel copyWith({
    String? name,
    int? channelIndex,
    String? nodeId,
    DateTime? lastMessageTime,
    String? lastMessage,
    int? unreadCount,
    bool? isMuted,
    bool? isFavorite,
  }) {
    return Channel(
      id: id,
      name: name ?? this.name,
      channelIndex: channelIndex ?? this.channelIndex,
      nodeId: nodeId ?? this.nodeId,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
} 