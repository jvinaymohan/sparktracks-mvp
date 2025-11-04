// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  id: json['id'] as String,
  conversationId: json['conversationId'] as String,
  senderId: json['senderId'] as String,
  receiverId: json['receiverId'] as String,
  content: json['content'] as String,
  type:
      $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
      MessageType.text,
  sentAt: DateTime.parse(json['sentAt'] as String),
  read: json['read'] as bool? ?? false,
  readAt: json['readAt'] == null
      ? null
      : DateTime.parse(json['readAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'id': instance.id,
  'conversationId': instance.conversationId,
  'senderId': instance.senderId,
  'receiverId': instance.receiverId,
  'content': instance.content,
  'type': _$MessageTypeEnumMap[instance.type]!,
  'sentAt': instance.sentAt.toIso8601String(),
  'read': instance.read,
  'readAt': instance.readAt?.toIso8601String(),
  'metadata': instance.metadata,
};

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.system: 'system',
  MessageType.notification: 'notification',
};

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
  id: json['id'] as String,
  parentId: json['parentId'] as String,
  coachId: json['coachId'] as String,
  studentId: json['studentId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastMessageAt: json['lastMessageAt'] == null
      ? null
      : DateTime.parse(json['lastMessageAt'] as String),
  lastMessageContent: json['lastMessageContent'] as String?,
  unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
  archived: json['archived'] as bool? ?? false,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parentId': instance.parentId,
      'coachId': instance.coachId,
      'studentId': instance.studentId,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
      'lastMessageContent': instance.lastMessageContent,
      'unreadCount': instance.unreadCount,
      'archived': instance.archived,
      'metadata': instance.metadata,
    };
