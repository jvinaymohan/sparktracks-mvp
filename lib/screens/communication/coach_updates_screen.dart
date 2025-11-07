import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/coach_update_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/navigation_helper.dart';
import 'package:intl/intl.dart';

/// Coach Updates Feed Screen (v3.0)
/// Central hub for coach to post updates, announcements, and communicate with students
class CoachUpdatesScreen extends StatefulWidget {
  const CoachUpdatesScreen({super.key});

  @override
  State<CoachUpdatesScreen> createState() => _CoachUpdatesScreenState();
}

class _CoachUpdatesScreenState extends State<CoachUpdatesScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final coachId = authProvider.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Updates & Announcements'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationHelper.goToDashboard(context),
        ),
        actions: [
          NavigationHelper.buildGradientHomeButton(context),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('coachUpdates')
            .where('coachId', isEqualTo: coachId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final update = CoachUpdate.fromJson(doc.data() as Map<String, dynamic>);
              return _buildUpdateCard(update);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateUpdateDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Post Update'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.announcement, size: 80, color: AppTheme.neutral400),
          const SizedBox(height: 16),
          Text('No Updates Yet', style: AppTheme.headline5),
          const SizedBox(height: 8),
          Text(
            'Post your first update to communicate with students!',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateUpdateDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Post First Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard(CoachUpdate update) {
    IconData icon;
    Color color;
    
    switch (update.type) {
      case UpdateType.classCancelled:
        icon = Icons.event_busy;
        color = AppTheme.errorColor;
        break;
      case UpdateType.homework:
        icon = Icons.assignment;
        color = AppTheme.accentColor;
        break;
      case UpdateType.performance:
        icon = Icons.star;
        color = Colors.purple;
        break;
      case UpdateType.achievement:
        icon = Icons.emoji_events;
        color = AppTheme.successColor;
        break;
      default:
        icon = Icons.announcement;
        color = AppTheme.primaryColor;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(update.title, style: AppTheme.headline6),
                      Text(
                        DateFormat('MMM dd, yyyy • h:mm a').format(update.createdAt),
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                      ),
                    ],
                  ),
                ),
                if (update.isPinned)
                  Icon(Icons.push_pin, color: color, size: 20),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(update.message, style: AppTheme.bodyMedium),
          ),
          
          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.visibility, size: 16, color: AppTheme.neutral500),
                const SizedBox(width: 4),
                Text('${update.viewCount} views', style: AppTheme.bodySmall),
                const SizedBox(width: 16),
                if (update.type == UpdateType.homework) ...[
                  Icon(Icons.assignment_turned_in, size: 16, color: AppTheme.neutral500),
                  const SizedBox(width: 4),
                  Text('${update.submittedByIds.length} submitted', style: AppTheme.bodySmall),
                ],
              ],
            ),
          ),
          
          // Actions
          ButtonBar(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.delete, size: 18),
                label: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateUpdateDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    UpdateType selectedType = UpdateType.general;
    bool sendNotification = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Post an Update'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Selection
                  DropdownButtonFormField<UpdateType>(
                    value: selectedType,
                    decoration: AppTheme.inputDecoration(
                      labelText: 'Update Type',
                      prefixIcon: const Icon(Icons.category),
                    ),
                    items: const [
                      DropdownMenuItem(value: UpdateType.general, child: Text('📢 General Update')),
                      DropdownMenuItem(value: UpdateType.classCancelled, child: Text('❌ Class Cancelled/Rescheduled')),
                      DropdownMenuItem(value: UpdateType.homework, child: Text('📚 Homework Assignment')),
                      DropdownMenuItem(value: UpdateType.performance, child: Text('⭐ Performance Update')),
                      DropdownMenuItem(value: UpdateType.achievement, child: Text('🏆 Achievement Celebration')),
                    ],
                    onChanged: (value) => setDialogState(() => selectedType = value!),
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  TextField(
                    controller: titleController,
                    decoration: AppTheme.inputDecoration(
                      labelText: 'Title',
                      hintText: 'What\'s this about?',
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Message
                  TextField(
                    controller: messageController,
                    decoration: AppTheme.inputDecoration(
                      labelText: 'Message',
                      hintText: 'Write your update...',
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  
                  // Send Notification
                  CheckboxListTile(
                    value: sendNotification,
                    onChanged: (value) => setDialogState(() => sendNotification = value!),
                    title: const Text('Send Push Notification'),
                    subtitle: const Text('Students will receive a notification'),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () => _postUpdate(
                dialogContext,
                selectedType,
                titleController.text,
                messageController.text,
                sendNotification,
              ),
              icon: const Icon(Icons.send),
              label: const Text('Post Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _postUpdate(
    BuildContext dialogContext,
    UpdateType type,
    String title,
    String message,
    bool sendNotification,
  ) async {
    if (title.trim().isEmpty || message.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final coachId = authProvider.currentUser?.id ?? '';
      final coachName = authProvider.currentUser?.name ?? 'Coach';

      final update = CoachUpdate(
        id: 'update_${DateTime.now().millisecondsSinceEpoch}',
        coachId: coachId,
        coachName: coachName,
        type: type,
        title: title.trim(),
        message: message.trim(),
        createdAt: DateTime.now(),
        sendNotification: sendNotification,
      );

      await FirebaseFirestore.instance
          .collection('coachUpdates')
          .doc(update.id)
          .set(update.toJson());

      if (mounted) {
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Update posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

