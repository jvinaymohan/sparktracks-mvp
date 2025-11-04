import 'package:json_annotation/json_annotation.dart';

part 'message_model.g.dart';

enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('system')
  system,
  @JsonValue('notification')
  notification,
}

@JsonSerializable()
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final DateTime sentAt;
  final bool read;
  final DateTime? readAt;
  final Map<String, dynamic> metadata;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = MessageType.text,
    required this.sentAt,
    this.read = false,
    this.readAt,
    this.metadata = const {},
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    DateTime? sentAt,
    bool? read,
    DateTime? readAt,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      sentAt: sentAt ?? this.sentAt,
      read: read ?? this.read,
      readAt: readAt ?? this.readAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

@JsonSerializable()
class Conversation {
  final String id;
  final String parentId;
  final String coachId;
  final String? studentId; // Optional: conversation about specific student
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final String? lastMessageContent;
  final int unreadCount;
  final bool archived;
  final Map<String, dynamic> metadata;

  Conversation({
    required this.id,
    required this.parentId,
    required this.coachId,
    this.studentId,
    required this.createdAt,
    this.lastMessageAt,
    this.lastMessageContent,
    this.unreadCount = 0,
    this.archived = false,
    this.metadata = const {},
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationToJson(this);

  Conversation copyWith({
    String? id,
    String? parentId,
    String? coachId,
    String? studentId,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    String? lastMessageContent,
    int? unreadCount,
    bool? archived,
    Map<String, dynamic>? metadata,
  }) {
    return Conversation(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      coachId: coachId ?? this.coachId,
      studentId: studentId ?? this.studentId,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      unreadCount: unreadCount ?? this.unreadCount,
      archived: archived ?? this.archived,
      metadata: metadata ?? this.metadata,
    );
  }
}

