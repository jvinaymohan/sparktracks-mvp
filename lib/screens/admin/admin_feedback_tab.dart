import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';

class AdminFeedbackTab extends StatefulWidget {
  const AdminFeedbackTab({super.key});

  @override
  State<AdminFeedbackTab> createState() => _AdminFeedbackTabState();
}

class _AdminFeedbackTabState extends State<AdminFeedbackTab> {
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('User Feedback', style: AppTheme.headline4),
              // Status Filter
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('All')),
                  ButtonSegment(value: 'pending', label: Text('Pending')),
                  ButtonSegment(value: 'reviewed', label: Text('Reviewed')),
                  ButtonSegment(value: 'resolved', label: Text('Resolved')),
                ],
                selected: {_statusFilter},
                onSelectionChanged: (Set<String> selection) {
                  setState(() {
                    _statusFilter = selection.first;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Feedback List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('feedback')
                  .orderBy('submittedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading feedback: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.feedback_outlined,
                          size: 64,
                          color: AppTheme.neutral400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No feedback submitted yet',
                          style: AppTheme.headline6.copyWith(color: AppTheme.neutral600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'User feedback will appear here when submitted',
                          style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral500),
                        ),
                      ],
                    ),
                  );
                }

                final allFeedback = snapshot.data!.docs;
                
                // Filter by status
                final filteredFeedback = _statusFilter == 'all'
                    ? allFeedback
                    : allFeedback.where((doc) {
                        final status = doc.data() as Map<String, dynamic>;
                        return status['status'] == _statusFilter;
                      }).toList();

                if (filteredFeedback.isEmpty) {
                  return Center(
                    child: Text(
                      'No ${_statusFilter} feedback',
                      style: AppTheme.bodyLarge.copyWith(color: AppTheme.neutral600),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredFeedback.length,
                  itemBuilder: (context, index) {
                    final doc = filteredFeedback[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    return _buildFeedbackCard(data, doc.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> feedback, String docId) {
    final status = feedback['status'] as String? ?? 'pending';
    final category = feedback['category'] as String? ?? 'general';
    final rating = feedback['rating'] as int? ?? 0;
    final title = feedback['title'] as String? ?? 'No title';
    final description = feedback['description'] as String?;
    final userName = feedback['userName'] as String? ?? 'Unknown User';
    final userEmail = feedback['userEmail'] as String? ?? '';
    final userType = feedback['userType'] as String? ?? '';
    final submittedAt = feedback['submittedAt'] as Timestamp?;
    final adminNotes = feedback['adminNotes'] as String?;

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'reviewed':
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.visibility;
        break;
      case 'resolved':
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        break;
      case 'inProgress':
        statusColor = Colors.blue;
        statusIcon = Icons.hourglass_bottom;
        break;
      default:
        statusColor = AppTheme.neutral500;
        statusIcon = Icons.pending;
    }

    Color categoryColor;
    IconData categoryIcon;
    switch (category) {
      case 'bug':
        categoryColor = AppTheme.errorColor;
        categoryIcon = Icons.bug_report;
        break;
      case 'feature':
        categoryColor = Colors.purple;
        categoryIcon = Icons.lightbulb;
        break;
      case 'ui':
        categoryColor = Colors.orange;
        categoryIcon = Icons.palette;
        break;
      case 'performance':
        categoryColor = Colors.red;
        categoryIcon = Icons.speed;
        break;
      default:
        categoryColor = AppTheme.primaryColor;
        categoryIcon = Icons.feedback;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: categoryColor.withOpacity(0.2),
            child: Icon(categoryIcon, color: categoryColor, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: AppTheme.neutral600),
                  const SizedBox(width: 4),
                  Text('$userName ($userType)', style: AppTheme.bodySmall),
                  const SizedBox(width: 12),
                  Icon(Icons.email, size: 14, color: AppTheme.neutral600),
                  const SizedBox(width: 4),
                  Text(userEmail, style: AppTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  ...List.generate(5, (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  )),
                  const SizedBox(width: 8),
                  if (submittedAt != null)
                    Text(
                      _formatDate(submittedAt.toDate()),
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral500),
                    ),
                ],
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.neutral50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  if (description != null && description.isNotEmpty) ...[
                    Text(
                      'Description:',
                      style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(description, style: AppTheme.bodyMedium),
                    const SizedBox(height: 16),
                  ],
                  
                  // Admin Notes
                  if (adminNotes != null && adminNotes.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.admin_panel_settings, size: 16, color: AppTheme.warningColor),
                              const SizedBox(width: 8),
                              Text(
                                'Admin Notes:',
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.warningColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(adminNotes, style: AppTheme.bodyMedium),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Actions
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (status == 'pending')
                        ElevatedButton.icon(
                          onPressed: () => _updateStatus(docId, 'reviewed'),
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('Mark as Reviewed'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.warningColor,
                          ),
                        ),
                      if (status == 'reviewed')
                        ElevatedButton.icon(
                          onPressed: () => _updateStatus(docId, 'inProgress'),
                          icon: const Icon(Icons.hourglass_bottom, size: 16),
                          label: const Text('In Progress'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      if (status != 'resolved')
                        ElevatedButton.icon(
                          onPressed: () => _updateStatus(docId, 'resolved'),
                          icon: const Icon(Icons.check_circle, size: 16),
                          label: const Text('Mark as Resolved'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                          ),
                        ),
                      OutlinedButton.icon(
                        onPressed: () => _showAddNotesDialog(docId, adminNotes),
                        icon: const Icon(Icons.note_add, size: 16),
                        label: Text(adminNotes == null ? 'Add Notes' : 'Edit Notes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(String feedbackId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('feedback')
          .doc(feedbackId)
          .update({
        'status': newStatus,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': 'admin', // TODO: Use actual admin ID
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Feedback marked as $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddNotesDialog(String feedbackId, String? currentNotes) async {
    final notesController = TextEditingController(text: currentNotes ?? '');

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Notes'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Add your notes here...',
          ),
          maxLines: 5,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('feedback')
                    .doc(feedbackId)
                    .update({
                  'adminNotes': notesController.text.trim(),
                });

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notes saved'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving notes: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

