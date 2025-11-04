import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/messaging_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Consumer3<MessagingProvider, AuthProvider, UserProvider>(
        builder: (context, messagingProvider, authProvider, userProvider, _) {
          final currentUserId = authProvider.currentUser?.id ?? '';
          final conversations = messagingProvider.getConversationsForUser(currentUserId);
          
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.neutral400),
                  const SizedBox(height: AppTheme.spacingL),
                  Text('No conversations yet', style: AppTheme.headline6),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Start a conversation with a coach or parent',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                  ),
                ],
              ),
            );
          }
          
          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final otherUserId = conversation.parentId == currentUserId
                  ? conversation.coachId
                  : conversation.parentId;
              
              final otherUser = userProvider.getUserById(otherUserId);
              
              return _buildConversationTile(
                context,
                conversation,
                otherUser,
                currentUserId,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewMessageDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Message'),
      ),
    );
  }

  Widget _buildConversationTile(
    BuildContext context,
    Conversation conversation,
    User? otherUser,
    String currentUserId,
  ) {
    final hasUnread = conversation.unreadCount > 0;
    
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              otherUser?.name.substring(0, 1).toUpperCase() ?? '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          if (hasUnread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.errorColor,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '${conversation.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        otherUser?.name ?? 'Unknown User',
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        conversation.lastMessageContent ?? 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: conversation.lastMessageAt != null
          ? Text(
              _formatTime(conversation.lastMessageAt!),
              style: AppTheme.bodySmall.copyWith(
                color: hasUnread ? AppTheme.primaryColor : AppTheme.neutral600,
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
            )
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversation: conversation,
              otherUser: otherUser,
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }

  void _showNewMessageDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Select a coach from the Browse Classes screen to start a conversation'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }
}

