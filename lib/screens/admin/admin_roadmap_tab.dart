import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/roadmap_item_model.dart';

class AdminRoadmapTab extends StatefulWidget {
  const AdminRoadmapTab({super.key});

  @override
  State<AdminRoadmapTab> createState() => _AdminRoadmapTabState();
}

class _AdminRoadmapTabState extends State<AdminRoadmapTab> {
  String _viewMode = 'kanban'; // 'kanban' or 'list'
  String _filterVersion = 'all';
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Product Roadmap', style: AppTheme.headline4),
              Row(
                children: [
                  // View mode toggle
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'kanban',
                        label: Text('Kanban'),
                        icon: Icon(Icons.view_column, size: 16),
                      ),
                      ButtonSegment(
                        value: 'list',
                        label: Text('List'),
                        icon: Icon(Icons.view_list, size: 16),
                      ),
                    ],
                    selected: {_viewMode},
                    onSelectionChanged: (Set<String> selection) {
                      setState(() => _viewMode = selection.first);
                    },
                  ),
                  const SizedBox(width: 16),
                  // Add item button
                  ElevatedButton.icon(
                    onPressed: () => _showAddItemDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Add from feedback button
                  OutlinedButton.icon(
                    onPressed: () => _showAddFromFeedbackDialog(context),
                    icon: const Icon(Icons.feedback),
                    label: const Text('From Feedback'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // View
          Expanded(
            child: _viewMode == 'kanban'
                ? _buildKanbanView()
                : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('roadmap')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final items = snapshot.data?.docs ?? [];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildKanbanColumn('Backlog', RoadmapStatus.backlog, items),
            _buildKanbanColumn('Planned', RoadmapStatus.planned, items),
            _buildKanbanColumn('In Progress', RoadmapStatus.inProgress, items),
            _buildKanbanColumn('Completed', RoadmapStatus.completed, items),
          ],
        );
      },
    );
  }

  Widget _buildKanbanColumn(String title, RoadmapStatus status, List<QueryDocumentSnapshot> allItems) {
    final columnItems = allItems.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['status'] == status.toString().split('.').last;
    }).toList();

    Color headerColor;
    switch (status) {
      case RoadmapStatus.backlog:
        headerColor = AppTheme.neutral500;
        break;
      case RoadmapStatus.planned:
        headerColor = Colors.blue;
        break;
      case RoadmapStatus.inProgress:
        headerColor = AppTheme.warningColor;
        break;
      case RoadmapStatus.completed:
        headerColor = AppTheme.successColor;
        break;
      default:
        headerColor = AppTheme.neutral500;
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppTheme.neutral50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Column header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: headerColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border(
                  bottom: BorderSide(color: headerColor, width: 2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: headerColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: headerColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${columnItems.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: columnItems.length,
                itemBuilder: (context, index) {
                  final doc = columnItems[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildRoadmapCard(data, doc.id);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('roadmap')
          .orderBy('priority')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 64, color: AppTheme.neutral400),
                const SizedBox(height: 16),
                Text('No roadmap items yet', style: AppTheme.headline6),
                const SizedBox(height: 8),
                Text('Start planning your product roadmap!', style: AppTheme.bodyMedium),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildRoadmapCard(data, doc.id);
          },
        );
      },
    );
  }

  Widget _buildRoadmapCard(Map<String, dynamic> data, String docId) {
    final title = data['title'] as String? ?? 'Untitled';
    final description = data['description'] as String?;
    final type = data['type'] as String? ?? 'feature';
    final priority = data['priority'] as String? ?? 'medium';
    final status = data['status'] as String? ?? 'backlog';
    final targetVersion = data['targetVersion'] as String?;
    final linkedFeedbackId = data['linkedFeedbackId'] as String?;
    final tags = (data['tags'] as List<dynamic>?)?.cast<String>() ?? [];
    final notes = data['notes'] as String?;

    Color typeColor = _getTypeColor(type);
    Color priorityColor = _getPriorityColor(priority);
    IconData typeIcon = _getTypeIcon(type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: typeColor.withOpacity(0.2),
            child: Icon(typeIcon, color: typeColor, size: 20),
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
                  // Priority badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: priorityColor),
                    ),
                    child: Text(
                      priority.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: priorityColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                    ),
                  ),
                  if (targetVersion != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        targetVersion,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                  if (linkedFeedbackId != null) ...[
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Linked to user feedback',
                      child: Icon(Icons.link, size: 14, color: AppTheme.accentColor),
                    ),
                  ],
                ],
              ),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (description != null && description.isNotEmpty) ...[
                    Text(
                      'Description:',
                      style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(description, style: AppTheme.bodyMedium),
                    const SizedBox(height: 16),
                  ],
                  
                  if (tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags.map((tag) => Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 11)),
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  if (notes != null && notes.isNotEmpty) ...[
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
                              Icon(Icons.note, size: 16, color: AppTheme.warningColor),
                              const SizedBox(width: 8),
                              Text(
                                'Notes:',
                                style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(notes, style: AppTheme.bodyMedium),
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
                      // Status actions
                      if (status == 'backlog')
                        ElevatedButton.icon(
                          onPressed: () => _updateStatus(docId, 'planned'),
                          icon: const Icon(Icons.schedule, size: 16),
                          label: const Text('Move to Planned'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        ),
                      if (status == 'planned')
                        ElevatedButton.icon(
                          onPressed: () => _updateStatus(docId, 'inProgress'),
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: const Text('Start Working'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningColor),
                        ),
                      if (status == 'inProgress')
                        ElevatedButton.icon(
                          onPressed: () => _updateStatus(docId, 'completed'),
                          icon: const Icon(Icons.check_circle, size: 16),
                          label: const Text('Mark Complete'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
                        ),
                      
                      // Edit & Delete
                      OutlinedButton.icon(
                        onPressed: () => _showEditItemDialog(context, data, docId),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _deleteItem(docId),
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                        ),
                      ),
                      if (linkedFeedbackId != null)
                        OutlinedButton.icon(
                          onPressed: () => _viewLinkedFeedback(linkedFeedbackId),
                          icon: const Icon(Icons.feedback, size: 16),
                          label: const Text('View Feedback'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.accentColor,
                          ),
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

  Color _getTypeColor(String type) {
    switch (type) {
      case 'feature': return Colors.purple;
      case 'improvement': return Colors.blue;
      case 'bugFix': return AppTheme.errorColor;
      case 'enhancement': return Colors.green;
      case 'technical': return Colors.grey;
      default: return AppTheme.primaryColor;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'critical': return Colors.red;
      case 'high': return Colors.orange;
      case 'medium': return Colors.blue;
      case 'low': return AppTheme.neutral500;
      default: return AppTheme.neutral500;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'feature': return Icons.lightbulb;
      case 'improvement': return Icons.trending_up;
      case 'bugFix': return Icons.bug_report;
      case 'enhancement': return Icons.star;
      case 'technical': return Icons.code;
      default: return Icons.task;
    }
  }

  void _showAddItemDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final versionController = TextEditingController();
    final notesController = TextEditingController();
    String selectedType = 'feature';
    String selectedPriority = 'medium';
    String selectedStatus = 'backlog';
    List<String> tags = [];
    final tagController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Roadmap Item'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  
                  // Type & Priority
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'feature', child: Text('Feature')),
                            DropdownMenuItem(value: 'improvement', child: Text('Improvement')),
                            DropdownMenuItem(value: 'bugFix', child: Text('Bug Fix')),
                            DropdownMenuItem(value: 'enhancement', child: Text('Enhancement')),
                            DropdownMenuItem(value: 'technical', child: Text('Technical')),
                          ],
                          onChanged: (value) => setDialogState(() => selectedType = value!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedPriority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'critical', child: Text('Critical')),
                            DropdownMenuItem(value: 'high', child: Text('High')),
                            DropdownMenuItem(value: 'medium', child: Text('Medium')),
                            DropdownMenuItem(value: 'low', child: Text('Low')),
                          ],
                          onChanged: (value) => setDialogState(() => selectedPriority = value!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Status & Version
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'backlog', child: Text('Backlog')),
                            DropdownMenuItem(value: 'planned', child: Text('Planned')),
                            DropdownMenuItem(value: 'inProgress', child: Text('In Progress')),
                            DropdownMenuItem(value: 'completed', child: Text('Completed')),
                          ],
                          onChanged: (value) => setDialogState(() => selectedStatus = value!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: versionController,
                          decoration: const InputDecoration(
                            labelText: 'Target Version',
                            hintText: 'e.g., v3.0',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Tags
                  TextField(
                    controller: tagController,
                    decoration: InputDecoration(
                      labelText: 'Add Tag',
                      hintText: 'e.g., parent-feature',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (tagController.text.trim().isNotEmpty) {
                            setDialogState(() {
                              tags.add(tagController.text.trim());
                              tagController.clear();
                            });
                          }
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        setDialogState(() {
                          tags.add(value.trim());
                          tagController.clear();
                        });
                      }
                    },
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: tags.map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () => setDialogState(() => tags.remove(tag)),
                        deleteIconColor: AppTheme.errorColor,
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  
                  // Notes
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Internal Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
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
            ElevatedButton(
              onPressed: () => _saveRoadmapItem(
                dialogContext,
                titleController.text,
                descriptionController.text,
                selectedType,
                selectedPriority,
                selectedStatus,
                versionController.text,
                tags,
                notesController.text,
                null, // No linked feedback
              ),
              child: const Text('Add to Roadmap'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFromFeedbackDialog(BuildContext context) async {
    // Show list of pending feedback to convert to roadmap items
    final feedbackSnapshot = await FirebaseFirestore.instance
        .collection('feedback')
        .where('status', isEqualTo: 'pending')
        .get();

    if (!mounted) return;

    if (feedbackSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pending feedback to add')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Roadmap Item from Feedback'),
        content: SizedBox(
          width: 500,
          height: 400,
          child: ListView.builder(
            itemCount: feedbackSnapshot.docs.length,
            itemBuilder: (context, index) {
              final doc = feedbackSnapshot.docs[index];
              final data = doc.data();
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${data['rating']}⭐'),
                  ),
                  title: Text(data['title'] ?? ''),
                  subtitle: Text(
                    '${data['userName']} - ${data['category']}',
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddItemDialogFromFeedback(context, data, doc.id);
                    },
                    child: const Text('Use This'),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialogFromFeedback(BuildContext context, Map<String, dynamic> feedbackData, String feedbackId) {
    // Similar to add dialog but pre-filled from feedback
    final titleController = TextEditingController(text: feedbackData['title'] ?? '');
    final descriptionController = TextEditingController(text: feedbackData['description'] ?? '');
    _showAddItemDialog(context); // For now, just open regular dialog
  }
  
  void _showEditItemDialog(BuildContext context, Map<String, dynamic> data, String docId) {
    // Similar to add dialog but pre-filled with existing data
    // Implementation similar to _showAddItemDialog
  }

  Future<void> _saveRoadmapItem(
    BuildContext dialogContext,
    String title,
    String description,
    String type,
    String priority,
    String status,
    String targetVersion,
    List<String> tags,
    String notes,
    String? linkedFeedbackId,
  ) async {
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }

    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final adminEmail = adminProvider.currentAdmin?.email ?? 'admin';

      final itemId = 'roadmap_${DateTime.now().millisecondsSinceEpoch}';
      
      await FirebaseFirestore.instance.collection('roadmap').doc(itemId).set({
        'id': itemId,
        'title': title.trim(),
        'description': description.trim().isEmpty ? null : description.trim(),
        'type': type,
        'priority': priority,
        'status': status,
        'targetVersion': targetVersion.trim().isEmpty ? null : targetVersion.trim(),
        'linkedFeedbackId': linkedFeedbackId,
        'tags': tags,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': adminEmail,
        'notes': notes.trim().isEmpty ? null : notes.trim(),
        'metadata': {},
      });

      if (mounted) {
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Roadmap item added!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateStatus(String itemId, String newStatus) async {
    try {
      final updates = <String, dynamic>{
        'status': newStatus,
      };
      
      if (newStatus == 'completed') {
        updates['completedAt'] = FieldValue.serverTimestamp();
      }
      
      await FirebaseFirestore.instance
          .collection('roadmap')
          .doc(itemId)
          .update(updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Moved to $newStatus'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteItem(String itemId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Roadmap Item?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('roadmap').doc(itemId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item deleted'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _viewLinkedFeedback(String feedbackId) {
    // TODO: Navigate to feedback tab and highlight this feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Linked feedback ID: $feedbackId')),
    );
  }
}

