import 'package:flutter/material.dart';
import '../models/message_model.dart';

class MessagingProvider with ChangeNotifier {
  final List<Conversation> _conversations = [];
  final List<Message> _messages = [];

  List<Conversation> get conversations => _conversations;
  List<Message> get messages => _messages;

  // Get conversations for a user
  List<Conversation> getConversationsForUser(String userId) {
    return _conversations.where((c) => 
      c.parentId == userId || c.coachId == userId
    ).toList()..sort((a, b) => 
      (b.lastMessageAt ?? b.createdAt).compareTo(a.lastMessageAt ?? a.createdAt)
    );
  }

  // Get or create conversation
  Conversation getOrCreateConversation({
    required String parentId,
    required String coachId,
    String? studentId,
  }) {
    // Try to find existing conversation
    final existing = _conversations.where((c) =>
      c.parentId == parentId &&
      c.coachId == coachId &&
      c.studentId == studentId
    ).toList();
    
    if (existing.isNotEmpty) {
      return existing.first;
    }
    
    // Create new conversation
    final conversation = Conversation(
      id: 'conv_${DateTime.now().millisecondsSinceEpoch}',
      parentId: parentId,
      coachId: coachId,
      studentId: studentId,
      createdAt: DateTime.now(),
    );
    
    _conversations.add(conversation);
    notifyListeners();
    return conversation;
  }

  // Get messages for conversation
  List<Message> getMessagesForConversation(String conversationId) {
    return _messages.where((m) => m.conversationId == conversationId).toList()
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
  }

  // Send message
  void sendMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
  }) {
    final message = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      type: type,
      sentAt: DateTime.now(),
    );
    
    _messages.add(message);
    
    // Update conversation
    final convIndex = _conversations.indexWhere((c) => c.id == conversationId);
    if (convIndex != -1) {
      _conversations[convIndex] = _conversations[convIndex].copyWith(
        lastMessageAt: DateTime.now(),
        lastMessageContent: content,
        unreadCount: _conversations[convIndex].unreadCount + 1,
      );
    }
    
    notifyListeners();
  }

  // Mark message as read
  void markAsRead(String messageId, String userId) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1 && _messages[index].receiverId == userId) {
      _messages[index] = _messages[index].copyWith(
        read: true,
        readAt: DateTime.now(),
      );
      
      // Update conversation unread count
      final conversationId = _messages[index].conversationId;
      final convIndex = _conversations.indexWhere((c) => c.id == conversationId);
      if (convIndex != -1) {
        final unreadCount = _messages.where((m) =>
          m.conversationId == conversationId &&
          m.receiverId == userId &&
          !m.read
        ).length;
        
        _conversations[convIndex] = _conversations[convIndex].copyWith(
          unreadCount: unreadCount,
        );
      }
      
      notifyListeners();
    }
  }

  // Mark all messages in conversation as read
  void markConversationAsRead(String conversationId, String userId) {
    bool updated = false;
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].conversationId == conversationId &&
          _messages[i].receiverId == userId &&
          !_messages[i].read) {
        _messages[i] = _messages[i].copyWith(
          read: true,
          readAt: DateTime.now(),
        );
        updated = true;
      }
    }
    
    if (updated) {
      final convIndex = _conversations.indexWhere((c) => c.id == conversationId);
      if (convIndex != -1) {
        _conversations[convIndex] = _conversations[convIndex].copyWith(
          unreadCount: 0,
        );
      }
      notifyListeners();
    }
  }

  // Get unread count for user
  int getUnreadCount(String userId) {
    return _messages.where((m) =>
      m.receiverId == userId && !m.read
    ).length;
  }
}

