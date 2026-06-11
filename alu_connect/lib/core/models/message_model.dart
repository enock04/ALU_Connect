class MessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String body;
  final DateTime sentAt;
  final bool isMe;

  const MessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.body,
    required this.sentAt,
    this.isMe = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final senderId = json['sender_id'] as String;
    return MessageModel(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      senderId: senderId,
      senderName: json['sender_name'] as String? ?? 'Unknown',
      senderAvatar: json['sender_avatar'] as String?,
      body: json['body'] as String,
      sentAt: DateTime.parse(json['sent_at'] as String),
      isMe: currentUserId != null && senderId == currentUserId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'room_id': roomId,
        'sender_id': senderId,
        'sender_name': senderName,
        'sender_avatar': senderAvatar,
        'body': body,
        'sent_at': sentAt.toIso8601String(),
      };
}

class ChatRoom {
  final String id;
  final String name;
  final String? description;
  final int memberCount;
  final bool isJoined;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isTeamChat;
  final String? ideaId;

  const ChatRoom({
    required this.id,
    required this.name,
    this.description,
    this.memberCount = 0,
    this.isJoined = false,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isTeamChat = false,
    this.ideaId,
  });

  ChatRoom copyWith({
    String? id,
    String? name,
    String? description,
    int? memberCount,
    bool? isJoined,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? isTeamChat,
    String? ideaId,
  }) =>
      ChatRoom(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        memberCount: memberCount ?? this.memberCount,
        isJoined: isJoined ?? this.isJoined,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        unreadCount: unreadCount ?? this.unreadCount,
        isTeamChat: isTeamChat ?? this.isTeamChat,
        ideaId: ideaId ?? this.ideaId,
      );

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      memberCount: json['member_count'] as int? ?? 0,
      isJoined: json['is_joined'] as bool? ?? false,
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      isTeamChat: json['type'] == 'team_chat',
      ideaId: json['idea_id'] as String?,
    );
  }
}
